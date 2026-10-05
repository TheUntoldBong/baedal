import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class DineInWidget extends StatelessWidget {
  const DineInWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final bool isMobile = ResponsiveHelper.isMobile(context);
    final double iconSize = isMobile ? 48 : 60;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
      child: InkWell(
        onTap: () => Get.toNamed(RouteHelper.getDineInRestaurantScreen()),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.paddingMedium,
            vertical: isMobile ? Dimensions.paddingMedium : Dimensions.paddingDefault,
          ),
          decoration: BoxDecoration(
            color: context.bgWarningMedium,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          child: Row(children: [

            CustomAssetImageWidget(Images.dineInTable, height: iconSize, width: iconSize, fit: BoxFit.contain),
            const SizedBox(width: Dimensions.paddingMedium),

            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                Text(
                  'want_to_dine_in'.tr,
                  style: (isMobile ? context.heading.large : context.heading.extraLarge).overrideWith(color: context.textBaseDefault),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Dimensions.padding2xSmall),

                Text(
                  'visit_the_restaurant_and_enjoy_your_meal'.tr,
                  style: (isMobile ? context.subHeading.small : context.subHeading.defaultSize).overrideWith(color: context.textBaseMedium),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                ),

              ]),
            ),
            const SizedBox(width: Dimensions.paddingSmall),

            Icon(
              isRtl ? Icons.arrow_back_ios_rounded : Icons.arrow_forward_ios_rounded,
              size: isMobile ? 18 : 22, color: context.primary,
            ),

          ]),
        ),
      ),
    );
  }
}
