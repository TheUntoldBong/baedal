import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class PermissionDialog extends StatelessWidget {
  const PermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return DialogSheetBody(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingLarge),
        child: SizedBox(
          width: 500,
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            Icon(Icons.add_location_alt_rounded, color: context.primary, size: 100),
            const SizedBox(height: Dimensions.paddingLarge),

            ResponsiveHelper.isMobile(context) ? Text(
              'you_denied_location_permission'.tr, textAlign: TextAlign.center,
              style: context.heading.large.medium,
            ) : Text(
              'please_enable_location_permission_from_browser_settings'.tr, textAlign: TextAlign.center,
              style: context.heading.large.medium,
            ),
            const SizedBox(height: Dimensions.paddingLarge),

            Row(children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall), side: BorderSide(width: 2, color: context.primary)),
                    minimumSize: const Size(1, 40),
                  ),
                  child: Text('close'.tr),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSmall),
              ResponsiveHelper.isMobile(context) ? Expanded(child: CustomButtonWidget(buttonText: 'settings'.tr, onPressed: () async {
                await Geolocator.openAppSettings();
                Get.back();
              })) : const SizedBox(),
            ]),
          ]),
        ),
      ));
  }
}
