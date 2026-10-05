import 'package:flutter/gestures.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CheckoutCondition extends StatelessWidget {
  const CheckoutCondition({super.key});

  @override
  Widget build(BuildContext context) {

    bool activeRefund = Get.find<SplashController>().configModel!.refundPolicyStatus!;

    return Container(
      padding: EdgeInsets.all(Dimensions.paddingMedium),
      decoration: BoxDecoration(
        color: context.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault-2)
      ),
      child: Row(children: [
        Expanded(
          child: RichText(text: TextSpan(children: [
            TextSpan(
              text: '${'i_have_read_and_agreed_with'.tr} ',
              style: context.body.defaultSize.regular.overrideWith(color: context.textBaseDefault),
            ),
            TextSpan(
              text: 'privacy_policy'.tr, style: context.subHeading.defaultSize.medium.overrideWith(color: context.primary),
              recognizer: TapGestureRecognizer()
                ..onTap = () => Get.toNamed(RouteHelper.getPrivacyPolicyRoute()),
            ),
            activeRefund ? TextSpan(
              text: ', ',
              style: context.body.defaultSize.regular.overrideWith(color: context.textBaseDefault),
            ) : TextSpan(
              text: ' ${'and'.tr} ',
              style: context.body.defaultSize.regular.overrideWith(color: context.textBaseDefault),
            ),
            TextSpan(
              text: 'terms_conditions'.tr, style: context.subHeading.defaultSize.medium.overrideWith(color: context.primary),
              recognizer: TapGestureRecognizer()
                ..onTap = () => Get.toNamed(RouteHelper.getTermsAndConditionRoute()),
            ),
            activeRefund ? TextSpan(text: ' ${'and'.tr} ', style: context.subHeading.defaultSize.regular) : const TextSpan(),
      
            activeRefund ? TextSpan(
              text: 'refund_policy'.tr, style: context.subHeading.defaultSize.medium.overrideWith(color: context.primary),
              recognizer: TapGestureRecognizer()
                ..onTap = () => Get.toNamed(RouteHelper.getRefundPolicyRoute()),
            ) : const TextSpan(),
          ]), textAlign: TextAlign.start, maxLines: 3),
        ),
      ]),
    );
  }
}
