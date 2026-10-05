import 'package:stackfood_multivendor/common/widgets/restaurant_card_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/home_section_header_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/section_view_all_tile.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class TopPickNearYouWidget extends StatelessWidget {
  const TopPickNearYouWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restController) {
      final restaurants = restController.topPickRestaurantList;
      if (restaurants == null || restaurants.isEmpty) {
        return const SizedBox.shrink();
      }

      final double screenWidth = MediaQuery.of(context).size.width;
      final double cardWidth = (screenWidth * 0.72).clamp(240.0, 300.0);
      final double cardRatio = 2;
      final double contentHeight = 64;

      return Container(
        padding: const EdgeInsets.only(bottom: Dimensions.paddingLarge),
        color: context.surfaceContainer,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          HomeSectionHeaderWidget(name: "top_pick_near_you"),
          const SizedBox(height: Dimensions.paddingMedium),

          SizedBox(
            height: (cardWidth/cardRatio) + contentHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
              itemCount: restaurants.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: Dimensions.paddingMedium),
              itemBuilder: (context, index) {
                if (index == restaurants.length) {
                  return SectionViewAllTile(
                    leftPadding: Dimensions.paddingSmall,
                    onTap: () => Get.toNamed(RouteHelper.getAllRestaurantRoute('top_pick')),
                  );
                }
                return RestaurantCardWidget(
                  restaurant: restaurants[index],
                  width: cardWidth,
                  isTopPick: true,
                );
              },
            ),
          ),
        ]),
      );
    });
  }
}
