import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class VerificationBottomSheet extends StatelessWidget {
  final bool isEmail;
  final Function()? onTap;
  const VerificationBottomSheet({super.key, this.isEmail = true, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      padding: const EdgeInsets.all(Dimensions.paddingSmall),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? Theme.of(context).scaffoldBackgroundColor : context.surfaceContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge),
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        Container(
          height: 5, width: 40,
          decoration: BoxDecoration(
            color: context.bgNeutralMedium,
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
          ),
        ),

        Align(
          alignment: Alignment.topRight,
          child: InkWell(
            onTap: () {
              Get.back();
            },
            child: Icon(Icons.close, color: context.iconDisabledDefault),
          ),
        ),

        CustomAssetImageWidget(
          Images.verificationIcon, height: 60, width: 60,
        ),
        const SizedBox(height: Dimensions.paddingLarge),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Text(
            isEmail ? 'verify_your_email'.tr : 'verify_your_phone_number'.tr,
            style: context.heading.large.semiBold, textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSmall),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
          child: Text(
            isEmail ? 'we_will_send_you_a_one_time_code_to_confirm_your_email'.tr : 'we_will_send_you_a_one_time_code_to_confirm_your_phone_number'.tr,
            style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium), textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 50),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
          child: Row(children: [
            Expanded(
              child: CustomButtonWidget(
                isBold: false,
                fontSize: Dimensions.fontSizeDefault,
                onPressed: () {
                  Get.back();
                },
                buttonText: 'cancel'.tr,
                color: context.bgNeutralLight,
                textColor: context.textBaseMedium,
              ),
            ),
            const SizedBox(width: Dimensions.paddingDefault),

            Expanded(
              child: CustomButtonWidget(
                isBold: false,
                fontSize: Dimensions.fontSizeDefault,
                onPressed: onTap,
                buttonText: 'continue'.tr,
              ),
            ),

          ]),
        ),
        const SizedBox(height: Dimensions.paddingDefault),
      ]),

    );
  }
}
