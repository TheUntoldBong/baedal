import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/features/loyalty/widgets/loyalty_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class LoyaltyCardWidget extends StatelessWidget {
  final JustTheController tooltipController;
  const LoyaltyCardWidget({super.key, required this.tooltipController});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (userController) {
        String points = userController.userInfoModel?.loyaltyPoint == null ? '0' : userController.userInfoModel!.loyaltyPoint.toString();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Dimensions.paddingDefault),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: context.surfaceContainer,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(clipBehavior: Clip.none, children: [

            Positioned(
              left: 30, top: -10,
              child: Opacity(opacity: 0.5, child: CustomAssetImageWidget(Images.loyal, height: 110, width: 110)),
            ),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('your_point'.tr, style: context.heading.small.regular.overrideWith(color: context.textBaseMedium)),
                const SizedBox(height: Dimensions.paddingExtraSmall),
                Text(points, style: context.subHeading.extraOverLarge.strong),
              ]),

              CustomButtonWidget(
                width: 163,
                buttonText: 'convert_to_wallet_money'.tr,
                onPressed: () {
                  showCustomDialog( child: DialogSheetBody(child: LoyaltyBottomSheetWidget(amount: points), showCloseIcon: true, showDrager: false,));
                },
              ),
            ]),
          ]),
        );
    });
  }
}



class LoyaltyStepper extends StatelessWidget {
  const LoyaltyStepper({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 70,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                margin: const EdgeInsets.only(top: Dimensions.padding2xSmall),
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: context.primary, width: 2)
                ),
              ),

              Expanded(
                child: VerticalDivider(
                  thickness: 3,
                  color: context.primary.withValues(alpha: 0.30),
                ),
              ),

              Container(
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: context.primary, width: 2),
                ),
              ),
            ]),
            const SizedBox(width: Dimensions.paddingSmall),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('convert_your_loyalty_point_to_wallet_money'.tr, style: context.subHeading.defaultSize.regular),
                  Text('${'Minimum'.tr} ${Get.find<SplashController>().configModel!.loyaltyPointExchangeRate} ${'points_required_to_convert_into_currency'.tr}', style: context.subHeading.defaultSize.regular),
                ],
              ),
            ),

          ]),
        ),
        const SizedBox(height: Dimensions.paddingDefault),

        CustomButtonWidget(
          radius: Dimensions.radiusExtraSmall,
          isBold: true,
          buttonText: 'convert_to_currency_now'.tr,
          onPressed: () {
            showCustomDialog(
              child: LoyaltyBottomSheetWidget(
                amount: Get.find<ProfileController>().userInfoModel!.loyaltyPoint == null
                  ? '0' : Get.find<ProfileController>().userInfoModel!.loyaltyPoint.toString(),
              ));
          },
        ),
      ],
    );
  }
}

