import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ExtraDiscountViewWidget extends StatelessWidget {
  final double extraDiscount;
  const ExtraDiscountViewWidget({super.key, required this.extraDiscount});

  @override
  Widget build(BuildContext context) {
    return (extraDiscount > 0) ? Container(
      color: context.primary.withValues(alpha: 0.1),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomAssetImageWidget(Images.enjoyIcon, height: 20, width: 20),
          const SizedBox(width: Dimensions.paddingSmall),

          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(children: [
              TextSpan(text: 'you_got'.tr, style: context.subHeading.defaultSize.regular),
              const TextSpan(text: ' '),

              TextSpan(text: PriceConverter.convertPrice(extraDiscount), style: context.heading.defaultSize.strong.overrideWith(color: context.textBaseDefault)),
              const TextSpan(text: ' '),

              TextSpan(
                text: 'additional_discount'.tr,
                style: context.subHeading.defaultSize.regular,
              ),
            ]),
          ),
        ],
      ),
    ) : const SizedBox();
  }
}
