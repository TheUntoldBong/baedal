import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
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
    bool isOnlineSelected = checkoutController.paymentMethodIndex == 2;

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
              if (isDigitalPaymentActive)
                _paymentOptionCard(
                  context,
                  title: 'Online Payment',
                  subtitle: 'UPI, Google Pay, PhonePe, Cards, NetBanking',
                  icon: Images.digitalPayment,
                  isSelected: isOnlineSelected,
                  onTap: () {
                    checkoutController.setPaymentMethod(2);
                    checkoutController.changeDigitalPaymentName('razor_pay');
                  },
                ),

              if (isDigitalPaymentActive && isCashOnDeliveryActive)
                const SizedBox(height: Dimensions.paddingSmall),

              // 2. Cash On Delivery (COD)
              if (isCashOnDeliveryActive)
                _paymentOptionCard(
                  context,
                  title: checkoutController.orderType == 'dine_in' ? 'pay_after_service'.tr : 'cash_on_delivery'.tr,
                  subtitle: 'Pay with cash upon delivery',
                  icon: Images.cash,
                  isSelected: isCODSelected,
                  onTap: () {
                    checkoutController.setPaymentMethod(0);
                  },
                ),

              const SizedBox(height: Dimensions.paddingSmall),
            ],
          ),
        ),
      ],
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
