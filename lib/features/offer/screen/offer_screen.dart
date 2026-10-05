import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/horizontal_food_card_widget.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:stackfood_multivendor/common/widgets/restaurant_and_items_widget.dart';
import 'package:stackfood_multivendor/common/widgets/restaurant_card_widget.dart';
import 'package:stackfood_multivendor/common/widgets/section_empty_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/vertical_food_card_widget.dart';
import 'package:stackfood_multivendor/features/offer/controllers/offer_controller.dart';
import 'package:stackfood_multivendor/features/offer/widgets/offer_filter_widget.dart';
import 'package:stackfood_multivendor/theme/system_ui_style.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

part '../widgets/offer_header_delegate.dart';

class OfferScreen extends StatefulWidget {
  const OfferScreen({super.key, required this.title, required this.iconPath, this.isTopRated = false, this.isFreeDelivery = false});
  final String title;
  final String iconPath;
  final bool isTopRated;
  final bool isFreeDelivery;

  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  int _tabIndex = 0;
  bool _isSearchMode = false;
  final TextEditingController _searchTextController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Get.find<OfferController>().clearFilters(includeSearch: true);
    WidgetsBinding.instance.addPostFrameCallback((_){
      Get.find<OfferController>().getOffers(isTopRated: widget.isTopRated, isFreeDelivery: widget.isFreeDelivery);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchTextController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if(_scrollController.position.pixels < _scrollController.position.maxScrollExtent - 200) {
      return;
    }
    OfferController offerController = Get.find<OfferController>();
    if(_tabIndex == 0) {
      offerController.loadMoreFoodItems();
      offerController.loadMoreRestaurants();
    } else if(_tabIndex == 1) {
      offerController.loadMoreFoodItems();
    } else if(_tabIndex == 2) {
      offerController.loadMoreRestaurants();
    }
  }

  void _toggleSearchMode() {
    bool hadSearchText = Get.find<OfferController>().searchText.isNotEmpty;
    setState(() {
      _isSearchMode = !_isSearchMode;
      _searchTextController.clear();
    });
    if(_isSearchMode) {
      _searchFocusNode.requestFocus();
    } else {
      _searchFocusNode.unfocus();
      if(hadSearchText) {
        Get.find<OfferController>().setSearchText('');
      }
    }
  }

  Widget _foodListView(List<Product> foods, bool paginate) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingLarge),
      child: Column(children: [
        ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: foods.length,
          separatorBuilder: (context, index) => Divider(height: Dimensions.paddingDefault*2, thickness: 1),
          itemBuilder: (context, index) => HorizontalFoodCardWidget(
            padding: EdgeInsets.zero,
            product: foods[index], restaurant: null, index: index, length: foods.length,
            isTopRated: widget.isTopRated,
          ),
        ),
        if(paginate) Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingDefault),
          child: Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))),
        ),
      ]),
    );
  }

  Widget _restaurantListView(List<Restaurant> restaurants, bool paginate) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingLarge),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: restaurants.length,
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingDefault),
          child: Divider(height: 1, thickness: 1),
        ),
        itemBuilder: (context, index) => RestaurantCardWidget.detailed(restaurant: restaurants[index]),
      ),
    );
  }

  void _showFilterBottomSheet() {
    FocusManager.instance.primaryFocus?.unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 1),
        child: OfferFilterWidget(isRestaurantTab: _tabIndex == 2),
      ),
    );
  }

  double get _collapseProgress => _OfferHeaderDelegate.collapseProgress(_scrollController.hasClients ? _scrollController.offset : 0);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyleOf(context, statusBarColor: Colors.transparent),
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceContainer,
      body: Column(children: [

        AnimatedBuilder(
          animation: _scrollController,
          builder: (context, child) => Container(
            height: MediaQuery.of(context).padding.top,
            color: _OfferHeaderDelegate.backgroundColorAt(context, _collapseProgress),
          ),
        ),

        Expanded(child: SafeArea(top: false, child: GetBuilder<OfferController>(builder: (offerController) {
        List<Product> foods = offerController.foodList ?? [];
        List<Restaurant> restaurants = offerController.restaurantList ?? [];
        bool showFoods = _tabIndex != 2 && foods.isNotEmpty;
        bool showRestaurants = _tabIndex != 1 && restaurants.isNotEmpty;
        int resultCount = _tabIndex == 1 ? offerController.foodTotalSize
            : _tabIndex == 2 ? offerController.restaurantTotalSize
            : offerController.foodTotalSize + offerController.restaurantTotalSize;

        return CustomScrollView(controller: _scrollController, slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _OfferHeaderDelegate(
              title: widget.title,
              iconPath: widget.iconPath,
              resultCount: resultCount,
              tabIndex: _tabIndex,
              onTabChanged: (index) => setState(() => _tabIndex = index),
              isSearchMode: _isSearchMode,
              searchController: _searchTextController,
              searchFocusNode: _searchFocusNode,
              onSearchToggle: _toggleSearchMode,
              onSearchSubmit: (value) => offerController.setSearchText(value),
              onFilterTap: _showFilterBottomSheet,
              isLoading: offerController.isLoading,
            ),
          ),

          if(offerController.isLoading)
            const SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator()))
          else if(!showFoods && !showRestaurants)
            SliverFillRemaining(hasScrollBody: false, child: Center(child: NoDataScreen(title: 'no_offer_found'.tr)))
          else
            SliverToBoxAdapter(
              child: SizedBox(
                child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child:
                  _tabIndex == 1 ? _foodListView(foods, offerController.foodPaginate)
                  : _tabIndex == 2 ? _restaurantListView(restaurants, offerController.restaurantPaginate)
                  : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  const SizedBox(height: Dimensions.paddingLarge),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                    child: Text('foods'.tr, style: context.heading.extraLarge.strong),
                  ),
                  const SizedBox(height: Dimensions.paddingLarge),

                  if(foods.isEmpty)
                    SectionEmptyViewWidget(image: Images.emptyFood, message: 'no_food_found'.tr)
                  else ...[
                    NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if(notification.metrics.pixels >= notification.metrics.maxScrollExtent - 100) {
                          offerController.loadMoreFoodItems();
                        }
                        return false;
                      },
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...List.generate(foods.length, (index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    right: (index == foods.length - 1 && !offerController.foodPaginate) ? 0 : Dimensions.paddingMedium,
                                  ),
                                  child: VerticalFoodCardWidget(product: foods[index], isTopRated: widget.isTopRated),
                                );
                              }),
                              if(offerController.foodPaginate) const Padding(
                                padding: EdgeInsets.only(right: Dimensions.paddingDefault),
                                child: SizedBox(width: 40, child: Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)))),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: Dimensions.paddingExtraLarge),
                  Divider(height: 1, thickness: 2),
                  SizedBox(height: Dimensions.paddingLarge),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                    child: Text('restaurants'.tr, style: context.heading.extraLarge.strong),
                  ),
                  SizedBox(height: Dimensions.paddingLarge),

                  if(restaurants.isEmpty)
                    SectionEmptyViewWidget(image: Images.emptyRestaurant, message: 'no_restaurant_found'.tr)
                  else ...[
                    ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: restaurants.length,
                      separatorBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingLarge),
                        child: Divider(height: 1, thickness: 1),
                      ),
                      itemBuilder: (context, index) => RestaurantAndItemsWidget(restaurant: restaurants[index],
                        restaurantHeaderPadding: EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                        itemHorizontalPadding: EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                      ),
                    ),
                    if(offerController.restaurantPaginate) Padding(
                      padding: const EdgeInsets.only(top: Dimensions.paddingDefault),
                      child: Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                    ),
                  ],

                  const SizedBox(height: Dimensions.paddingOverLarge),
                ]))),
              ),
            ),
        ]);
      }))),

      ]),
    );
  }
}
