import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/horizontal_food_card_widget.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_shimmer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/restaurant_card_widget.dart';
import 'package:stackfood_multivendor/features/search/controllers/search_controller.dart' as search;
import 'package:stackfood_multivendor/features/search/widgets/search_result_count_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

const double _restaurantCardDetailsHeight = 95;

class ItemViewWidget extends StatelessWidget {
  final bool isRestaurant;
  final ScrollController scrollController;
  final TabController tabController;
  const ItemViewWidget({super.key, required this.isRestaurant, required this.scrollController, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceContainer,
      body: GetBuilder<search.SearchController>(builder: (searchController) {
        bool isNull = isRestaurant ? searchController.searchRestList == null : searchController.searchProductList == null;
        int length = isRestaurant ? (searchController.searchRestList?.length ?? 0) : (searchController.searchProductList?.length ?? 0);

        return SingleChildScrollView(
          controller: scrollController,
          child: SizedBox(
            child: Center(child: SizedBox(width: Dimensions.webMaxWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                child: Column(
                  children: [
                    SizedBox(height: Dimensions.paddingDefault,),
                    SearchResultCountWidget(tabController: tabController),
                    SizedBox(height: Dimensions.paddingDefault,),

                    if(isNull)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 6,
                        itemBuilder: (context, index) => ProductShimmer(isEnabled: true, isRestaurant: isRestaurant, hasDivider: index != 5),
                      )
                    else if(length == 0)
                      NoDataScreen(
                        isEmptyRestaurant: isRestaurant,
                        isEmptySearchFood: !isRestaurant,
                        title: isRestaurant ? 'no_restaurant_found'.tr : 'no_food_found'.tr,
                      )
                    else if(isRestaurant)
                      LayoutBuilder(builder: (context, constraints) {
                        final int crossAxisCount = ResponsiveHelper.isTab(context) ? 2 : 1;
                        final double tileWidth = (constraints.maxWidth - (Dimensions.paddingDefault * (crossAxisCount - 1))) / crossAxisCount;

                        return GridView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: Dimensions.paddingLarge,
                            crossAxisSpacing: Dimensions.paddingDefault,
                            mainAxisExtent: (tileWidth / 2) + _restaurantCardDetailsHeight,
                          ),
                          itemBuilder: (context, index) => RestaurantCardWidget.detailed(
                            restaurant: searchController.searchRestList![index],
                          ),
                        );
                      })
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: length,
                        separatorBuilder: (context, index) => Divider(color: context.outline, height: Dimensions.paddingSizeExtraOverLarge, thickness: 1),
                        itemBuilder: (context, index) {
                          return HorizontalFoodCardWidget(
                            padding: EdgeInsets.zero,
                            product: searchController.searchProductList![index], restaurant: null, index: index, length: length,
                          );
                        },
                      ),

                    searchController.paginate ? Center(child: Padding(
                      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraOverLarge),
                      child: CircularProgressIndicator(),
                    )) : const SizedBox(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            )),
          ),
        );
      }),
    );
  }
}
