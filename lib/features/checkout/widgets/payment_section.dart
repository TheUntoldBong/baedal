import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/payment_method_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/extensions.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class PaymentSection extends StatelessWidget {
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isWalletActive;
  final bool isOfflinePaymentActive;
  final double total;
  final CheckoutController checkoutController;
  const PaymentSection({super.key, required this.isCashOnDeliveryActive, required this.isDigitalPaymentActive,
    required this.isWalletActive, required this.total, required this.checkoutController, required this.isOfflinePaymentActive});

  void _openPaymentMethodSheet(BuildContext context) {
    if(ResponsiveHelper.isDesktop(context)){
      Get.dialog(Dialog(backgroundColor: Colors.transparent, child: PaymentMethodBottomSheet(
        isCashOnDeliveryActive: isCashOnDeliveryActive, isDigitalPaymentActive: isDigitalPaymentActive,
        isWalletActive: isWalletActive, totalPrice: total, isOfflinePaymentActive: isOfflinePaymentActive,
      )));
    }else {
      Get.bottomSheet(
        PaymentMethodBottomSheet(
          isCashOnDeliveryActive: isCashOnDeliveryActive, isDigitalPaymentActive: isDigitalPaymentActive,
          isWalletActive: isWalletActive, totalPrice: total, isOfflinePaymentActive: isOfflinePaymentActive,
        ),
        backgroundColor: Colors.transparent, isScrollControlled: true, useRootNavigator: true,
      );
    }
  }

  String _methodLabel(bool isDineIn) {
    return checkoutController.paymentMethodIndex == 0 ? (isDineIn ? 'pay_after_service'.tr : 'cash_on_delivery'.tr)
      : checkoutController.paymentMethodIndex == 1 ? 'wallet_payment'.tr
      : checkoutController.paymentMethodIndex == 2 ? '${'digital_payment'.tr} (${checkoutController.digitalPaymentName?.replaceAll('_', ' ').toTitleCase() ?? ''})'
      : checkoutController.paymentMethodIndex == 3 ? '${'offline_payment'.tr} (${checkoutController.offlineMethodList![checkoutController.selectedOfflineBankIndex].methodName})'
      : 'select_payment_method'.tr;
  }

  Widget _methodIcon(BuildContext context) {
    if(checkoutController.paymentMethodIndex == 2) {
      final matchedGateway = Get.find<SplashController>().configModel!.activePaymentMethodList!.firstWhereOrNull(
        (gateway) => gateway.getWay == checkoutController.digitalPaymentName,
      );
      if(matchedGateway?.getWayImageFullUrl != null) {
        return CustomImageWidget(image: matchedGateway!.getWayImageFullUrl!, height: 26, width: 26, fit: BoxFit.contain);
      }
    }
    return Container(
      height: 32, width: 32,
      padding: const EdgeInsets.all(Dimensions.paddingExtraSmall),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        shape: BoxShape.circle,
      ),
      child: CustomAssetImageWidget(
        checkoutController.paymentMethodIndex == 0 ? Images.cash
          : checkoutController.paymentMethodIndex == 1 ? Images.walletPay
          : Images.digitalPayment,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _paymentRow(BuildContext context, {required Widget icon, required String label, required double amount}) {
    return Row(children: [
      icon,
      const SizedBox(width: Dimensions.paddingSmall),

      Expanded(child: Text(
        label, maxLines: 1, overflow: TextOverflow.ellipsis,
        style: context.subHeading.defaultSize.medium.overrideWith(color: context.textBaseDefault),
      )),
      const SizedBox(width: Dimensions.paddingSmall),

      Text(
        PriceConverter.convertPrice(amount), textDirection: TextDirection.ltr,
        style: context.heading.large.semiBold,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    double walletBalance = Get.find<ProfileController>().userInfoModel?.walletBalance??0;
    bool isDineIn = checkoutController.orderType == 'dine_in';
    bool hasSelectedMethod = checkoutController.paymentMethodIndex != -1;

    return Column(children: [
      Divider( thickness: 2),
      SizedBox(height: Dimensions.paddingDefault),
      Container(
          color: context.surfaceContainer,
          padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            
        
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('payment_method'.tr, style: context.heading.extraLarge.strong),
                const SizedBox(height: Dimensions.padding2xSmall),
        
                Text(
                  'add_at_least_one_option_to_pay_your_order'.tr,
                  style: context.body.small.regular,
                ),
              ])),
              const SizedBox(width: Dimensions.paddingLarge),
        
              hasSelectedMethod ? InkWell(
                onTap: () => _openPaymentMethodSheet(context),
                child: CustomAssetImageWidget(Images.editBtn, width: 20),
              ) : const SizedBox(),
            ]),
            const SizedBox(height: Dimensions.paddingDefault),
        
            !hasSelectedMethod ? InkWell(
              onTap: () => _openPaymentMethodSheet(context),
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingDefault),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.add_circle_outline, size: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
                  const SizedBox(width: Dimensions.paddingSmall),
                  Text('add_payment_method'.tr, style: context.heading.defaultSize.strong),
                ]),
              ),
            ) : Column(children: [
              const SizedBox(height: Dimensions.padding2xSmall),
        
              checkoutController.isPartialPay ? Column(children: [
                _paymentRow(context, icon: Container(
                  height: 32, width: 32, padding: const EdgeInsets.all(Dimensions.paddingExtraSmall),
                  decoration: BoxDecoration(color: context.surfaceContainer, shape: BoxShape.circle),
                  child: CustomAssetImageWidget(Images.walletPay, fit: BoxFit.contain),
                ), label: 'wallet_payment'.tr, amount: walletBalance),
                const SizedBox(height: Dimensions.paddingSmall),
        
                _paymentRow(context, icon: _methodIcon(context), label: _methodLabel(isDineIn), amount: total - walletBalance),
              ]) : _paymentRow(context, icon: _methodIcon(context), label: _methodLabel(isDineIn), amount: total),
            ]),
          ]),
        ),
    ]);
  }
}
