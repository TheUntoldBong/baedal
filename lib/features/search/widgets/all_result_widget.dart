
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/restaurant_card_widget.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:stackfood_multivendor/common/widgets/section_empty_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/restaurant_and_items_widget.dart';
import 'package:stackfood_multivendor/common/widgets/vertical_food_card_widget.dart';
import 'package:stackfood_multivendor/features/search/controllers/search_controller.dart' as search;
import 'package:stackfood_multivendor/features/search/widgets/search_result_count_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class AllResultWidget extends StatelessWidget {
  final ScrollController scrollController;
  final TabController tabController;
  final VoidCallback? onSeeAllFood;
  const AllResultWidget({super.key, required this.scrollController, required this.tabController, this.onSeeAllFood});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceContainer,
      body: GetBuilder<search.SearchController>(builder: (searchController) {
        bool isLoading = searchController.searchProductList == null || searchController.searchRestList == null;
        bool isEmpty = !isLoading && searchController.searchProductList!.isEmpty && searchController.searchRestList!.isEmpty;

        bool exclusiveDealsLoading = searchController.exclusiveDealsModel == null;
        List<Restaurant> exclusiveDeals = searchController.exclusiveDealsModel?.restaurants ?? [];

        if(isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if(isEmpty && !exclusiveDealsLoading && exclusiveDeals.isEmpty) {
          return NoDataScreen(isEmptySearchFood: true, title: 'no_food_found'.tr);
        }

        return SingleChildScrollView(
          controller: scrollController,
          child: SizedBox(
            child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingDefault),
                child: SearchResultCountWidget(tabController: tabController),
              ),

              Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                child: Text('food'.tr, style: context.heading.extraLarge),
              ),
              const SizedBox(height: Dimensions.paddingDefault),

              if(searchController.searchProductList!.isEmpty)
                SectionEmptyViewWidget(image: Images.emptyFood, message: 'no_food_found'.tr)
              else ...[
                SizedBox(
                  height: ResponsiveHelper.isMobile(context) ? 250 : 330,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if(notification.metrics.pixels >= notification.metrics.maxScrollExtent - 100) {
                        searchController.loadMoreSearchedFoods();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                      itemCount: searchController.searchProductList!.length + (searchController.allFoodPaginate ? 1 : 0),
                      itemBuilder: (context, index) {
                        if(index >= searchController.searchProductList!.length) {
                          return const Padding(
                            padding: EdgeInsets.only(right: Dimensions.paddingDefault),
                            child: SizedBox(width: 40, child: Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)))),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: Dimensions.paddingDefault),
                          child: VerticalFoodCardWidget(
                            width: ResponsiveHelper.isMobile(context) ? 130 : 200,
                            product: searchController.searchProductList![index],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],

              if(exclusiveDealsLoading || exclusiveDeals.isNotEmpty)
                Container(
                  color: context.surface,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const SizedBox(height: Dimensions.paddingLarge),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                      child: exclusiveDealsLoading
                          ? Shimmer(child: Container(width: 150, height: 20, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall), color: Theme.of(context).shadowColor)))
                          : Text('exclusive_deals'.tr, style: context.heading.extraLarge),
                    ),
                    const SizedBox(height: Dimensions.paddingDefault),

                    exclusiveDealsLoading ? SizedBox(
                      height: 227,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                        itemCount: 3,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(right: Dimensions.paddingDefault),
                          child: SizedBox(width: 280,
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Shimmer(child: Container(width: 280, height: 140, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), color: Theme.of(context).shadowColor))),
                              const SizedBox(height: Dimensions.paddingSmall),
                              Shimmer(child: Container(width: 180, height: 12, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall), color: Theme.of(context).shadowColor))),
                              const SizedBox(height: Dimensions.paddingExtraSmall),
                              Shimmer(child: Container(width: 120, height: 10, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall), color: Theme.of(context).shadowColor))),
                            ]),
                          ),
                        ),
                      ),
                    ) : SizedBox(
                      height: 227,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if(notification.metrics.pixels >= notification.metrics.maxScrollExtent - 100) {
                            searchController.loadMoreExclusiveDeals();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                          itemCount: exclusiveDeals.length + (searchController.exclusiveDealsPaginate ? 1 : 0),
                          itemBuilder: (context, index) {
                            if(index >= exclusiveDeals.length) {
                              return const Padding(
                                padding: EdgeInsets.only(right: Dimensions.paddingDefault),
                                child: SizedBox(width: 40, child: Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)))),
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.only(right: Dimensions.paddingDefault),
                              child: RestaurantCardWidget.detailed(restaurant: exclusiveDeals[index], width: 280),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingLarge),
                  ]),
                ),

              const SizedBox(height: Dimensions.paddingLarge),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                child: Text('restaurants'.tr, style: context.heading.extraLarge)
              ),
              const SizedBox(height: Dimensions.paddingLarge),

              if(searchController.searchRestList!.isEmpty)
                SectionEmptyViewWidget(image: Images.emptyRestaurant, message: 'no_restaurant_found'.tr)
              else
                _RestaurantGrid(restaurants: searchController.searchRestList!),

              const SizedBox(height: 20),
            ]))),
          ),
        );
      }),
    );
  }
}


class _RestaurantGrid extends StatelessWidget {
  final List<Restaurant> restaurants;
  const _RestaurantGrid({required this.restaurants});

  @override
  Widget build(BuildContext context) {
    final int crossAxisCount = ResponsiveHelper.isTab(context) ? 2 : 1;
    final int rowCount = (restaurants.length / crossAxisCount).ceil();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for(int row = 0; row < rowCount; row++) ...[

        if(row > 0) const Padding(
          padding: EdgeInsets.symmetric(vertical: Dimensions.paddingLarge),
          child: Divider(height: 1, thickness: 1),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for(int column = 0; column < crossAxisCount; column++) ...[
              if(column > 0) const SizedBox(width: Dimensions.paddingDefault),
              Expanded(child: Builder(builder: (context) {
                final int index = (row * crossAxisCount) + column;
                if(index >= restaurants.length) return const SizedBox();

                return RestaurantAndItemsWidget(
                  restaurant: restaurants[index],
                  restaurantHeaderPadding: EdgeInsets.zero,
                  itemHorizontalPadding: EdgeInsets.zero,
                );
              })),
            ],
          ]),
        ),

      ],
    ]);
  }
}
