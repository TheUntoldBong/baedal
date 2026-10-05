import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:intl/intl.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/helper/color_coverter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class OrderItemStatusSection extends StatelessWidget {
  final OrderModel order;
  final double total;

  const OrderItemStatusSection({super.key, required this.order, required this.total});

  @override
  Widget build(BuildContext context) {
    final Color statusColor = ColorConverter.getStatusColor(order.orderStatus ?? '');
    final formatted = order.createdAt == null ? '' : DateFormat('d MMM, y h:mm a').format(DateTime.parse(order.createdAt!).toLocal());
    final type = (order.orderType == 'delivery' ? 'home_delivery'.tr : (order.orderType ?? '').tr);
    final payment = order.paymentMethod == 'cash_on_delivery' ? 'cash_on_delivery'.tr
                  : order.paymentMethod == 'wallet' ? 'wallet_payment'.tr
                  : order.paymentMethod == 'partial_payment' ? 'partial_payment'.tr
                  : order.paymentMethod == 'offline_payment' ? 'offline_payment'.tr : 'digital_payment'.tr;
    return Column( mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(
            '#ID ${order.id}',
            style: context.heading.large.strong,
          ),

          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: order.id.toString()));
              showCustomSnackBar('order_id_copied'.tr, isError: false);
            },
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.padding2xSmall),
              child: Icon(Icons.copy, size: 14, color: context.iconBaseMedium),
            ),
          ),
          const SizedBox(width: Dimensions.padding2xSmall),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
            ),
            child: Text(
              (order.orderStatus ?? '').tr.capitalizeFirst ?? '',
              style: context.subHeading.small.medium.overrideWith(color: statusColor),
            ),
          )
        ]),
        const SizedBox(height: Dimensions.padding2xSmall),

        Text(
          '${'order_placed'.tr.capitalize}: $formatted',
          style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
        ),

        Text(
          '${'order_type_is'.tr.capitalize} $type & ${'paid_by'.tr} $payment.',
          style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
        ),
        const SizedBox(height: Dimensions.paddingSmall)
      ],
    );
  }
}
