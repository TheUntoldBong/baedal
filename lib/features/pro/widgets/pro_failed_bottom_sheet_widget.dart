import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class ProFailedBottomSheetWidget extends StatelessWidget {
  const ProFailedBottomSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      width: isDesktop ? 450 : MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(Dimensions.radiusExtraLarge),
          topRight: const Radius.circular(Dimensions.radiusExtraLarge),
          bottomLeft: Radius.circular(isDesktop ? Dimensions.radiusExtraLarge : 0),
          bottomRight: Radius.circular(isDesktop ? Dimensions.radiusExtraLarge : 0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: Dimensions.paddingSmall),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () => Get.back(),
              icon: Icon(Icons.close, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingDefault),
            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            child: const Icon(Icons.priority_high, size: 40, color: Colors.white),
          ),
          const SizedBox(height: Dimensions.paddingLarge),
          Text(
            'payment_failed'.tr,
            style: context.heading.extraLarge.strong,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.paddingSmall),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingExtraLarge),
            child: Text(
              'pro_payment_failed_message'.tr,
              style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: Dimensions.paddingExtraLarge),
        ],
      ),
    );
  }
}
