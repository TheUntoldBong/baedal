import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';

class PaymentButton extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final int index;
  const PaymentButton({super.key, required this.index, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(builder: (checkoutController) {
      bool selected = checkoutController.paymentMethodIndex == index;
      return Padding(
        padding: const EdgeInsets.only(right: Dimensions.paddingSmall, bottom:  Dimensions.paddingSmall),
        child: InkWell(
          onTap: () => checkoutController.setPaymentMethod(index),
          child: Container(
            width: 200, padding: const EdgeInsets.all(Dimensions.paddingDefault),
            decoration: BoxDecoration(
              color: context.surfaceContainer,
              borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
              border: Border.all(color: selected ? context.primary : context.outline, width: 1.5)
            ),
            child: Row(children: [
              CustomAssetImageWidget(
                icon, width: 20, height: 20,
                color: selected ? context.primary : context.iconBaseMedium,
              ),
              const SizedBox(width: Dimensions.paddingSmall),

              Text(title, style: context.subHeading.small.strong.overrideWith(color: selected ? context.primary : context.textBaseMedium)),

            ]),

          ),
        ),
      );
    });
  }
}
