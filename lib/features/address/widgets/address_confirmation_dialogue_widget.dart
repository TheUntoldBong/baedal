import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class AddressConfirmDialogueWidget extends StatelessWidget {
  final String icon;
  final String? title;
  final String description;
  final Function onYesPressed;
  final bool isDefault;
  const AddressConfirmDialogueWidget({super.key, required this.icon, this.title, required this.description, required this.onYesPressed, this.isDefault = false});

  @override
  Widget build(BuildContext context) {
    return DialogSheetBody(
      child: PointerInterceptor(
        child: SizedBox(
          width: 500,
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingLarge),
            child: Column(mainAxisSize: MainAxisSize.min, children: [

              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingLarge),
                child: CustomAssetImageWidget(icon, width: 50, height: 50),
              ),

              title != null ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                child: Text(
                  title ?? '', textAlign: TextAlign.center,
                  style: context.heading.extraLarge.medium,
                ),
              ) : const SizedBox(),

              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingLarge),
                child: Text(description, style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium), textAlign: TextAlign.center),
              ),
              const SizedBox(height: Dimensions.paddingLarge),

              isDefault ? GetBuilder<LocationController>(builder: (locationController) {
                return !locationController.isLoading ? Row(children: [

                  Expanded(child: CustomButtonWidget(
                    buttonText:  'cancel'.tr, textColor: context.textBaseDefault,
                    onPressed: () => Get.back(),
                    radius: Dimensions.radiusDefault, height: 50, color: context.surfaceContainerLowest,
                  )),
                  const SizedBox(width: Dimensions.paddingLarge),

                  Expanded(child: TextButton(
                    onPressed: () => onYesPressed(),
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error, minimumSize: const Size(Dimensions.webMaxWidth, 50), padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                    ),
                    child: Text(
                      'ok'.tr, textAlign: TextAlign.center,
                      style: context.body.defaultSize.strong.overrideWith(color: context.surfaceContainer),
                    ),
                  )),

                ]) : const Center(child: CircularProgressIndicator());
              }) :  GetBuilder<LocationController>(builder: (locationController) {
                return !locationController.isLoading ? Row(children: [

                  Expanded(child: TextButton(
                    onPressed: () => onYesPressed(),
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error, minimumSize: const Size(Dimensions.webMaxWidth, 50), padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                    ),
                    child: Text(
                      'delete'.tr, textAlign: TextAlign.center,
                      style: context.body.defaultSize.strong.overrideWith(color: context.surfaceContainer),
                    ),
                  )),
                  const SizedBox(width: Dimensions.paddingLarge),

                  Expanded(child: CustomButtonWidget(
                    buttonText:  'cancel'.tr, textColor: context.textBaseDefault,
                    onPressed: () => Get.back(),
                    radius: Dimensions.radiusDefault, height: 50, color: context.surfaceContainerLowest,
                  )),

                ]) : const Center(child: CircularProgressIndicator());
              }),

            ]),
          ),
        ),
      ));
  }
}
