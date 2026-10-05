import 'package:stackfood_multivendor/common/widgets/restaurant_card_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/home_section_header_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/section_view_all_tile.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class RecentlyViewedRestaurantsViewWidget extends StatelessWidget {
  const RecentlyViewedRestaurantsViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restController) {
      List<Restaurant>? restaurantList = restController.recentlyViewedRestaurantList;
      if(restaurantList != null && restaurantList.isEmpty) return const SizedBox.shrink();

      final double screenWidth = MediaQuery.of(context).size.width;
      final double cardWidth = (screenWidth * 0.72).clamp(240.0, 300.0);
      final double cardRatio = 2;
      final double contentHeight = 64;

      return Padding(
        padding: const EdgeInsets.only(bottom: Dimensions.paddingLarge),
        child: SizedBox(
        width: Dimensions.webMaxWidth,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Padding(
            padding: EdgeInsets.only(bottom: Dimensions.paddingMedium),
            child: HomeSectionHeaderWidget(name: 'recently_viewed_restaurants'.tr),
          ),

          restaurantList != null ? SizedBox(
            height: (cardWidth/cardRatio) + contentHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
              itemCount: restaurantList.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: Dimensions.paddingMedium),
              itemBuilder: (context, index) {
                if (index == restaurantList.length) {
                  return SectionViewAllTile(
                    leftPadding: Dimensions.paddingSmall,
                    onTap: () => Get.toNamed(RouteHelper.getAllRestaurantRoute('recently_viewed')),
                  );
                }
                return RestaurantCardWidget(
                  restaurant: restaurantList[index],
                  width: cardWidth,
                );
              },
            ),
          ) : SizedBox(
            height: (cardWidth/cardRatio) + contentHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
              itemCount: 3,
              separatorBuilder: (context, index) => const SizedBox(width: Dimensions.paddingMedium),
              itemBuilder: (context, index) => RestaurantCardShimmerWidget(width: cardWidth),
            ),
          ),

        ]),
      ),
      );
    });
  }
}


