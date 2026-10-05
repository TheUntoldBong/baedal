import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/vertical_food_card_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/home_section_header_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/item_card_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/section_view_all_tile.dart';
import 'package:stackfood_multivendor/features/review/controllers/review_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

class ItemYouWillLoveSection extends StatelessWidget {
  const ItemYouWillLoveSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReviewController>(builder: (reviewController) {
      final reviewedProducts = reviewController.reviewedProductList;
      if (reviewedProducts != null && reviewedProducts.isEmpty) {
        return const SizedBox.shrink();
      }

      final bool isTab = ResponsiveHelper.isTab(context);
      final double cardImage = isTab ? 200.0 : (MediaQuery.sizeOf(context).width * 0.35).clamp(100.0, double.infinity);
      final double textScale = MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 1.25);
      final double cardHeight = cardImage + 110.0 * textScale;

      return Container(
        padding: const EdgeInsets.only(bottom: Dimensions.paddingLarge),
        width: Dimensions.webMaxWidth,
        color: context.surfaceContainer,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

          HomeSectionHeaderWidget(name: 'item_you_will_love'),
          const SizedBox(height: Dimensions.paddingMedium),

          reviewedProducts != null ? SizedBox(
            height: cardHeight,
            child: ListView.builder(
              itemCount: reviewedProducts.length + 1,
              padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                if (index == reviewedProducts.length) {
                  return SectionViewAllTile(onTap: () => Get.toNamed(RouteHelper.getItemYouWillLoveRoute()));
                }
                return Padding(
                  padding: EdgeInsets.only(right: Dimensions.paddingMedium),
                  child: VerticalFoodCardWidget(
                    isCampaign: false,
                    product: reviewedProducts[index],
                    width: isTab ? 200 : null,
                  ),
                );
              },
            ),
          ) : const ItemCardShimmer(isPopularNearbyItem: false),

        ]),
      );
    });
  }
}

