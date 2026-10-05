import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
class PartialPayView extends StatelessWidget {
  final double totalPrice;
  const PartialPayView({super.key, required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(
      builder: (checkoutController) {
        return Get.find<SplashController>().configModel!.partialPaymentStatus! && !checkoutController.subscriptionOrder
        && Get.find<SplashController>().configModel!.customerWalletStatus!
        && Get.find<ProfileController>().userInfoModel != null && (checkoutController.distance != -1)
        && Get.find<ProfileController>().userInfoModel!.walletBalance! > 0 ? AnimatedContainer(
          duration: const Duration(seconds: 2),
          decoration: BoxDecoration(
            color: Get.find<ThemeController>().darkTheme ? context.primary.withValues(alpha: 0.2) : context.primary.withValues(alpha: 0.05),
            border: Border.all(color: context.primary, width: 0.5),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            image: const DecorationImage(
              alignment: Alignment.bottomRight,
              image: AssetImage(Images.partialWalletTransparent),
            ),
          ),
          padding: const EdgeInsets.all(Dimensions.paddingLarge),
          margin: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingLarge : Dimensions.paddingDefault,
            vertical: Dimensions.paddingSmall,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomAssetImageWidget(Images.partialWallet, height: 30, width: 30),
              const SizedBox(width: Dimensions.paddingSmall),

              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  PriceConverter.convertPrice(Get.find<ProfileController>().userInfoModel!.walletBalance!),
                  style: context.heading.extraOverLarge.strong.overrideWith(color: context.primary),
                ),
                const SizedBox(height: Dimensions.padding2xSmall),

                Text(
                  checkoutController.isPartialPay ? 'has_paid_by_your_wallet'.tr : 'your_have_balance_in_your_wallet'.tr,
                  style: context.subHeading.small.medium,
                ),
              ]),

            ]),
            const SizedBox(height: Dimensions.paddingSmall),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

              checkoutController.isPartialPay || checkoutController.paymentMethodIndex == 1 ? Row(children: [
                Container(
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  padding: const EdgeInsets.all(2),
                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                ),
                const SizedBox(width: Dimensions.padding2xSmall),

                Text(
                  'applied'.tr,
                  style: context.subHeading.large.medium.overrideWith(color: context.primary),
                )
              ]) : Text(
                'do_you_want_to_use_now'.tr,
                style: context.subHeading.large.medium.overrideWith(color: context.primary),
              ),

              InkWell(
                onTap: (){
                  if(Get.find<ProfileController>().userInfoModel!.walletBalance! < totalPrice){
                    checkoutController.changePartialPayment();
                  } else{
                    if(checkoutController.paymentMethodIndex != 1) {
                      checkoutController.setPaymentMethod(1);
                    }else{
                      checkoutController.setPaymentMethod(-1);
                    }
                  }

                },
                child: Container(
                  decoration: BoxDecoration(
                    color: checkoutController.isPartialPay || checkoutController.paymentMethodIndex == 1 ? context.surfaceContainer : context.primary,
                    border: Border.all(color: checkoutController.isPartialPay || checkoutController.paymentMethodIndex == 1 ? Colors.red : context.primary, width: 0.5),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall, horizontal: Dimensions.paddingLarge),
                  child: Text(
                    checkoutController.isPartialPay || checkoutController.paymentMethodIndex == 1 ? 'remove'.tr : 'use'.tr,
                    style: context.subHeading.large.strong.overrideWith(color: checkoutController.isPartialPay || checkoutController.paymentMethodIndex == 1 ? Colors.red : context.onPrimary),
                  ),
                ),
              ),

            ]),

            checkoutController.paymentMethodIndex == 1 ? Text(
              '${'remaining_wallet_balance'.tr}: ${PriceConverter.convertPrice(Get.find<ProfileController>().userInfoModel!.walletBalance! - totalPrice)}',
              style: context.subHeading.small.medium,
            ) : const SizedBox(),

          ]),
        ) : const SizedBox();
      }
    );
  }
}
