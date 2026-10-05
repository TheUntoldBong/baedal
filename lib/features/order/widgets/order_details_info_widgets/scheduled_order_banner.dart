import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get_utils/get_utils.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ScheduledOrderBanner extends StatelessWidget {
  final OrderModel order;

  const ScheduledOrderBanner({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final Color primary = context.primary;
    final String scheduledTime = order.scheduleAt != null ? DateConverter.dateTimeStringToDateTime(order.scheduleAt!) : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.paddingSmall),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary.withValues(alpha: 0.12), primary.withValues(alpha: 0.04)],
        ),
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
        border: Border.all(color: primary.withValues(alpha: 0.25)),
      ),
      child: Row(children: [
        Container(
          height: 30, width: 30,
          decoration: BoxDecoration(color: primary.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(Icons.event_available_rounded, color: primary, size: 16),
        ),
        const SizedBox(width: Dimensions.paddingSmall),

        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(
            'scheduled_order'.tr,
            style: context.subHeading.small.medium.overrideWith(color: primary),
          ),
          const SizedBox(height: 1),

          Row(children: [
            Icon(Icons.access_time_rounded, size: 12, color: context.iconBaseMedium),
            const SizedBox(width: Dimensions.padding2xSmall),
            Flexible(child: Text(
              scheduledTime,
              style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium),
            )),
          ]),
        ])),
      ]),
    );
  }
}
