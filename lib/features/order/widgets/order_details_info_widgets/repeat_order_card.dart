import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/order/domain/models/subscription_schedule_model.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

const List<String> _weekDays = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];

class RepeatOrderCard extends StatelessWidget {
  final SubscriptionModel subscription;
  final List<SubscriptionScheduleModel> schedules;

  const RepeatOrderCard({super.key, required this.subscription, this.schedules = const []});


  static int occurrenceCount(SubscriptionModel subscription, List<SubscriptionScheduleModel> schedules) {
    final int fallback = subscription.quantity ?? 0;
    final DateTime? start = DateTime.tryParse(subscription.startAt ?? '');
    final DateTime? end = DateTime.tryParse(subscription.endAt ?? '');
    if (start == null || end == null || end.isBefore(start)) return fallback;

    final int totalDays = DateTime(end.year, end.month, end.day).difference(DateTime(start.year, start.month, start.day)).inDays + 1;

    if (subscription.type == 'daily') return totalDays;

    final Set<int> days = schedules.where((s) => s.day != null).map((s) => s.day!).toSet();
    if (days.isEmpty) return fallback;

    int count = 0;
    for (int i = 0; i < totalDays; i++) {
      final DateTime day = DateTime(start.year, start.month, start.day + i);
      if (subscription.type == 'weekly') {
        if (days.contains(day.weekday % 7)) count++;
      } else if (subscription.type == 'monthly') {
        if (days.contains(day.day)) count++;
      } else {
        return fallback;
      }
    }
    return count;
  }

  void _openOverview() {
    Get.bottomSheet(
      RepeatOrderOverviewSheet(subscription: subscription, schedules: schedules),
      backgroundColor: Colors.transparent, isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final int count = occurrenceCount(subscription, schedules);

    return InkWell(
      onTap: _openOverview,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Dimensions.paddingSmall),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Row(children: [

          Container(
            height: 36, width: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Icon(Icons.event_repeat_rounded, size: 20, color: context.iconBaseMedium),
          ),
          const SizedBox(width: Dimensions.paddingSmall),

          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text('repeat_order'.tr, style: context.heading.large),
            const SizedBox(height: 2),
            RichText(
              maxLines: 2, overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: context.subHeading.small.overrideWith(color: context.textBaseMedium),
                children: [
                  TextSpan(text: '${'you_will_receive_this_order'.tr} '),
                  TextSpan(
                    text: '$count ${count > 1 ? 'times'.tr : 'time'.tr}',
                    style: context.subHeading.small.strong.overrideWith(color: context.textBaseDefault),
                  ),
                ],
              ),
            ),
          ])),
          const SizedBox(width: Dimensions.padding2xSmall),

          Icon(
            Get.find<LocalizationController>().isLtr ? Icons.arrow_forward : Icons.arrow_back,
            size: 20, color: Colors.blueAccent,
          ),

        ]),
      ),
    );
  }
}

class RepeatOrderOverviewSheet extends StatelessWidget {
  final SubscriptionModel subscription;
  final List<SubscriptionScheduleModel> schedules;

  const RepeatOrderOverviewSheet({super.key, required this.subscription, this.schedules = const []});

  String _formatDate(String? date) {
    final DateTime? parsed = DateTime.tryParse(date ?? '');
    return parsed == null ? '' : DateFormat('d MMM, yyyy').format(parsed);
  }

  String _formatTime(String? time) => (time == null || time.isEmpty) ? '' : DateConverter.convertTimeToTime(time);

  String get _note => switch (subscription.type) {
    'weekly' => 'scheduled_within_the_selected_weekdays'.tr,
    'monthly' => 'this_order_will_continue_during_your_selected_schedule'.tr,
    _ => 'this_order_will_continue_on_the_selected_days'.tr,
  };

  String _scheduleLabel(SubscriptionScheduleModel schedule) {
    if (schedule.day == null) return '';
    if (subscription.type == 'weekly') {
      return schedule.day! < _weekDays.length ? _weekDays[schedule.day!].tr : '';
    }
    final DateTime? start = DateTime.tryParse(subscription.startAt ?? '');
    if (start == null) return '${'day_capital'.tr} ${schedule.day}';
    final DateTime occurrence = schedule.day! >= start.day
        ? DateTime(start.year, start.month, schedule.day!)
        : DateTime(start.year, start.month + 1, schedule.day!);
    return DateFormat('d MMM, yyyy').format(occurrence);
  }

  @override
  Widget build(BuildContext context) {
    final Color disabled = context.surface;
    final int count = RepeatOrderCard.occurrenceCount(subscription, schedules);
    final String startAt = _formatDate(subscription.startAt);
    final String endAt = _formatDate(subscription.endAt);
    final bool isDaily = subscription.type == 'daily' || subscription.type == null;
    final List<SubscriptionScheduleModel> listed = isDaily ? const [] : schedules.where((s) => s.day != null).toList();

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Flexible(child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(Dimensions.paddingDefault, 0, Dimensions.paddingDefault, Dimensions.paddingLarge),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

              Stack(alignment: Alignment.topCenter, children: [
                Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(top: Dimensions.paddingSmall),
                    child: Container(
                      width: 36, height: 2,
                      decoration: BoxDecoration(
                        color: disabled.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  SizedBox(height: Dimensions.paddingExtraLarge,),


                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'repeat_order_overview'.tr, textAlign: TextAlign.center,
                      style: context.heading.extraLarge,
                    ),
                  ),
                  const SizedBox(height: Dimensions.padding2xSmall),
                  Text(_note, textAlign: TextAlign.center, style: context.subHeading.defaultSize.overrideWith(color: context.textBaseMedium)),
                ]),

                Positioned(
                  right: 0, top: 10,
                  child: InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 28, height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: disabled.withValues(alpha: 0.12), shape: BoxShape.circle),
                      child: Icon(Icons.close, size: 18, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingLarge),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingLarge),
                decoration: BoxDecoration(
                  color: disabled.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Column(children: [

                  if (isDaily && schedules.isNotEmpty && _formatTime(schedules.first.time).isNotEmpty) ...[
                    _SummaryLine(
                      spans: [
                        _Span('${'daily'.tr} ${'at'.tr} ', bold: false),
                        _Span(_formatTime(schedules.first.time)),
                      ],
                      size: Dimensions.fontSizeLarge,
                    ),
                    const SizedBox(height: Dimensions.paddingSmall),
                  ],

                  if (startAt.isNotEmpty && endAt.isNotEmpty) ...[
                    _SummaryLine(spans: [
                      _Span('${'from'.tr} ', bold: false),
                      _Span(startAt),
                      _Span(' ${'to'.tr} ', bold: false),
                      _Span(endAt),
                    ]),
                    const SizedBox(height: Dimensions.paddingSmall),
                  ],

                  _SummaryLine(spans: [
                    _Span('${'you_will_receive_this_order'.tr} ', bold: false),
                    _Span('$count ${count > 1 ? 'times'.tr : 'time'.tr}'),
                  ]),

                ]),
              ),

              if (listed.isNotEmpty) ...[
                const SizedBox(height: Dimensions.paddingExtraLarge),

                Text('${'scheduled_list'.tr} (${listed.length})', style: context.heading.defaultSize),
                const SizedBox(height: 2),
                Text('your_order_will_be_available_on'.tr, style: context.subHeading.small.overrideWith(color: context.textBaseMedium)),
                const SizedBox(height: Dimensions.paddingDefault),

                for (final schedule in listed) ...[
                  _ScheduleRow(label: _scheduleLabel(schedule), time: _formatTime(schedule.time)),
                  const SizedBox(height: Dimensions.paddingMedium),
                ],
              ],

            ]),
          )),

        ]),
      ),
    );
  }
}

class _Span {
  final String text;
  final bool bold;

  const _Span(this.text, {this.bold = true});
}

class _SummaryLine extends StatelessWidget {
  final List<_Span> spans;
  final double? size;

  const _SummaryLine({required this.spans, this.size});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: context.subHeading.defaultSize.overrideWith(color: context.textBaseMedium),
        children: spans.map((span) => TextSpan(
          text: span.text,
          style: span.bold ? context.subHeading.defaultSize.strong.overrideWith(color: context.textBaseDefault) : null,
        )).toList(),
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final String label;
  final String time;

  const _ScheduleRow({required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingMedium),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Row(children: [

        Icon(Icons.calendar_today_outlined, size: 16, color: context.iconBaseMedium),
        const SizedBox(width: Dimensions.paddingSmall),
        Expanded(child: Text(label, style: context.heading.defaultSize.medium)),

        if (time.isNotEmpty) ...[
          Icon(Icons.access_time_rounded, size: 16, color: context.iconBaseMedium),
          const SizedBox(width: Dimensions.padding2xSmall),
          Text(time, style: context.heading.defaultSize.medium),
        ],

      ]),
    );
  }
}
