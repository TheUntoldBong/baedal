import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
class PartialPayDialog extends StatelessWidget {
  final bool isPartialPay;
  final double totalPrice;
  const PartialPayDialog({super.key, required this.isPartialPay, required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Align(alignment: Alignment.topRight, child: InkWell(
            onTap: ()=> Get.back(),
            child:  Padding(
              padding: EdgeInsets.all(8.0),
              child: Container(width: 28, height: 28, 
              decoration: BoxDecoration(color: context.bgNeutralLight, shape: BoxShape.circle),
               child: Icon(Icons.clear, size: 20, color: context.iconBaseMedium)),
            ),
          )),

          CustomAssetImageWidget(Images.note, width: 35, height: 35),
          const SizedBox(height: Dimensions.paddingSmall),

          Text(
            'note'.tr, textAlign: TextAlign.center,
            style: context.heading.extraLarge.strong,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingSmall),
            child: Text(
              isPartialPay ? 'you_do_not_have_sufficient_balance_to_pay_full_amount_via_wallet'.tr
                  : 'you_can_pay_the_full_amount_with_your_wallet'.tr,
              style: context.subHeading.large.medium, textAlign: TextAlign.center,
            ),
          ),

          Text(
            isPartialPay ? 'want_to_pay_partially_with_wallet'.tr : 'want_to_pay_via_wallet'.tr,
            style: context.subHeading.large.medium.overrideWith(color: context.primary), textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.paddingDefault),

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            CustomAssetImageWidget(Images.partialWallet, height: 35, width: 35),
            const SizedBox(width: Dimensions.paddingDefault),

            Text(
              PriceConverter.convertPrice(Get.find<ProfileController>().userInfoModel!.walletBalance!),
              style: context.heading.extraOverLarge.strong.overrideWith(color: context.primary),
            ),
          ]),


          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSmall),
            child: isPartialPay ? Text(
              'can_be_paid_via_wallet'.tr,
              style: context.body.defaultSize.medium.overrideWith(color: context.textBaseMedium),
              textAlign: TextAlign.center,
            ) : Text.rich(
              TextSpan(style: context.body.defaultSize.medium.overrideWith(color: context.textBaseMedium), children: [
                TextSpan(
                  text: '${'remaining_wallet_balance'.tr}: ',
                  style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                ),
                TextSpan(
                  text: PriceConverter.convertPrice(Get.find<ProfileController>().userInfoModel!.walletBalance! - totalPrice),
                  style: context.body.defaultSize.strong.overrideWith(color: context.textBaseDefault),
                ),
              ]),
              textAlign: TextAlign.center,
            )
          ),

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingLarge),
            child: Row(children: [
              Expanded(child: CustomButtonWidget(buttonText: 'no'.tr,
                fontSize: Dimensions.fontSizeDefault,
                color: context.bgNeutralLight,
                textColor: Theme.of(context).textTheme.bodyLarge?.color,
                onPressed: (){
                Get.find<CheckoutController>().setPaymentMethod(-1);
                if(Get.find<CheckoutController>().isPartialPay){
                  Get.find<CheckoutController>().changePartialPayment();
                }
                Get.back();
                },
              )),
              const SizedBox(width: Dimensions.paddingSmall),

              Expanded(child: CustomButtonWidget(buttonText: 'yes_pay'.tr, fontSize: Dimensions.fontSizeDefault, onPressed: (){
                if(isPartialPay){
                  if(!Get.find<CheckoutController>().isPartialPay){
                    Get.find<CheckoutController>().changePartialPayment();
                  }
                }else{
                  Get.find<CheckoutController>().setPaymentMethod(1);
                }
                Get.back();
              })),
            ]),
          ),
        ]),
      ),
    );
  }
}
