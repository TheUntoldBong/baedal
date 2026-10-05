import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class OrderNotesPanel extends StatelessWidget {
  final OrderModel order;

  const OrderNotesPanel({super.key, required this.order});

  static bool _isNotBlank(String? s) {
    if (s == null) return false;
    final trimmed = s.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.toLowerCase() == 'null') return false;
    return true;
  }

  static bool hasContent(OrderModel order) {
    return _isNotBlank(order.deliveryInstruction) || _isNotBlank(order.unavailableItemNote)
        || _isNotBlank(order.orderNote) || (order.bringChangeAmount != null && order.bringChangeAmount! > 0);
  }

  @override
  Widget build(BuildContext context) {
    final hasInstruction = _isNotBlank(order.deliveryInstruction);
    final hasUnavailable = _isNotBlank(order.unavailableItemNote);
    final hasOrderNote = _isNotBlank(order.orderNote);
    final hasBringChangeAmount = order.bringChangeAmount != null && order.bringChangeAmount! > 0;

    if (!hasInstruction && !hasUnavailable && !hasOrderNote && !hasBringChangeAmount) {
      return const SizedBox.shrink();
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (hasInstruction || hasUnavailable || hasOrderNote)
        _BlueNotesPanel(
          instruction: hasInstruction ? order.deliveryInstruction : null,
          unavailable: hasUnavailable ? order.unavailableItemNote : null,
          additionalNote: hasOrderNote ? order.orderNote : null,
        ),
      if (hasBringChangeAmount) ...[
        const SizedBox(height: Dimensions.paddingSmall),
        _AdditionalNotePanel(amount: order.bringChangeAmount!),
      ],
    ]);
  }
}

class _BlueNotesPanel extends StatelessWidget {
  final String? instruction;
  final String? unavailable;
  final String? additionalNote;

  const _BlueNotesPanel({required this.instruction, required this.unavailable, required this.additionalNote});

  @override
  Widget build(BuildContext context) {
    final bool hasNoteAbove = instruction != null || unavailable != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSmall),
      decoration: BoxDecoration(
        color: Colors.blue.shade100.withAlpha(60),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (instruction != null)
          _NoteSection(title: 'delivery_instruction'.tr, body: instruction!),
        if (instruction != null && unavailable != null)
          Divider(height: 10, thickness: 1,),
        if (unavailable != null)
          _NoteSection(title: 'if_item_unavailable'.tr, body: unavailable!),
        if (hasNoteAbove && additionalNote != null)
          Divider(height: 10, thickness: 1,),
        if (additionalNote != null)
          _NoteSection(title: 'additional_note'.tr, body: additionalNote!),
      ]),
    );
  }
}

class _AdditionalNotePanel extends StatelessWidget {
  final double amount;

  const _AdditionalNotePanel({required this.amount});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSmall),
      decoration: BoxDecoration(
        color: context.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: RichText(
        text: TextSpan(children: [
          TextSpan(text: 'please_bring'.tr, style: context.subHeading.defaultSize.copyWith(color: textColor)),
          TextSpan(text: ' ${PriceConverter.convertPrice(amount)}', style: context.subHeading.defaultSize.semiBold.copyWith(color: textColor)),
          TextSpan(text: ' ${'in_change_when_making_the_delivery'.tr}', style: context.subHeading.defaultSize.copyWith(color: textColor)),
        ]),
      ),
    );
  }
}

class _NoteSection extends StatelessWidget {
  final String title;
  final String body;

  const _NoteSection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: context.subHeading.defaultSize),
      const SizedBox(height: 2),
      Text(body.tr, style: context.subHeading.small.overrideWith(color: context.textBaseMedium)),
    ]);
  }
}
