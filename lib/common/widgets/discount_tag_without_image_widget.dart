import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class DiscountTagWithoutImageWidget extends StatelessWidget {
  final double? discount;
  final String? discountType;
  final double fromTop;
  final double? fontSize;
  final bool? freeDelivery;
  const DiscountTagWithoutImageWidget({super.key,
    required this.discount, required this.discountType, this.fromTop = 10, this.fontSize, this.freeDelivery = false,
  });

  @override
  Widget build(BuildContext context) {
    return (discount! > 0 || freeDelivery!) ? Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
      ),
      child: Text(
        '(${discount! > 0 ? '$discount${discountType == 'percent' ? '%' : Get.find<SplashController>().configModel!.currencySymbol}${'off'.tr}' : 'free_delivery'.tr})',
        style: context.subHeading.small.strong.overrideWith(color: Colors.green).copyWith(
          fontSize: fontSize ?? (ResponsiveHelper.isMobile(context) ? 8 : 12),
        ),
        textAlign: TextAlign.center,
      ),
    ) : const SizedBox();
  }
}
