import 'package:stackfood_multivendor/common/widgets/section_divider_header_widget.dart';
import 'package:stackfood_multivendor/common/widgets/restaurant_card_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/quick_delivery_bolt_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/section_view_all_tile.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class QuickDeliveryWidget extends StatelessWidget {
  final EdgeInsets? padding;
  const QuickDeliveryWidget({super.key, this.padding});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restController) {
      final restaurants = restController.quickDeliveryRestaurantList;
      if (restaurants == null || restaurants.isEmpty) {
        return const SizedBox.shrink();
      }

      final double screenWidth = MediaQuery.of(context).size.width;
      final double cardWidth = (screenWidth * 0.72).clamp(240.0, 300.0);
      final double cardHeight = (cardWidth / 2) + 64;

      return Container(
        padding: padding ?? const EdgeInsets.only(top: Dimensions.paddingDefault, bottom: Dimensions.paddingLarge),
        color: context.surfaceContainer,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionDividerHeaderWidget(child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text('quick'.tr, style: context.heading.extraLarge),
            const SizedBox(width: Dimensions.padding2xSmall),
            const QuickDeliveryBoltWidget(size: 20),
            const SizedBox(width: Dimensions.padding2xSmall),
            Text('delivery'.tr, style: context.heading.extraLarge),
          ])),
          const SizedBox(height: Dimensions.paddingMedium),

          SizedBox(
            height: cardHeight,
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
                    onTap: () => Get.toNamed(RouteHelper.getAllRestaurantRoute('quick_delivery')),
                  );
                }
                return RestaurantCardWidget(
                  restaurant: restaurants[index],
                  width: cardWidth,
                  isQuickDelivery: true,
                );
              },
            ),
          ),
        ]),
      );
    });
  }
}
