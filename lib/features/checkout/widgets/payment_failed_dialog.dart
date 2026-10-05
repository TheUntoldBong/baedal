import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';

class PaymentFailedDialog extends StatelessWidget {
  final String? orderID;
  final double? orderAmount;
  final double? maxCodOrderAmount;
  final String? contactPersonNumber;
  const PaymentFailedDialog({super.key, required this.orderID, required this.maxCodOrderAmount, required this.orderAmount, this.contactPersonNumber});

  @override
  Widget build(BuildContext context) {
    return DialogSheetBody(
      child: SizedBox(width: 500, child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingLarge),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingLarge),
            child: CustomAssetImageWidget(Images.warning, width: 70, height: 70),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
            child: Text(
              'are_you_agree_with_this_order_fail'.tr, textAlign: TextAlign.center,
              style: context.heading.extraLarge.medium.overrideWith(color: Colors.red),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingLarge),
            child: Text(
              'if_you_do_not_pay'.tr,
              style: context.subHeading.large.medium, textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: Dimensions.paddingLarge),

          GetBuilder<OrderController>(builder: (orderController) {
            return !orderController.isLoading ? Column(children: [
              Get.find<SplashController>().configModel!.cashOnDelivery! ? CustomButtonWidget(
                buttonText: 'switch_to_cash_on_delivery'.tr,
                onPressed: () {
                  if(maxCodOrderAmount == null || orderAmount! < maxCodOrderAmount!){
                    double total = ((orderAmount! / 100) * Get.find<SplashController>().configModel!.loyaltyPointItemPurchasePoint!);
                    orderController.switchToCOD(orderID, contactPersonNumber, points: total);
                  }else{
                    if(Get.isDialogOpen!) {
                      Get.back();
                    }
                    showCustomSnackBar('${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
                  }
                },
                radius: Dimensions.radiusExtraSmall, height: 40,
              ) : const SizedBox(),
              SizedBox(height: Get.find<SplashController>().configModel!.cashOnDelivery! ? Dimensions.paddingLarge : 0),
              !orderController.isCancelLoading ? TextButton(
                onPressed: () {
                  Get.find<OrderController>().cancelOrder(int.parse(orderID!), 'Digital payment issue').then((success) {
                    if(success) {
                      Get.offAllNamed(RouteHelper.getInitialRoute());
                    }
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor: context.bgNeutralMedium, minimumSize: const Size(Dimensions.webMaxWidth, 40), padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall)),
                ),
                child: Text('cancel_order'.tr, textAlign: TextAlign.center, style: context.subHeading.defaultSize.strong.overrideWith(color: context.textBaseDefault)),
              ) : const Center(child: CircularProgressIndicator()),
            ]) : const Center(child: CircularProgressIndicator());
          }),

        ]),
      )));
  }
}
