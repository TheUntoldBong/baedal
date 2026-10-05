import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
class NotificationStatusChangeBottomSheet extends StatelessWidget {
  const NotificationStatusChangeBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      padding: const EdgeInsets.all(Dimensions.paddingLarge),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: ResponsiveHelper.isDesktop(context) ? BorderRadius.circular(Dimensions.radiusLarge) : const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge),
        ),
      ),
      child: GetBuilder<AuthController>(builder: (authController) {
        return Column(mainAxisSize: MainAxisSize.min, children: [

          ResponsiveHelper.isDesktop(context) ?
              Align(alignment: Alignment.topRight, child: IconButton(onPressed: ()=> Get.back(), icon: const Icon(Icons.clear))) : Container(
            height: 5, width: 50,
            decoration: BoxDecoration(
              color: context.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
            ),
          ),
          const SizedBox(height: 35),

          const CustomAssetImageWidget(
            Images.warning, height: 50, width: 50,
          ),
          const SizedBox(height: 35),

          Text('are_you_sure'.tr, style: context.heading.large.medium, textAlign: TextAlign.center),
          const SizedBox(height: Dimensions.paddingSmall),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
            child: Text(
              authController.notification ? 'if_you_disable_this_option_you_will_not_receive_system_notifications'.tr
                  : 'when_you_enable_this_option_you_will_be_notified_with_the_system_notifications'.tr,
              style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium), textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 50),

          Row(children: [

            Expanded(
              child: !authController.notificationLoading ? CustomButtonWidget(
                onPressed: () async {
                  await authController.setNotificationActive(!authController.notification);
                  Get.back();
                },
                buttonText: 'yes'.tr,
                color: Theme.of(context).colorScheme.error,
              ) : Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.error)),
            ),
            const SizedBox(width: Dimensions.paddingSmall),

            Expanded(
              child: CustomButtonWidget(
                onPressed: () {
                  Get.back();
                },
                buttonText: 'no'.tr,
                color: context.bgNeutralMedium,
                textColor: Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),

          ]),

        ]);
      }),
    );
  }
}
