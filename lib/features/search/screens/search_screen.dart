import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/bottom_cart_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_icon_button.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/restaurant_card_widget.dart';
import 'package:stackfood_multivendor/common/widgets/search_field_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cuisine/controllers/cuisine_controller.dart';
import 'package:stackfood_multivendor/features/dashboard/controllers/dashboard_controller.dart';
import 'package:stackfood_multivendor/features/search/controllers/search_controller.dart' as search;
import 'package:stackfood_multivendor/features/search/domain/models/top_category_model.dart';
import 'package:stackfood_multivendor/features/search/widgets/filter_widget.dart';
import 'package:stackfood_multivendor/features/search/widgets/search_result_view.dart';
import 'package:stackfood_multivendor/features/search/widgets/search_suggestion_list_tile.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/helper/voice_permission_handler.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

part '../widgets/search_initial_view.dart';
part '../widgets/search_suggestion_view.dart';

class SearchScreen extends StatefulWidget {
  final bool fromNav;
  const SearchScreen({super.key, this.fromNav = false});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  late bool _isLoggedIn;
  final ScrollController scrollController = ScrollController();
  final TextEditingController _searchTextEditingController = TextEditingController();
  List<Map<String, dynamic>> _foodsAndRestaurants = <Map<String, dynamic>>[];
  bool _showSuggestion = false;
  int _historyDisplayCount = 5;
  late TabController _tabController;
  bool _cuisineShimmerMinElapsed = false;

  @override
  void initState() {
    super.initState();
    _historyDisplayCount = 5;
    _isLoggedIn = Get.find<AuthController>().isLoggedIn();
    _tabController = TabController(length: 3, initialIndex: 0, vsync: this);
    _tabController.addListener(() {
      if(_tabController.indexIsChanging) return;
      Get.find<search.SearchController>().setRestaurant(_tabController.index == 2, willUpdate: false);
    });
    Get.find<search.SearchController>().setSearchMode(true, canUpdate: false);
    if(_isLoggedIn) {
      Get.find<search.SearchController>().getSuggestedFoods();
    }
    Get.find<CuisineController>().getCuisineList();
    Get.find<search.SearchController>().getHistoryList();
    Get.find<search.SearchController>().getTrendingSearches();
    Get.find<search.SearchController>().getTopCategories();
    Get.find<search.SearchController>().getFeaturedRestaurants();
    Get.find<search.SearchController>().getExclusiveDeals();
    Future.delayed(const Duration(milliseconds: 500), () {
      if(mounted) {
        setState(() => _cuisineShimmerMinElapsed = true);
      }
    });
  }

  Future<void> _searchSuggestions(String query) async {
    _foodsAndRestaurants = [];
    if (query == '') {
      _showSuggestion = false;
      _foodsAndRestaurants = [];
    } else {
      _showSuggestion = true;
      _foodsAndRestaurants = await Get.find<search.SearchController>().getSearchSuggestions(query);
    }
    setState(() {});
  }

  void _actionOnBackButton() {
    if(!Get.find<search.SearchController>().isSearchMode) {
      Get.find<search.SearchController>().setSearchMode(true);
      _searchTextEditingController.text = '';
      _showSuggestion = false;
    } else if(_searchTextEditingController.text.isNotEmpty) {
      _searchTextEditingController.text = '';
      _showSuggestion = false;
      setState(() {});
    } else {
      if(!widget.fromNav){
        Get.back();
      }else{
        Get.find<DashboardController>().selectTab(0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        _actionOnBackButton();
      },
      child: Scaffold(
        backgroundColor: context.surfaceContainer,
        body: SafeArea(child: GetBuilder<search.SearchController>(builder: (searchController) {
          return Stack(
            children: [
              Column(children: [
                  Container(
                    padding: EdgeInsets.only(top: Dimensions.fontSizeDefault),
                    color: context.surfaceContainer,
                    child: SizedBox( width: Dimensions.webMaxWidth, child: Row(children: [
                        SizedBox(width: ResponsiveHelper.isMobile(context) ? Dimensions.paddingLarge : Dimensions.paddingSmall),

                        InkWell(
                          onTap: ()=> _actionOnBackButton(),
                          child: Padding(padding: EdgeInsets.only(right: Dimensions.paddingLarge),
                            child:  const Icon(Icons.arrow_back, size: 20,)),
                        ),

                        Expanded(child: Container(
                          width: double.infinity, height: 36,
                          padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
                          decoration: BoxDecoration(
                            color: context.surfaceContainer,
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            border: Border.all(color: context.outlineVariant),
                          ),
                          child: Row(children: [
                            CustomInkWellWidget(
                              onTap: ()=> _actionSearch(context, searchController, false),
                              child: CustomAssetImageWidget(Images.search, height: 16, color: Theme.of(context).textTheme.bodyLarge?.color,),
                            ),
                            SizedBox(width: Dimensions.paddingSmall),
                            
                            if(!searchController.isSearchMode && searchController.isNearMe) Container(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: 4),
                              margin: const EdgeInsets.only(right: Dimensions.paddingSmall),
                              decoration: BoxDecoration(
                                color: context.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                                border: Border.all(color: context.primary),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Text('near_me'.tr,
                                  style: context.heading.large.copyWith(color: context.primary, fontSize: Dimensions.fontSizeDefault),
                                ),
                                const SizedBox(width: 4),
                                InkWell(
                                  onTap: () => searchController.searchAllData(searchController.searchText, nearMe: false),
                                  child: Icon(Icons.close, size: 16, color: context.primary),
                                ),
                              ]),
                            ),

                            Expanded(child: SearchFieldWidget(
                              controller: _searchTextEditingController,
                              hint: 'search_food_or_restaurant'.tr,
                              onChanged: (value) {_searchSuggestions(value);},
                              onSubmit: (value) {
                                _actionSearch(context, searchController, true);
                                if(!searchController.isSearchMode && _searchTextEditingController.text.isEmpty) {
                                  searchController.setSearchMode(true);
                                }
                              },
                            )),

                            searchController.isSearchMode ? CustomIconButton(
                              onPressed: () async {
                                await VoicePermissionHandler.openVoiceSearch(
                                  context: context,
                                  searchTextEditingController: _searchTextEditingController,
                                );
                              },
                              icon: Icons.keyboard_voice_sharp,
                              size: 22, color: context.iconBaseMedium,
                            ) : CustomIconButton(
                              onPressed: () {
                                _searchTextEditingController.clear();
                                _actionOnBackButton();
                              },
                              icon: Icons.close, size: 20, color: context.textBaseDefault
                            ),
                          ]),
                        )),
                        SizedBox(width: Dimensions.paddingLarge),
                      ])),
                  ),

                  GetBuilder<CartController>(builder: (cartController) {
                    return Expanded(child: Stack(children: [
                      Column(children: [
                        if(!searchController.isSearchMode) ...[
                          Row(children: [
                            Expanded(
                              child: Container(
                                color: context.surfaceContainer,
                                child: TabBar(
                                  controller: _tabController,
                                  isScrollable: true,
                                  tabAlignment: TabAlignment.start,
                                  indicatorColor: context.textBaseDefault,
                                  indicatorWeight: 3,
                                  labelColor: context.textBaseDefault,
                                  unselectedLabelColor: context.textBaseMedium,
                                  unselectedLabelStyle: context.heading.defaultSize.copyWith(color: context.textBaseMedium),
                                  labelStyle: context.heading.defaultSize,
                                  labelPadding: const EdgeInsets.symmetric(),
                                  indicatorPadding: EdgeInsetsGeometry.only(right: Dimensions.paddingExtraSmall, left: Dimensions.paddingExtraSmall),
                                  splashBorderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                                  overlayColor: WidgetStateProperty.all(context.primary.withValues(alpha: 0.1)),
                                  tabs: [
                                    Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
                                      child: Tab(text: 'all'.tr),
                                    ),
                                    Padding(padding: const EdgeInsets.only(right: Dimensions.paddingSmall, left: Dimensions.paddingSmall),
                                      child: Tab(text: 'food'.tr),
                                    ),
                                    Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
                                      child: Tab(text: 'restaurants'.tr),
                                    ),
                                  ]
                                ),
                              ),
                            ),
                            Container(
                              color: context.surfaceContainer,
                              child: CustomIconButton(
                                onPressed: (){_actionSearch(context, searchController, false);},
                                image:Images.sortIcon, size: 20,
                              ),
                            ),
                            SizedBox(width: Dimensions.paddingDefault)
                          ]),
                        ],
                        if(searchController.isSearchMode) SizedBox(height: Dimensions.paddingMedium),
                        Divider(color: context.outlineVariant, height: 1),

                        Expanded(child:
                          searchController.isSearchMode ?
                              _SearchInitialView(
                                  searchController: searchController, searchTextEditingController: _searchTextEditingController,
                                  scrollController: scrollController, isLoggedIn: _isLoggedIn, historyDisplayCount: _historyDisplayCount,
                                  onHistoryDisplayCountChanged: (count) => setState(() => _historyDisplayCount = count),
                                  cuisineShimmerMinElapsed: _cuisineShimmerMinElapsed,
                                )
                            :  SearchResultView(
                                searchText: _searchTextEditingController.text.trim(),
                                tabController: _tabController,
                              ),
                        ),
                      ]),

                      if(_showSuggestion) Positioned.fill(
                        child: _SearchSuggestionView(searchController: searchController,
                            foodsAndRestaurants: _foodsAndRestaurants,
                            searchTextEditingController: _searchTextEditingController,
                            isAddToCartCart: cartController.cartBundleList.isNotEmpty,
                            onSearchTriggered: () => setState(() => _showSuggestion = false),
                          ),
                      ),
                    ]));
                  })
              ]),
              GetBuilder<CartController>(builder: (cartController) {
                return AnimatedBuilder(
                  animation: scrollController,
                  builder: (context, child) {
                    return cartController.cartBundleList.isNotEmpty
                        ? const BottomCartWidget(showGlobalCardWise: true)
                        : const SizedBox();
                  },
                );
              }),
            ],
          );
        })),
      ),
    );
  }

  void _actionSearch(BuildContext context, search.SearchController searchController, bool isSubmit) {
    if(searchController.isSearchMode || isSubmit) {
      if(_searchTextEditingController.text.trim().isNotEmpty) {
        setState(() => _showSuggestion = false);
        searchController.searchAllData(_searchTextEditingController.text.trim(), nearMe: false);
      }else {
        showCustomSnackBar('search_food_or_restaurant'.tr);
      }
    } else {
      double? maxValue = searchController.upperValue > 0 ? searchController.upperValue : 1000;
      double? minValue = searchController.lowerValue;
      _showFilterBottomSheet(maxValue, minValue, _filterTarget);
    }
  }

  SearchFilterTarget get _filterTarget => switch(_tabController.index) {
    1 => SearchFilterTarget.food,
    2 => SearchFilterTarget.restaurant,
    _ => SearchFilterTarget.both,
  };

  void _showFilterBottomSheet(double? maxValue, double? minValue, SearchFilterTarget target) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusLarge), topRight: Radius.circular(Dimensions.radiusLarge)),
      ),
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 1),
        child: FilterWidget(maxValue: maxValue, minValue: minValue, target: target, startFullScreen: true),
      ),
    );
  }

}
