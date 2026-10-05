import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/adaptive_dialog_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/order/widgets/order_details_info_widgets/payment_method_section.dart';
import 'package:stackfood_multivendor/features/order/widgets/pay_digitally_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CodPaymentFailedSheet extends StatelessWidget {
  final OrderModel? order;
  final String? contactNumber;
  const CodPaymentFailedSheet({super.key, required this.order, this.contactNumber});

  static void open({required OrderModel? order, String? contactNumber}) {
    showCustomDialog(child: CodPaymentFailedSheet(order: order, contactNumber: contactNumber));
  }

  bool get _canRetry => order != null
      && PaymentMethodSection.canOfferDigitalPayment(order, Get.find<SplashController>().configModel);

  void _retry() {
    final OrderModel retryOrder = order!;
    Get.back();
    PayDigitallyBottomSheet.open(
      Get.context!, order: retryOrder,
      totalPrice: retryOrder.orderAmount ?? 0, contactNumber: contactNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.paddingLarge, Dimensions.paddingLarge, Dimensions.paddingLarge, Dimensions.paddingExtraLarge,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        Container(
          padding: const EdgeInsets.all(Dimensions.paddingMedium),
          decoration: BoxDecoration(
            color: context.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.priority_high_rounded, size: 24, color: context.error),
        ),
        const SizedBox(height: Dimensions.paddingLarge),

        Text('payment_failed'.tr, style: context.heading.large.strong, textAlign: TextAlign.center),
        const SizedBox(height: Dimensions.paddingSmall),

        Text(
          'payment_failed_your_order_is_unchanged'.tr, textAlign: TextAlign.center,
          style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
        ),
        const SizedBox(height: Dimensions.paddingExtraLarge),

        Row(children: [
          Expanded(child: CustomButtonWidget(
            buttonText: 'close'.tr, transparent: true, height: 45,
            onPressed: () => Get.back(),
          )),

          if(_canRetry) ...[
            const SizedBox(width: Dimensions.paddingSmall),
            Expanded(child: CustomButtonWidget(
              buttonText: 'try_again'.tr, height: 45,
              onPressed: _retry,
            )),
          ],
        ]),
      ]),
    );
  }
}
