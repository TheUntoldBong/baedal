import 'package:dotted_border/dotted_border.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_tool_tip.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/discount_eligibility_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/pro/domain/models/pro_active_offer_model.dart';
import 'package:stackfood_multivendor/features/order/model/billing_value.dart';
import 'package:stackfood_multivendor/features/order/widgets/collapsible_header.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class BillingSummarySection extends StatefulWidget {
  final OrderModel order;
  final BillingValues billing;

  const BillingSummarySection({super.key, required this.order, required this.billing});

  @override
  State<BillingSummarySection> createState() => _BillingSummarySectionState();
}

class _BillingSummarySectionState extends State<BillingSummarySection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final billing = widget.billing;
    final addOnEnabled = billing.addOns > 0;
    final additionalChargeName = Get.find<SplashController>().configModel?.additionalChargeName ?? '';
    final hasAdditionalCharge = billing.additionalCharge > 0;
    final hasCouponDiscount = billing.couponDiscount > 0;
    final hasReferrerBonus = billing.referrerBonusAmount > 0;
    final hasDmTips = billing.dmTips > 0;
    final hasExtraPackaging = billing.extraPackagingCharge > 0;
    final showVat = billing.tax > 0 && !billing.taxIncluded;
    final showDeliveryTypeCharge = (order.deliveryType == 'slightly_delay' || order.deliveryType == 'express') && billing.deliveryTypeCharge != 0;
    final isProDiscount = order.benefitType == ProBenefitType.discount && (order.proDiscount ?? 0) > 0;
    final isProCoupon = order.benefitType == ProBenefitType.coupon && (hasCouponDiscount || (order.couponDiscountAmount ?? 0) > 0);
    final isProDeliveryFee = order.benefitType == ProBenefitType.deliveryFee && (order.deliveryFeeReductionAmount ?? 0) > 0;
    final DiscountSource? discountSource = billing.discount > 0 ? order.discountSource : null;
    final isSubscription = order.subscription != null;
    final repeatQuantity = order.subscription?.quantity ?? 1;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      CollapsibleSectionHeader(
        title: 'billing_summary'.tr,
        expanded: _expanded,
        onTap: () => setState(() => _expanded = !_expanded),
      ),

      AnimatedCrossFade(
        firstChild: const SizedBox(width: double.infinity),
        secondChild: Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _BillingRow(label: 'item_price'.tr, value: PriceConverter.convertPrice(billing.itemsPrice)),
            if (addOnEnabled) ...[
              _BillingRow(label: 'addons'.tr, value: '(+) ${PriceConverter.convertPrice(billing.addOns)}'),
              Divider(thickness: 1),
              _BillingRow(label: 'subtotal'.tr, value: PriceConverter.convertPrice(billing.subTotal), style: context.heading.defaultSize.semiBold),
            ],
            _BillingRow(
              label: 'discount'.tr,
              value: '(-) ${PriceConverter.convertPrice(billing.discount)}',
              tooltipMessage: discountSource?.labelKey.tr,
            ),
            if (isProDiscount)
              _BillingRow(label: 'discount_pro'.tr, value: '(-) ${PriceConverter.convertPrice(order.proDiscount)}'),
            if (isProCoupon)
              _BillingRow(label: 'coupon_discount_pro'.tr, value: '(-) ${PriceConverter.convertPrice((order.couponDiscountAmount ?? 0) > 0 ? order.couponDiscountAmount : billing.couponDiscount)}')
            else if (hasCouponDiscount)
              _BillingRow(label: 'coupon_discount'.tr, value: '(-) ${PriceConverter.convertPrice(billing.couponDiscount)}'),
            if (hasReferrerBonus)
              _BillingRow(label: 'referral_discount'.tr, value: '(-) ${PriceConverter.convertPrice(billing.referrerBonusAmount)}'),
            if (hasAdditionalCharge)
              _BillingRow(label: additionalChargeName, value: '(+) ${PriceConverter.convertPrice(billing.additionalCharge)}'),
            if (showVat) _BillingRow(label: 'vat_tax'.tr, value: '(+) ${PriceConverter.convertPrice(billing.tax)}'),
            if (hasDmTips)
              _BillingRow(label: 'delivery_man_tips'.tr, value: '(+) ${PriceConverter.convertPrice(billing.dmTips)}'),
            if (hasExtraPackaging)
              _BillingRow(label: 'extra_packaging'.tr, value: '(+) ${PriceConverter.convertPrice(billing.extraPackagingCharge)}'),
            _BillingRow(
              label: 'delivery_fee'.tr,
              value: billing.deliveryCharge > 0
                  ? '(+) ${PriceConverter.convertPrice(isProDeliveryFee ? billing.deliveryCharge + (order.deliveryFeeReductionAmount ?? 0) : billing.deliveryCharge)}'
                  : 'free'.tr,
              valueColor: billing.deliveryCharge > 0 ? null : context.primary,
            ),
            if (isProDeliveryFee)
              _BillingRow(
                label: 'delivery_fee_discount_pro'.tr,
                value: '(-) ${PriceConverter.convertPrice(order.deliveryFeeReductionAmount)}',
                tooltipMessage: _deliveryDiscountTooltip(order, billing),
              ),
            if (showDeliveryTypeCharge)
              _BillingRow(
                label: '${order.deliveryType!.replaceAll('_', ' ').capitalize} ${'delivery'.tr}',
                value: '${billing.deliveryTypeCharge < 0 ? '(-)' : '(+)'} ${PriceConverter.convertPrice(billing.deliveryTypeCharge.abs())}',
              ),

            Divider(height: Dimensions.paddingLarge),

            if (isSubscription) ...[
              _BillingRow(label: 'subtotal'.tr, value: PriceConverter.convertPrice(billing.total), style: context.heading.large.medium),
              _BillingRow(label: 'repeat_order'.tr, value: '$repeatQuantity', style: context.heading.large.medium),

              Divider(height: Dimensions.paddingLarge),

              _TotalAmountRow(
                total: billing.total * repeatQuantity,
                taxIncluded: billing.taxIncluded,
                paymentStatus: order.paymentStatus,
              ),
            ] else if (order.paymentMethod == 'partial_payment')
              _PartialPaymentTotal(order: order, total: billing.total, taxIncluded: billing.taxIncluded)
            else
              _TotalAmountRow(
                total: billing.total,
                taxIncluded: billing.taxIncluded,
                paymentStatus: order.paymentStatus,
              ),
          ]),
        ),
        crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 200),
      ),
    ]);
  }

  String _deliveryDiscountTooltip(OrderModel order, BillingValues billing) {
    final double reduction = order.deliveryFeeReductionAmount ?? 0;
    final double originalDeliveryCharge = billing.deliveryCharge + reduction;
    final double percentage = originalDeliveryCharge > 0 ? (reduction / originalDeliveryCharge) * 100 : 0;
    return '${percentage.toStringAsFixed(0)}% ${'delivery_fee_discount_applied'.tr}';
  }
}

class _BillingRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final String? tooltipMessage;
  final TextStyle? style;

  const _BillingRow({required this.label, required this.value, this.valueColor, this.tooltipMessage, this.style});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingDefault),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Flexible(
              child: Text(
                label,
                style: style ?? context.heading.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            if (tooltipMessage != null) ...[
              const SizedBox(width: Dimensions.padding2xSmall),
              CustomToolTip(
                message: tooltipMessage!,
                size: Dimensions.fontSizeLarge,
                preferredDirection: AxisDirection.up,
              ),
            ],
          ]),
        ),
        const SizedBox(width: Dimensions.paddingSmall),
        Text(
          value,
          style: style ?? context.heading.defaultSize.regular.overrideWith(color: valueColor),
          textDirection: TextDirection.ltr,
        ),
      ]),
    );
  }
}

class _TotalAmountRow extends StatelessWidget {
  final double total;
  final bool taxIncluded;
  final String? paymentStatus;

  const _TotalAmountRow({
    required this.total,
    required this.taxIncluded,
    required this.paymentStatus,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPaid = paymentStatus == 'paid';
    final bool hasStatus = paymentStatus == 'paid' || paymentStatus == 'unpaid';
    final Color statusColor = isPaid ? const Color(0xFF009F6B) : const Color(0xFFE53935);
    return Row(children: [
      Text('total'.tr, style: context.heading.extraLarge.overrideWith(color: context.textNeutralMedium)),
      if (taxIncluded)
        Text(
          ' ${'vat_tax_inc'.tr}',
          style: context.heading.small.overrideWith(color: context.textBaseMedium,),
        ),
      const Expanded(child: SizedBox()),

      if (hasStatus) ...[
        Text(
          paymentStatus!.tr,
          style: context.heading.small.overrideWith(color: statusColor),
        ),
        const SizedBox(width: Dimensions.padding2xSmall),
      ],
      Text(
        PriceConverter.convertPrice(total),
        style: context.heading.extraLarge,
        textDirection: TextDirection.ltr,
      ),
    ]);
  }
}

class _PartialPaymentTotal extends StatelessWidget {
  final OrderModel order;
  final double total;
  final bool taxIncluded;

  const _PartialPaymentTotal({required this.order, required this.total, required this.taxIncluded});

  @override
  Widget build(BuildContext context) {
    final primary = context.primary;
    return Container(
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          color: primary,
          strokeWidth: 1,
          strokeCap: StrokeCap.butt,
          dashPattern: const [8, 5],
          padding: const EdgeInsets.all(Dimensions.paddingSmall),
          radius: const Radius.circular(Dimensions.radiusDefault),
        ),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('total_amount'.tr,
                style: context.heading.defaultSize.overrideWith(color: primary)),
            Text(
              PriceConverter.convertPrice(total),
              style: context.heading.large.overrideWith(color: primary),
              textDirection: TextDirection.ltr,
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSmall),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('paid_by_wallet'.tr,
              style: context.heading.small.regular.overrideWith(color: context.textBaseMedium),
            ),
            Text(
              PriceConverter.convertPrice(order.payments?[0].amount ?? 0),
              style: context.heading.defaultSize.medium,
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSmall),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              '${order.payments?[1].paymentStatus == 'paid' ? 'paid_by'.tr : 'due_amount'.tr} (${order.payments?[1].paymentMethod?.tr ?? ''})',
              style: context.heading.small.regular.overrideWith(color: context.textBaseMedium),
            ),
            Text(
              PriceConverter.convertPrice(order.payments?[1].amount ?? 0),
              style: context.heading.defaultSize.medium,
            ),
          ]),
        ]),
      ),
    );
  }
}
