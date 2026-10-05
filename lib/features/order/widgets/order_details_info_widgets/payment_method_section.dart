import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/enums/order_status.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';

import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/digital_payment_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/order/widgets/collapsible_header.dart';
import 'package:stackfood_multivendor/features/order/widgets/pay_digitally_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/config_model.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class PaymentMethodSection extends StatefulWidget {
  final List<Payments> payments;
  final OrderModel? order;
  final double? total;
  final String? contactNumber;

  const PaymentMethodSection({super.key, required this.payments, this.order, this.total, this.contactNumber});

  static bool canOfferDigitalPayment(OrderModel? order, ConfigModel? config) {
    if(order == null || order.paymentMethod != 'cash_on_delivery' || order.paymentStatus == 'paid') {
      return false;
    }

    if(order.subscription != null || order.subscriptionId != null) {
      return false;
    }

    if(!(config?.digitalPayment ?? false) || !(config?.codToDigitalPayment ?? false) || (config?.activePaymentMethodList?.isEmpty ?? true)) {
      return false;
    }

    return order.orderStatus == OrderStatus.pending.name || order.orderStatus == OrderStatus.accepted.name
      || order.orderStatus == OrderStatus.confirmed.name || order.orderStatus == OrderStatus.processing.name
      || order.orderStatus == OrderStatus.handover.name || order.orderStatus == OrderStatus.picked_up.name;
  }

  @override
  State<PaymentMethodSection> createState() => PaymentMethodSectionState();
}

class PaymentMethodSectionState extends State<PaymentMethodSection> {
  bool _expanded = true;
  DigitalPaymentStatusModel? _digitalPaymentStatus;
  int? _statusRequestedForOrderId;

  bool get _locallyEligible => PaymentMethodSection.canOfferDigitalPayment(widget.order, Get.find<SplashController>().configModel);

  bool get _canPayDigitally => _locallyEligible && (_digitalPaymentStatus?.eligible ?? false);

  double get _amountDue {
    final double? amountDue = _digitalPaymentStatus?.amountDue;
    if(amountDue != null && amountDue > 0) {
      return amountDue;
    }
    return widget.total ?? widget.order!.orderAmount ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _checkDigitalPaymentEligibility();
  }

  @override
  void didUpdateWidget(covariant PaymentMethodSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.order?.id != oldWidget.order?.id) {
      _digitalPaymentStatus = null;
      _statusRequestedForOrderId = null;
    }
    _checkDigitalPaymentEligibility();
  }

  void _checkDigitalPaymentEligibility() async {
    final int? orderId = widget.order?.id;
    if(orderId == null || !_locallyEligible || _statusRequestedForOrderId == orderId) {
      return;
    }
    _statusRequestedForOrderId = orderId;

    final DigitalPaymentStatusModel? status = await Get.find<OrderController>().getDigitalPaymentStatus(orderId);
    if(mounted && _statusRequestedForOrderId == orderId) {
      setState(() => _digitalPaymentStatus = status);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      CollapsibleSectionHeader(
        title: 'payment_method'.tr,
        expanded: _expanded,
        onTap: () => setState(() => _expanded = !_expanded),
      ),

      AnimatedCrossFade(
        firstChild: const SizedBox(width: double.infinity),
        secondChild: Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (int i = 0; i < widget.payments.length; i++) ...[
              _PaymentRow(payment: widget.payments[i], hilight : _canPayDigitally),
              if (i != widget.payments.length - 1)
                const SizedBox(height: Dimensions.paddingDefault),
            ],

            if(_canPayDigitally) ...[
              const SizedBox(height: Dimensions.paddingDefault),
              _PayDigitallyCard(
                order: widget.order!,
                total: _amountDue,
                contactNumber: widget.contactNumber,
              ),
            ],
          ]),
        ),
        crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 200),
      ),
    ]);
  }
}

class _PayDigitallyCard extends StatelessWidget {
  final OrderModel order;
  final double total;
  final String? contactNumber;

  const _PayDigitallyCard({required this.order, required this.total, this.contactNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingMedium),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: context.outline),
      ),
      child: Row(children: [

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text('no_cash_in_your_hand'.tr, style: context.heading.large.medium),
            const SizedBox(height: Dimensions.paddingOverSmall),

            Text(
              'select_any_digital_gateways_to_pay'.tr,
              style: context.subHeading.small.regular.overrideWith(color: context.textBaseMedium),
            ),
          ]),
        ),
        const SizedBox(width: Dimensions.paddingSmall),

        CustomButtonWidget(
          buttonText: 'pay_digitally'.tr,
          takeMinimumWidth: true,
          height: 36,
          radius: Dimensions.radiusMedium,
          fontSize: Dimensions.fontSizeSmall,
          onPressed: () => PayDigitallyBottomSheet.open(context, order: order, totalPrice: total, contactNumber: contactNumber),
        ),
      ]),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final Payments payment;
  final bool hilight;

  const _PaymentRow({required this.payment, this.hilight = false});

  IconData get _icon {
    switch (payment.paymentMethod) {
      case 'cash_on_delivery':
        return Icons.payments_outlined;
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'digital_payment':
        return Icons.credit_card;
      case 'offline_payment':
        return Icons.receipt_long_outlined;
      default:
        return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Icon(_icon, size: 20, color: Theme.of(context).textTheme.bodyLarge?.color),
      const SizedBox(width: Dimensions.paddingDefault),

      Expanded(
        child: Text(
          (payment.paymentMethod ?? '').tr.replaceAll('_', ' '),
          style: context.heading.defaultSize.overrideWith(fontWeight: hilight ? AppWeight.strong : AppWeight.regular),
        ),
      ),

      Text(
        PriceConverter.convertPrice(payment.amount ?? 0),
        style: context.heading.defaultSize.regular.overrideWith(fontWeight: hilight ? AppWeight.strong : AppWeight.regular),
      ),
    ]);
  }
}
