import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class ProRenewBottomSheetWidget extends StatelessWidget {
  const ProRenewBottomSheetWidget({super.key});

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
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: Dimensions.paddingSmall),
          Row(
            children: [
              const SizedBox(width: 48),
              Expanded(
                child: Center(
                  child: isDesktop ? const SizedBox() : Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: context.bgNeutralMedium,
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.close, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
            ],
          ),
          const Text('🔔', style: TextStyle(fontSize: 60)),
          const SizedBox(height: Dimensions.paddingLarge),
          Text(
            'renew_your_subscription'.tr,
            style: context.heading.extraLarge.strong,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.paddingSmall),
          Text(
            'renew_subscription_message'.tr,
            style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.paddingExtraLarge),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.back();
                Get.toNamed(RouteHelper.getSubscriptionPlanRoute());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingDefault),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)),
                elevation: 0,
              ),
              child: Text('renew_subscription'.tr, style: context.heading.defaultSize.strong.overrideWith(color: Colors.white)),
            ),
          ),
          const SizedBox(height: Dimensions.paddingExtraLarge),
        ],
      ),
    );
  }
}
