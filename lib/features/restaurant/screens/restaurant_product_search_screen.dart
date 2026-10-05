import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/enums/veg_type.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/veg_filter_widget.dart';
import 'package:stackfood_multivendor/features/category/controllers/category_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/search/controllers/search_controller.dart' as search;
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class RestaurantProductSearchScreen extends StatefulWidget {
  final String? restaurantId;
  const RestaurantProductSearchScreen({super.key, required this.restaurantId});

  @override
  State<RestaurantProductSearchScreen> createState() => _RestaurantProductSearchScreenState();
}

class _RestaurantProductSearchScreenState extends State<RestaurantProductSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Get.find<RestaurantController>().initSearchData();
    Get.find<search.SearchController>().getHistoryList();
    Get.find<CategoryController>().getCategoryList(true, search: '');
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restaurantController) {
      return GetBuilder<search.SearchController>(builder: (searchController) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if(restaurantController.isSearching && !didPop){
              _searchController.text = '';
              restaurantController.changeSearchStatus();
              restaurantController.initSearchData();
            }else if(_searchController.text.isNotEmpty){
              _searchController.text = '';
              setState(() {});
            }else if(!didPop){
              Future.delayed(const Duration(milliseconds: 0), () => Get.back());
            }
          },
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size(Dimensions.webMaxWidth, 80),
              child: Container(
                height: 80 + context.mediaQueryPadding.top, width: Dimensions.webMaxWidth,
                padding: EdgeInsets.only(top: context.mediaQueryPadding.top),
                color: context.surfaceContainer,
                alignment: Alignment.center,
                child: SizedBox(width: Dimensions.webMaxWidth, child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.paddingSmall),
                  child: Row(children: [

                    IconButton(
                      onPressed: () {
                        if(restaurantController.isSearching){
                          _searchController.text = '';
                          restaurantController.changeSearchStatus();
                          restaurantController.initSearchData();
                        }else if(_searchController.text.isNotEmpty){
                          _searchController.text = '';
                          setState(() {});
                        }else {
                          Get.back();
                        }
                      },
                      icon: Icon(Icons.arrow_back, color: context.iconColor),
                    ),

                    Expanded(child: TextField(
                      controller: _searchController,
                      style: context.body.large.regular,
                      textInputAction: TextInputAction.search,
                      cursorColor: context.primary,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: 'search_item_in_store'.tr,
                        hintStyle: context.body.large.regular.overrideWith(color: context.textBaseMedium),
                        isDense: true,
                        contentPadding: const EdgeInsets.all(Dimensions.paddingSmall),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(color: context.primary.withValues(alpha: 0.3), width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(color: context.primary.withValues(alpha: 0.3), width: 1),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(CupertinoIcons.search, size: 25),
                          onPressed: () {
                            searchController.saveSearchHistory(_searchController.text.trim());
                            Get.find<RestaurantController>().getRestaurantSearchProductList(
                              _searchController.text.trim(), widget.restaurantId, 1, Get.find<RestaurantController>().searchType,
                            );
                          },
                        ),
                      ),
                      onSubmitted: (text) {
                        searchController.saveSearchHistory(_searchController.text.trim());
                        Get.find<RestaurantController>().getRestaurantSearchProductList(
                          _searchController.text.trim(), widget.restaurantId, 1, Get.find<RestaurantController>().searchType,
                        );
                      }
                    )),
                    if(restaurantController.isSearching) ...[
                      const SizedBox(width: Dimensions.paddingSmall),

                      VegFilterWidget(
                        type: restaurantController.searchText.isNotEmpty ? restaurantController.searchType : null,
                        onSelected: (VegType type) {
                          restaurantController.getRestaurantSearchProductList(restaurantController.searchText, widget.restaurantId, 1, type);
                        },
                        fromAppBar: true,
                      ),
                    ],

                  ]),
                )),
              ),
            ),

            body: SingleChildScrollView(
              controller: _scrollController,
              padding: ResponsiveHelper.isDesktop(context) ? null : const EdgeInsets.all(Dimensions.paddingSmall),
              child: Center(
                child: SizedBox(width: Dimensions.webMaxWidth, child: !restaurantController.isSearching ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: Dimensions.padding2xSmall),
                    searchController.historyList.isNotEmpty ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('recent_search'.tr, style: context.subHeading.large.medium),

                      InkWell(
                        onTap: () => searchController.clearSearchAddress(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall, horizontal: 4),
                          child: Text('clear_all'.tr, style: context.body.small.regular.overrideWith(color: context.error)),
                        ),
                      ),
                    ]) : const SizedBox(),

                    SizedBox(height: searchController.historyList.isNotEmpty ? Dimensions.padding2xSmall : 0),
                    Wrap(
                      children: searchController.historyList.asMap().entries.map((entry) {
                        Map<String, dynamic> historyData = entry.value;
                        String query = historyData['query'] ?? '';

                        return Padding(
                          padding: const EdgeInsets.only(right: Dimensions.paddingSmall, bottom: Dimensions.paddingSmall),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
                            decoration: BoxDecoration(
                              color: context.bgNeutralLight,
                              borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                              border: Border.all(color: context.outline),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              InkWell(
                                onTap: () {
                                  _searchController.text = query;
                                  searchController.saveSearchHistory(query);
                                  Get.find<RestaurantController>().getRestaurantSearchProductList(
                                    _searchController.text.trim(), widget.restaurantId, 1, Get.find<RestaurantController>().searchType,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: Dimensions.padding2xSmall),
                                  child: Text(
                                    query,
                                    style: context.body.defaultSize.regular.overrideWith(color: context.textBaseDefault.withValues(alpha: 0.5)),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(width: Dimensions.paddingSmall),

                              InkWell(
                                onTap: () => searchController.removeHistory(historyData),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: Dimensions.padding2xSmall),
                                  child: Icon(Icons.close, color: context.iconBaseMedium, size: 20),
                                ),
                              )
                            ]),
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: searchController.historyList.isNotEmpty && restaurantController.categoryList != null ? Dimensions.paddingLarge : 0),

                    (restaurantController.categoryList != null) ? Padding(
                      padding: const EdgeInsets.only(bottom: Dimensions.paddingDefault),
                      child: Text(
                        'popular_categories'.tr, style: context.subHeading.large.medium,
                      ),
                    ) : const SizedBox(),

                    (restaurantController.categoryList != null) ? restaurantController.categoryList!.isNotEmpty ?  Wrap(
                      children: restaurantController.categoryList!.map((category) {
                        return category.name != 'All' ? Padding(
                          padding: const EdgeInsets.only(right: Dimensions.paddingSmall, bottom: Dimensions.paddingSmall),
                          child: InkWell(
                            onTap: () {
                              _searchController.text = category.name!;
                              searchController.saveSearchHistory(category.name!);
                              Get.find<RestaurantController>().getRestaurantSearchProductList(
                                _searchController.text.trim(), widget.restaurantId, 1, Get.find<RestaurantController>().searchType,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.paddingSmall),
                              decoration: BoxDecoration(
                                color: context.surfaceContainer,
                                borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                                border: Border.all(color: context.outline),
                              ),
                              child: Text(
                                category.name!,
                                style: context.subHeading.small.medium,
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ) : const SizedBox();
                      }).toList(),
                    ) : Padding(padding: const EdgeInsets.only(top: 10), child: Text('no_suggestions_available'.tr)) : const SizedBox(),
                  ]) : PaginatedListViewWidget(
                    scrollController: _scrollController,
                    onPaginate: (int? offset) => restaurantController.getRestaurantSearchProductList(
                      restaurantController.searchText, widget.restaurantId, offset!, restaurantController.searchType,
                    ),
                    totalSize: restaurantController.restaurantSearchProductModel?.totalSize,
                    offset: restaurantController.restaurantSearchProductModel != null ? restaurantController.restaurantSearchProductModel!.offset : 1,
                    productView: ProductViewWidget(
                      isRestaurant: false, restaurants: null,
                      products: restaurantController.restaurantSearchProductModel?.products,
                      inRestaurantPage: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      });
    });
  }
}
