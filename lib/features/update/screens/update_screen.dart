import 'package:stackfood_multivendor/common/widgets/dotted_divider.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UpdateScreen extends StatelessWidget {
  final bool isUpdate;
  const UpdateScreen({super.key, required this.isUpdate});

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: GetBuilder<SplashController>(builder: (splashController) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingLarge),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        
              CustomAssetImageWidget(
                isUpdate ? Images.update : Images.maintenance,
                width: 280, height: 180,
              ),
              const SizedBox(height: 50),
        
              Text(
                isUpdate ? 'update'.tr : splashController.configModel!.maintenanceModeData?.maintenanceMessageSetup?.maintenanceMessage ?? 'we_are_cooking_up_something_special'.tr,
                style: context.heading.defaultSize.semiBold.copyWith(fontSize: isUpdate ? MediaQuery.of(context).size.height*0.023 : Dimensions.fontSizeDefault),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.paddingDefault),
        
              SizedBox(
                width: context.width,
                child: Text(
                  isUpdate ? 'your_app_is_deprecated'.tr : splashController.configModel!.maintenanceModeData?.maintenanceMessageSetup?.messageBody ?? 'maintenance_mode'.tr,
                  style: context.body.small.regular.overrideWith(color: context.textBaseMedium).copyWith(fontSize: isUpdate ? MediaQuery.of(context).size.height*0.0175 : Dimensions.fontSizeSmall),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: isUpdate ? MediaQuery.of(context).size.height*0.04 : Dimensions.paddingLarge),
        
              isUpdate ? const SizedBox() : Column(children: [
        
                splashController.configModel!.maintenanceModeData?.maintenanceMessageSetup?.businessEmail == 1
                || splashController.configModel!.maintenanceModeData?.maintenanceMessageSetup?.businessNumber == 1 ? Column(
                  children: [
        
                    SizedBox(
                      width: context.width,
                      child: DottedDivider(dashWidth: 10, color: context.outlineVariant),
                    ),
                    SizedBox(height: Dimensions.paddingLarge),
        
                    Text(
                      'any_query_feel_free_to_contact_us'.tr,
                      style: context.subHeading.small.medium,
                    ),
                    const SizedBox(height: Dimensions.paddingLarge),
        
                    splashController.configModel!.maintenanceModeData?.maintenanceMessageSetup?.businessNumber == 1 ? InkWell(
                      onTap: () async {
                        if(await canLaunchUrlString('tel:${splashController.configModel?.phone}')) {
                          launchUrlString('tel:${splashController.configModel?.phone}', mode: LaunchMode.externalApplication);
                        }else {
                          showCustomSnackBar('${'can_not_launch'.tr} ${splashController.configModel?.phone}');
                        }
                      },
                      child: Text(
                        splashController.configModel?.phone ?? '',
                        style: context.subHeading.small.medium.overrideWith(color: context.primary).copyWith(decoration: TextDecoration.underline, decorationColor: context.primary),
                      ),
                    ) : const SizedBox(),
                    SizedBox(height: splashController.configModel!.maintenanceModeData?.maintenanceMessageSetup?.businessNumber == 1 ? Dimensions.padding2xSmall : 0),
        
                    splashController.configModel!.maintenanceModeData?.maintenanceMessageSetup?.businessEmail == 1 ? InkWell(
                      onTap: () async {
                        if(await canLaunchUrlString('mailto:${splashController.configModel?.email}')) {
                          launchUrlString('mailto:${splashController.configModel?.email}', mode: LaunchMode.externalApplication);
                        }else {
                          showCustomSnackBar('${'can_not_launch'.tr} ${splashController.configModel?.email}');
                        }
                      },
                      child: Text(
                        splashController.configModel?.email ?? '',
                        style: context.subHeading.small.medium.overrideWith(color: context.primary).copyWith(decoration: TextDecoration.underline, decorationColor: context.primary),
                      ),
                    ) : const SizedBox(),
                  ],
                ) : const SizedBox(),
        
              ]),
        
              isUpdate ? CustomButtonWidget(buttonText: 'update_now'.tr, onPressed: () async {
                String? appUrl = 'https://google.com';
                if(GetPlatform.isAndroid) {
                  appUrl = splashController.configModel!.appUrlAndroid;
                }else if(GetPlatform.isIOS) {
                  appUrl = splashController.configModel!.appUrlIos;
                }
                if(await canLaunchUrlString(appUrl!)) {
                  launchUrlString(appUrl, mode: LaunchMode.externalApplication);
                }else {
                  showCustomSnackBar('${'can_not_launch'.tr} $appUrl');
                }
              }) : const SizedBox(),
        
            ]),
          ),
        );
      }),
    );
  }
}
