import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class ConfirmationDialogWidget extends StatelessWidget {
  final String icon;
  final String? title;
  final String description;
  final Function onYesPressed;
  final bool isLogOut;
  final Function? onNoPressed;
  final Color? titleColor;
  final bool? isDelete;
  const ConfirmationDialogWidget({super.key, required this.icon, this.title, required this.description, required this.onYesPressed,
    this.isLogOut = false, this.onNoPressed, this.titleColor = Colors.red, this.isDelete = false});

  @override
  Widget build(BuildContext context) {
    return DialogSheetBody(
      padding: const EdgeInsets.all(Dimensions.paddingLarge),
      child: PointerInterceptor(
        child: Column(mainAxisSize: MainAxisSize.min, children: [

            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingLarge),
              child: CustomAssetImageWidget(icon, width: 50, height: 50),
            ),

            title != null ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
              child: Text(
                title!, textAlign: TextAlign.center,
                style: context.heading.extraLarge.medium.overrideWith(color: titleColor),
              ),
            ) : const SizedBox(),

            Padding(
              padding: EdgeInsets.all(isDelete == true ? Dimensions.paddingSmall : Dimensions.paddingLarge),
              child: Text(description, style: isDelete == true? context.body.defaultSize.regular : context.body.large.medium, textAlign: TextAlign.center),
            ),
            const SizedBox(height: Dimensions.paddingLarge),

            GetBuilder<ProfileController>(builder: (userController) {
              return GetBuilder<AuthController>(builder: (authController) {
                return GetBuilder<OrderController>(builder: (orderController) {
                  return (orderController.isLoading || userController.isLoading || authController.guestLoading || authController.isLoading) ? const Center(child: CircularProgressIndicator()) : Row(children: [
                    Expanded(child: TextButton(
                      onPressed: () => isLogOut ? onYesPressed() : onNoPressed != null ? onNoPressed!() : Get.back(),
                      style: TextButton.styleFrom(
                        backgroundColor: isDelete == true ? context.error : context.surfaceContainerLowest, minimumSize: const Size(Dimensions.webMaxWidth, 40), padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall)),
                      ),
                      child: Text(
                        isLogOut ? isDelete == true ? 'delete'.tr : 'yes'.tr : isDelete == true ? 'cancel'.tr : 'no'.tr, textAlign: TextAlign.center,
                        style: context.heading.defaultSize.strong.overrideWith(color: isDelete == true ? context.surfaceContainer : Theme.of(context).textTheme.bodyLarge!.color),
                      ),
                    )),
                    const SizedBox(width: Dimensions.paddingLarge),

                    Expanded(child: CustomButtonWidget(
                      color: isDelete == true ? context.bgNeutralMedium : context.primary,
                      textColor: isDelete == true ? context.textBaseMedium : context.surfaceContainer,
                      buttonText: isLogOut ? isDelete == true ? 'cancel'.tr : 'no'.tr : isDelete == true ? 'delete'.tr : 'yes'.tr,
                      onPressed: () => isLogOut ? Get.back() : onYesPressed(),
                      radius: Dimensions.radiusExtraSmall, height: 40,
                    )),

                  ]);
                });
              });
            }),

        ]),
      ),
    );
  }
}
