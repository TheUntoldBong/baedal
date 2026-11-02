import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/wallet/widgets/add_fund_dialogue_widget.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
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
  const PaymentSection({
    super.key,
    required this.isCashOnDeliveryActive,
    required this.isDigitalPaymentActive,
    required this.isWalletActive,
    required this.total,
    required this.checkoutController,
    required this.isOfflinePaymentActive,
  });

  @override
  Widget build(BuildContext context) {
    bool isCODSelected = checkoutController.paymentMethodIndex == 0;
    bool isWalletSelected = checkoutController.paymentMethodIndex == 1;
    bool isOnlineSelected = checkoutController.paymentMethodIndex == 2;

    final bool isLogged = Get.find<AuthController>().isLoggedIn();
    final double walletBalance = isLogged ? (Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0) : 0;
    final bool coversTotal = walletBalance >= total;
    final bool isPartialPay = checkoutController.isPartialPay;
    final bool partialPaymentStatus = Get.find<SplashController>().configModel?.partialPaymentStatus ?? false;
    final bool canShowWallet = isWalletActive && isLogged && !checkoutController.subscriptionOrder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(thickness: 2),
        const SizedBox(height: Dimensions.paddingDefault),
        Container(
          color: context.surfaceContainer,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('payment_method'.tr, style: context.heading.extraLarge.strong),
              const SizedBox(height: Dimensions.padding2xSmall),
              Text(
                'select_payment_method'.tr,
                style: context.body.small.regular,
              ),
              const SizedBox(height: Dimensions.paddingDefault),

              // 1. Online Payment (Razorpay - UPI, Cards, NetBanking)
              if (isDigitalPaymentActive) ...[
                _paymentOptionCard(
                  context,
                  title: 'Online Payment',
                  subtitle: isPartialPay
                      ? '${'remaining_bill'.tr}: ${PriceConverter.convertPrice(total - walletBalance)} via UPI, Cards'
                      : 'UPI, Google Pay, PhonePe, Cards, NetBanking',
                  icon: Images.digitalPayment,
                  isSelected: isOnlineSelected,
                  onTap: () {
                    checkoutController.setPaymentMethod(2);
                    checkoutController.changeDigitalPaymentName('razor_pay');
                  },
                ),
                const SizedBox(height: Dimensions.paddingSmall),
              ],

              // 2. Baedal Wallet Payment
              if (canShowWallet) ...[
                _walletOptionCard(
                  context,
                  walletBalance: walletBalance,
                  coversTotal: coversTotal,
                  isSelected: isWalletSelected,
                  isPartialPay: isPartialPay,
                  onTap: () {
                    if (coversTotal) {
                      if (checkoutController.isPartialPay) {
                        checkoutController.changePartialPayment();
                      }
                      checkoutController.setPaymentMethod(1);
                    } else if (partialPaymentStatus && walletBalance > 0) {
                      // Toggle partial payment with wallet
                      checkoutController.changePartialPayment();
                      if (checkoutController.paymentMethodIndex == 1 || checkoutController.paymentMethodIndex == -1) {
                        // Default remainder to online payment
                        checkoutController.setPaymentMethod(2);
                        checkoutController.changeDigitalPaymentName('razor_pay');
                      }
                    } else {
                      showCustomSnackBar(
                        '${'you_do_not_have_sufficient_balance_in_wallet'.tr}. Recharge using digital payment.',
                      );
                      Get.dialog(const Dialog(backgroundColor: Colors.transparent, child: AddFundDialogueWidget()));
                    }
                  },
                  onRechargeTap: () {
                    Get.dialog(const Dialog(backgroundColor: Colors.transparent, child: AddFundDialogueWidget()));
                  },
                ),
                const SizedBox(height: Dimensions.paddingSmall),
              ],

              // 3. Cash On Delivery (COD)
              if (isCashOnDeliveryActive) ...[
                _paymentOptionCard(
                  context,
                  title: checkoutController.orderType == 'dine_in' ? 'pay_after_service'.tr : 'cash_on_delivery'.tr,
                  subtitle: isPartialPay
                      ? '${'remaining_bill'.tr}: ${PriceConverter.convertPrice(total - walletBalance)} via Cash'
                      : 'Pay with cash upon delivery',
                  icon: Images.cash,
                  isSelected: isCODSelected,
                  onTap: () {
                    checkoutController.setPaymentMethod(0);
                  },
                ),
                const SizedBox(height: Dimensions.paddingSmall),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _walletOptionCard(
    BuildContext context, {
    required double walletBalance,
    required bool coversTotal,
    required bool isSelected,
    required bool isPartialPay,
    required VoidCallback onTap,
    required VoidCallback onRechargeTap,
  }) {
    String subtitle;
    if (isPartialPay) {
      subtitle = '${'paid_by_wallet'.tr}: ${PriceConverter.convertPrice(walletBalance)} • ${'remaining_bill'.tr}: ${PriceConverter.convertPrice(total - walletBalance)}';
    } else if (coversTotal) {
      subtitle = 'Balance: ${PriceConverter.convertPrice(walletBalance)} (Sufficient for full order)';
    } else {
      subtitle = 'Balance: ${PriceConverter.convertPrice(walletBalance)} (Insufficient)';
    }

    final bool activeHighlight = isSelected || isPartialPay;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingDefault),
        decoration: BoxDecoration(
          color: activeHighlight ? context.primary.withValues(alpha: 0.05) : context.surface,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: activeHighlight ? context.primary : context.outlineVariant,
            width: activeHighlight ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              padding: const EdgeInsets.all(Dimensions.paddingExtraSmall),
              decoration: BoxDecoration(
                color: activeHighlight ? context.primary.withValues(alpha: 0.1) : context.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: const CustomAssetImageWidget(Images.walletPay, fit: BoxFit.contain),
            ),
            const SizedBox(width: Dimensions.paddingDefault),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'wallet_payment'.tr,
                        style: context.heading.defaultSize.semiBold.overrideWith(
                          color: activeHighlight ? context.primary : context.textBaseDefault,
                        ),
                      ),
                      if (isPartialPay) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: context.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'applied'.tr,
                            style: context.body.extraSmall.medium.overrideWith(color: context.primary),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: context.body.small.regular.overrideWith(
                      color: context.textBaseMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Dimensions.paddingSmall),
            // "Recharge" button when balance is insufficient, or selection checkmark when sufficient
            if (!coversTotal)
              InkWell(
                onTap: onRechargeTap,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.primary,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Text(
                    'recharge'.tr.isNotEmpty ? 'recharge'.tr : 'Add Fund',
                    style: robotoBold.copyWith(
                      color: Colors.white,
                      fontSize: Dimensions.fontSizeExtraSmall,
                    ),
                  ),
                ),
              )
            else
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? context.primary : context.iconDisabledDefault,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget _paymentOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingDefault),
        decoration: BoxDecoration(
          color: isSelected ? context.primary.withValues(alpha: 0.05) : context.surface,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: isSelected ? context.primary : context.outlineVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              padding: const EdgeInsets.all(Dimensions.paddingExtraSmall),
              decoration: BoxDecoration(
                color: isSelected ? context.primary.withValues(alpha: 0.1) : context.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: CustomAssetImageWidget(icon, fit: BoxFit.contain),
            ),
            const SizedBox(width: Dimensions.paddingDefault),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.heading.defaultSize.semiBold.overrideWith(
                      color: isSelected ? context.primary : context.textBaseDefault,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: context.body.small.regular.overrideWith(
                      color: context.textBaseMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Dimensions.paddingSmall),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? context.primary : context.iconDisabledDefault,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
