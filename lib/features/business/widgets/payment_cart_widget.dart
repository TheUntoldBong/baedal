import 'package:stackfood_multivendor/features/business/controllers/business_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class PaymentCartWidget extends StatelessWidget {
  final String title;
  final int index;
  final Function onTap;
  const PaymentCartWidget({super.key, required this.title, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessController>(builder: (businessController) {
      return Stack( clipBehavior: Clip.none, children: [

        InkWell(
          onTap: onTap as void Function()?,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: businessController.paymentIndex == index ? Border.all(color: context.primary, width: 1) : null,
              boxShadow: businessController.paymentIndex != index ? [BoxShadow(color: context.shadow, blurRadius: 10)] : null,
              color: businessController.paymentIndex == index ? context.primary.withValues(alpha: 0.05) : context.surfaceContainer,
            ),
            alignment: Alignment.centerLeft,
            width: context.width,
            padding: const EdgeInsets.all(Dimensions.paddingLarge),
            child: Row(children: [
              Text(title, style: context.subHeading.defaultSize.strong.overrideWith(color: businessController.paymentIndex == index ? context.primary : Theme.of(context).textTheme.bodyLarge!.color)),
              const Spacer(),

              (ResponsiveHelper.isDesktop(context) && businessController.paymentIndex == index) ? Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(color: context.primary, shape: BoxShape.circle),
                child: Icon(Icons.check, size: 18, color: context.surfaceContainer),
              ) : const SizedBox(),
            ]),
          ),
        ),

        (ResponsiveHelper.isMobile(context) && businessController.paymentIndex == index)  ? Positioned(
          top: -8, right: -8,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(color: context.primary, shape: BoxShape.circle),
            child: Icon(Icons.check, size: 18, color: context.surfaceContainer),
          ),
        ) : const SizedBox(),

      ]);
    });
  }
}

