import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/order/widgets/order_status_history_sheet.dart';
import 'package:stackfood_multivendor/helper/color_coverter.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/delivery_time_helper.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class OrderStatusCard extends StatelessWidget {
  final OrderModel order;
  final bool ongoing;
  final bool floating;
  final double total;
  final bool arrivalState;

  const OrderStatusCard({super.key, required this.order, required this.ongoing, this.floating = false, this.total = 0, this.arrivalState = false});

  void _showHistorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => OrderStatusHistorySheet(order: order),
    );
  }

  static String? arrivalRange(OrderModel order) {
    if (order.eta?.fromAt != null && order.eta?.toAt != null) {
      try {
        final DateTime fromAt = DateTime.parse(order.eta!.fromAt!).toLocal();
        final DateTime toAt = DateTime.parse(order.eta!.toAt!).toLocal();
        final DateTime now = DateTime.now();

        if (!toAt.isBefore(now.subtract(const Duration(minutes: 2)))) {
          return DateConverter.timeRange(fromAt, toAt);
        }
      } catch (_) {}
    }

    final List<int> store = DeliveryTimeHelper.parseStoreMinutes(order.restaurant?.deliveryTime);
    final int processing = order.processingTime ?? 0;

    int minMinutes;
    int maxMinutes;
    if (store.isNotEmpty) {
      minMinutes = store[0];
      maxMinutes = store[1] + processing;
    } else if (processing > 0) {
      minMinutes = processing;
      maxMinutes = processing;
    } else if (order.eta?.min != null && order.eta?.max != null && order.eta!.min! > 0) {
      minMinutes = order.eta!.min!;
      maxMinutes = order.eta!.max!;
    } else {
      minMinutes = 25;
      maxMinutes = 35;
    }

    final String? baseStr = order.createdAt;
    try {
      DateTime base = baseStr != null ? DateTime.parse(baseStr).toLocal() : DateTime.now();
      if (base.add(Duration(minutes: maxMinutes)).isBefore(DateTime.now())) {
        base = DateTime.now();
        minMinutes = 5;
        maxMinutes = 15;
      }
      final List<DateTime> arrival = DeliveryTimeHelper.arrivalWindow(base, minMinutes, maxMinutes);
      return DateConverter.timeRange(arrival[0], arrival[1]);
    } catch (_) {
      final List<DateTime> arrival = DeliveryTimeHelper.arrivalWindow(DateTime.now(), 5, 15);
      return DateConverter.timeRange(arrival[0], arrival[1]);
    }
  }

  static String? scheduledAtFor(OrderModel order) {
    if (order.scheduled != 1) {
      return null;
    }

    final String? window = scheduledWindow(order);
    if (window != null) {
      return window;
    }

    try {
      return DateConverter.dateTimeStringToDateTime(order.scheduleAt!);
    } catch (_) {
      return null;
    }
  }

  static String? scheduledWindow(OrderModel order) {
    final String? window = order.eta?.window?.trim();
    if (window == null || window.isEmpty) {
      return null;
    }

    final String? day = _dayLabel(order.eta?.fromAt ?? order.scheduleAt);
    return day == null ? window : '$day, $window';
  }

  static String? _dayLabel(String? stamp) {
    if (stamp == null || stamp.length < 10) {
      return null;
    }
    try {
      final DateTime day = DateTime.parse(stamp.substring(0, 10));
      if (DateConverter.isToday(day)) {
        return 'today'.tr;
      }
      if (DateConverter.isTomorrow(day)) {
        return 'tomorrow'.tr;
      }
      return DateFormat('dd MMM').format(day);
    } catch (_) {
      return null;
    }
  }

  String? _deliveredTime() {
    if (order.delivered == null) return null;
    try {
      return DateConverter.dateToTimeOnly(DateTime.parse(order.delivered!).toLocal());
    } catch (_) {
      return null;
    }
  }

  String _deliveredPrefix() => 'delivered'.tr;

  String _deliveredDetailRest() {
    final String? time = _deliveredTime();
    if (time == null) return ', ${'thank_you_for_choosing'.tr}!';
    return ' ${'at'.tr} $time, ${'thank_you_for_choosing'.tr}!';
  }

  @override
  Widget build(BuildContext context) {
    final _StatusContent content = _StatusContent.resolve(order);
    final Color statusColor = ColorConverter.getStatusColor(order.orderStatus ?? '');
    final bool isDelivered = order.orderStatus == 'delivered';

    final bool isSubscription = order.subscription != null;
    final String? paymentStatus = (order.paymentStatus == 'paid' || order.paymentStatus == 'unpaid') ? order.paymentStatus : null;
    final Color paymentStatusColor = order.paymentStatus == 'paid' ? const Color(0xFF009F6B) : const Color(0xFFE53935);

    final bool isDineIn = order.orderType == 'dine_in';
    final String? dineInAt = (isDineIn && ongoing) ? DateConverter.dineInDateTime(order.scheduleAt) : null;

    final String? scheduledAt = (ongoing && !isDineIn) ? scheduledAtFor(order) : null;
    final bool showScheduled = scheduledAt != null;
    final bool scheduledFromEta = showScheduled && scheduledWindow(order) != null;

    final String? arrival = (ongoing && !isDineIn && (!showScheduled || isSubscription)) ? arrivalRange(order) : null;
    final bool showArrival = arrival != null;
    final bool ltrHeadline = dineInAt != null || showArrival || (showScheduled && !isSubscription);

    final String? topLabel = dineInAt != null
        ? 'dine_in_date'.tr
        : showArrival ? 'estimated_arrival'.tr
        : showScheduled ? (scheduledFromEta ? 'estimated_arrival_scheduled'.tr : 'scheduled_at'.tr)
        : (isDelivered ? content.title : null);
    final String headline = dineInAt ?? (showArrival ? arrival
        : isSubscription ? 'repeat_order'.tr
        : showScheduled ? scheduledAt
        : (isDelivered ? 'enjoy_your_food_short'.tr : content.title));

    return Padding(
      padding: floating ? const EdgeInsets.all(Dimensions.paddingDefault) : EdgeInsets.zero,
      child: Material(
      color: context.surfaceContainer,
      borderRadius: floating ? BorderRadius.circular(Dimensions.radiusLarge) : null,
      clipBehavior: floating ? Clip.antiAlias : Clip.none,
      elevation: floating ? 4 : 0,
      shadowColor: floating ? context.shadow : null,
      child: InkWell(
        onTap: () => _showHistorySheet(context),
        child: Padding(
          padding: EdgeInsets.only(
            left: Dimensions.paddingDefault,
            right: Dimensions.paddingDefault,
            top: floating ? Dimensions.paddingDefault : Dimensions.paddingLarge,
            bottom: floating ? Dimensions.paddingDefault : 0,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (topLabel != null) ...[
                    Text(
                      topLabel,
                      style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                    ),
                    const SizedBox(height: Dimensions.padding2xSmall),
                  ],

                  Text(
                    headline,
                    style: context.heading.extraLarge.strong,
                    textDirection: ltrHeadline ? TextDirection.ltr : null,
                  ),
                  const SizedBox(height: Dimensions.padding2xSmall),

                  RichText(
                    text: TextSpan(
                      style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                      children: isDelivered
                          ? [
                              TextSpan(
                                text: _deliveredPrefix(),
                                style: context.body.small.medium.overrideWith(color: statusColor),
                              ),
                              TextSpan(text: _deliveredDetailRest()),
                            ]
                          : [
                              TextSpan(text: '${'your_order_is'.tr} '),
                              TextSpan(
                                text: (order.orderStatus ?? '').tr.capitalizeFirst ?? '',
                                style: context.body.defaultSize.regular.copyWith(fontSize: Dimensions.fontSizeSmall, color: statusColor),
                              ),
                              TextSpan(text: content.sentence),
                            ],
                    ),
                  ),

                  if (isSubscription) ...[
                    const SizedBox(height: Dimensions.paddingSmall),
                    Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                      Text(
                        PriceConverter.convertPrice(total),
                        style: context.body.defaultSize.regular.copyWith(fontSize: Dimensions.fontSizeLarge),
                        textDirection: TextDirection.ltr,
                      ),
                      if (paymentStatus != null) ...[
                        const SizedBox(width: Dimensions.paddingSmall),
                        Text(
                          paymentStatus.tr,
                          style: context.body.defaultSize.regular.copyWith(fontSize: Dimensions.fontSizeSmall, color: paymentStatusColor),
                        ),
                      ],
                    ]),
                  ],
                ]),
              ),
              const SizedBox(width: Dimensions.paddingSmall),

              Icon(
                Get.find<LocalizationController>().isLtr ? Icons.arrow_forward : Icons.arrow_back,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                size: 20,
              ),
            ]),

            if (!floating || arrivalState) ...[
              const SizedBox(height: Dimensions.paddingLarge),
              Divider(height: 1, thickness: 1),
            ],
          ]),
        ),
      ),
    ),
    );
  }
}

class _StatusContent {
  final String title;
  final String sentence;
  const _StatusContent({required this.title, required this.sentence});

  static _StatusContent resolve(OrderModel order) {
    return _StatusContent(title: _StatusTitle.resolve(order.orderStatus), sentence: _StatusSentence.resolve(order));
  }
}

class _StatusTitle {
  static String resolve(String? status) {
    if (status == 'delivered') return 'your_order_has_arrived'.tr;
    if (status == 'canceled' || status == 'failed') return 'order_cancelled'.tr;
    return (status ?? '').tr.capitalizeFirst ?? '';
  }
}

class _StatusSentence {
  static String resolve(OrderModel order) {
    final String? status = order.orderStatus;
    switch (status) {
      case 'pending':
        return '. ${'waiting_for_confirmation'.tr}';
      case 'accepted':
      case 'confirmed':
        return ' ${'being_prepared'.tr}';
      case 'processing':
        return '. ${'order_processing_detail'.trParams({'min': '${order.processingTime ?? 30}'})}';
      case 'handover':
        return '. ${'order_handover_detail'.tr}';
      case 'picked_up':
        return '. ${'order_out_for_delivery_detail'.tr}';
      case 'canceled':
      case 'failed':
        return '.';
      default:
        return '';
    }
  }
}
