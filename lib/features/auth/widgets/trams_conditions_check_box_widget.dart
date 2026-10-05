import 'package:flutter/gestures.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/auth/controllers/deliveryman_registration_controller.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class TramsConditionsCheckBoxWidget extends StatelessWidget {
  final AuthController? authController;
  final bool fromDmRegistration;
  final DeliverymanRegistrationController? deliverymanRegistrationController;
  final bool fromSignUp;
  final bool fromDialog;
  const TramsConditionsCheckBoxWidget({super.key, this.authController,  this.fromSignUp = false, this.fromDialog = false,
    this.fromDmRegistration = false, this.deliverymanRegistrationController});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment:  MainAxisAlignment.start , children: [

      fromSignUp || fromDmRegistration ? Checkbox(
        side: BorderSide(color: context.outlineVariant, width: 1.5),
        activeColor: context.primary,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        value: fromDmRegistration ? deliverymanRegistrationController?.acceptTerms : authController?.acceptTerms,
        onChanged: (bool? isChecked) => fromDmRegistration ? deliverymanRegistrationController?.toggleTerms() : authController?.toggleTerms(),
      ) : const SizedBox(),

      SizedBox(width: Dimensions.paddingSmall),
      Flexible(
        child: RichText(textAlign: TextAlign.start,
          text: TextSpan(children: [
            TextSpan(
              text: 'I_ve_read_and_agree_to_the'.tr,
              style: context.body.small.overrideWith(color: context.textBaseMedium),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: 'privacy_policy'.tr,
              style: context.body.small.overrideWith(color: Theme.of(context).textTheme.bodyLarge?.color),
              recognizer: TapGestureRecognizer()..onTap = () => Get.toNamed(RouteHelper.privacyPolicy),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: 'terms_and_conditions'.tr,
              style: context.body.small.overrideWith(color: Theme.of(context).textTheme.bodyLarge?.color),
              recognizer: TapGestureRecognizer()..onTap = () => Get.toNamed(RouteHelper.termsAndCondition),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: 'and'.tr,
              style: context.body.small.overrideWith(color: context.textBaseMedium),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: 'refund_policy'.tr,
              style: context.body.small.overrideWith(color: Theme.of(context).textTheme.bodyLarge?.color),
              recognizer: TapGestureRecognizer()..onTap = () => Get.toNamed(RouteHelper.refundPolicy),
            ),

          ]),
        ),
      ),

    ]);
  }
}
