import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/custom_date_picker.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/time_wheel_bottom_sheet.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class SubscriptionScheduleBottomSheet extends StatefulWidget {
  final CheckoutController checkoutController;
  const SubscriptionScheduleBottomSheet({
    super.key,
    required this.checkoutController,
  });

  @override
  State<SubscriptionScheduleBottomSheet> createState() =>
      _SubscriptionScheduleBottomSheetState();
}

class _SubscriptionScheduleBottomSheetState
    extends State<SubscriptionScheduleBottomSheet> {
  static const List<String> _weekDays = [
    'sunday',
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
  ];

  late String _type;
  DateTimeRange? _range;
  late List<DateTime?> _selectedDays;
  final ScrollController _scrollController = ScrollController();
  static const double _collapseDistance = 56;

  @override
  void initState() {
    super.initState();
    _type = widget.checkoutController.subscriptionType ?? 'daily';
    _range = widget.checkoutController.subscriptionRange;
    _selectedDays = List<DateTime?>.from(
      widget.checkoutController.selectedDays,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int _weekdayIndexOf(DateTime date) => date.weekday % 7;

  bool _todayInRange() {
    if (_range == null) return false;
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime start = DateTime(
      _range!.start.year,
      _range!.start.month,
      _range!.start.day,
    );
    final DateTime end = DateTime(
      _range!.end.year,
      _range!.end.month,
      _range!.end.day,
    );
    return !today.isBefore(start) && !today.isAfter(end);
  }

  bool _weekdayIncludesToday(int weekdayIndex) =>
      _todayInRange() && _weekdayIndexOf(DateTime.now()) == weekdayIndex;

  bool _monthDayIncludesToday(int dayOfMonth) =>
      (_range == null || _todayInRange()) && DateTime.now().day == dayOfMonth;

  Map<int, DateTime> _weekdayFirstDatesInRange() {
    final Map<int, DateTime> dates = {};
    if (_range == null) return dates;
    final int totalDays = _range!.duration.inDays + 1;
    DateTime cursor = _range!.start;
    for (int i = 0; i < totalDays; i++) {
      dates.putIfAbsent(_weekdayIndexOf(cursor), () => cursor);
      cursor = cursor.add(const Duration(days: 1));
    }
    return dates;
  }

  List<int> _visibleWeekdayIndices() {
    final Map<int, DateTime> dates = _weekdayFirstDatesInRange();
    if (_range == null || dates.length >= 7)
      return List<int>.generate(7, (i) => i);
    final List<int> indices = dates.keys.toList()
      ..sort((a, b) => dates[a]!.compareTo(dates[b]!));
    return indices;
  }

  Map<int, DateTime> _monthDayFirstDatesInRange() {
    final Map<int, DateTime> dates = {};
    if (_range == null) return dates;
    final int totalDays = _range!.duration.inDays + 1;
    DateTime cursor = _range!.start;
    for (int i = 0; i < totalDays; i++) {
      dates.putIfAbsent(cursor.day, () => cursor);
      cursor = cursor.add(const Duration(days: 1));
    }
    return dates;
  }

  List<int> _visibleMonthDays() {
    if (_range == null) {
      final DateTime now = DateTime.now();
      final int lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
      return List<int>.generate(
        lastDayOfMonth - now.day + 1,
        (i) => now.day + i,
      );
    }
    final Map<int, DateTime> dates = _monthDayFirstDatesInRange();
    final List<int> days = dates.keys.toList()
      ..sort((a, b) => dates[a]!.compareTo(dates[b]!));
    return days;
  }

  List<int> _activeIndices() {
    if (_type == 'daily') return const [0];
    if (_type == 'weekly') return _visibleWeekdayIndices();
    return _visibleMonthDays().map((day) => day - 1).toList();
  }

  bool get _hasDate => _range != null;

  bool get _hasTime => _activeIndices().any(
    (index) => index < _selectedDays.length && _selectedDays[index] != null,
  );

  String? get _confirmBlockedMessage {
    if (!_hasDate) return 'choose_subscription_date'.tr;
    if (!_hasTime) return 'select_time_for_the_dates'.tr;
    return null;
  }

  Future<void> _pickTimeFor(int index, TimeOfDay? minTime) async {
    TimeOfDay? time = await TimeWheelBottomSheet.pick(
      context,
      initialTime: TimeOfDay.now(),
      minTime: minTime,
    );
    if (time != null && mounted) {
      final now = DateTime.now();
      setState(
        () => _selectedDays[index] = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        ),
      );
    }
  }

  void _onDatePicked(DateTimeRange range) {
    setState(() => _range = range);
    if (_type == 'daily') {
      _pickTimeFor(0, _todayInRange() ? TimeOfDay.now() : null);
    }
  }

  void _confirm() {
    if (_range != null) {
      widget.checkoutController.setSubscriptionRange(_range!, notify: false);
    }
    for (int index = 0; index < _selectedDays.length; index++) {
      final entry = _selectedDays[index];
      widget.checkoutController.addDay(
        index,
        entry != null
            ? TimeOfDay(hour: entry.hour, minute: entry.minute)
            : null,
        notify: false,
      );
    }
    widget.checkoutController.update();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      width: isDesktop ? 500 : double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingLarge),
      constraints: BoxConstraints(
        maxHeight: context.height,
        minHeight: context.height,
      ),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: isDesktop
            ? BorderRadius.circular(Dimensions.radiusDefault)
            : const BorderRadius.vertical(
                top: Radius.circular(Dimensions.radiusExtraLarge),
              ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Dimensions.paddingExtraLarge),
            AnimatedBuilder(
              animation: _scrollController,
              builder: (context, child) {
                final double offset = _scrollController.hasClients
                    ? _scrollController.offset
                    : 0;
                final double t = (offset / _collapseDistance).clamp(0.0, 1.0);
                const double arrowSize = 18;
                const double titleLineHeight = 30;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height:
                          titleLineHeight +
                          (arrowSize + Dimensions.paddingDefault) * (1 - t),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.lerp(
                              Alignment.topLeft,
                              Alignment.centerLeft,
                              t,
                            )!,
                            child: InkWell(
                              onTap: () => Get.back(),
                              child: Icon(
                                Icons.arrow_back,
                                size: arrowSize,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.lerp(
                              Alignment.bottomLeft,
                              Alignment.centerLeft,
                              t,
                            )!,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: (arrowSize + Dimensions.paddingSmall) * t,
                              ),
                              child: Text(
                                'select_date_and_time'.tr,
                                style: context.heading.extraLarge.strong,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Opacity(
                      opacity: t,
                      child: Container(
                        height: 1,
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                          top: Dimensions.padding2xSmall,
                        ),
                        color: context.bgNeutralLight,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: Dimensions.padding2xSmall),

            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'choose_preferable_date_and_time_when_you_want_delivery'
                          .tr,
                      style: context.body.defaultSize.regular.overrideWith(
                        color: context.textBaseMedium,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingDefault),

                    Text(
                      'select_date_range'.tr,
                      style: context.subHeading.defaultSize.regular,
                    ),
                    const SizedBox(height: Dimensions.paddingSmall),

                    InkWell(
                      onTap: () => CustomDatePicker.pickRange(
                        context,
                        range: _range,
                        isPause: false,
                        onDatePicked: _onDatePicked,
                      ),
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingDefault,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusExtraSmall + 2,
                          ),
                          border: Border.all(color: context.outline),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _range != null
                                    ? DateConverter.dateRangeToDate(_range!)
                                    : 'choose_subscription_date'.tr,
                                style: context.subHeading.defaultSize.regular,
                              ),
                            ),
                            CustomAssetImageWidget(
                              Images.calendarClockIcon,
                              width: 20,
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingLarge),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                        Dimensions.paddingSmall + 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.surfaceContainer,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusDefault,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'select_time_for_the_dates'.tr,
                            style: context.heading.defaultSize.strong,
                          ),
                          const SizedBox(height: Dimensions.paddingSmall),

                          _type == 'daily'
                              ? _dayTile(
                                  label: null,
                                  index: 0,
                                  height: _tileHeight(context),
                                  minTime: _todayInRange()
                                      ? TimeOfDay.now()
                                      : null,
                                )
                              : _type == 'weekly'
                              ? _weeklyGrid(context)
                              : _monthlyGrid(context),
                        ],
                      ),
                    ),
                    SizedBox(height: Dimensions.paddingSmall),
                  ],
                ),
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: CustomButtonWidget(
                    buttonText: 'cancel'.tr,
                    fontSize: Dimensions.fontSizeDefault,
                    color: context.surface,
                    textColor: Theme.of(context).textTheme.bodyLarge?.color,
                    onPressed: () => Get.back(),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSmall),

                Expanded(
                  child: CustomButtonWidget(
                    buttonText: 'confirm'.tr,
                    fontSize: Dimensions.fontSizeDefault,
                    onPressed: (_hasDate && _hasTime) ? _confirm : null,
                    disabledMessage: _confirmBlockedMessage,
                    disabledColor: context.surface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _tileHeight(BuildContext context) =>
      (context.height * 0.06).clamp(44.0, 60.0);

  Widget _weeklyGrid(BuildContext context) {
    double tileHeight = _tileHeight(context);
    final List<int> visibleIndices = _visibleWeekdayIndices();

    if (_range == null || visibleIndices.length == 7) {
      return Column(
        children: [
          for (int row = 0; row < 3; row++) ...[
            Row(
              children: [
                Expanded(
                  child: _dayTile(
                    label: _weekDays[row * 2].tr,
                    index: row * 2,
                    height: tileHeight,
                    minTime: _weekdayIncludesToday(row * 2)
                        ? TimeOfDay.now()
                        : null,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSmall),
                Expanded(
                  child: _dayTile(
                    label: _weekDays[row * 2 + 1].tr,
                    index: row * 2 + 1,
                    height: tileHeight,
                    minTime: _weekdayIncludesToday(row * 2 + 1)
                        ? TimeOfDay.now()
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSmall),
          ],
          _dayTile(
            label: _weekDays[6].tr,
            index: 6,
            height: tileHeight,
            minTime: _weekdayIncludesToday(6) ? TimeOfDay.now() : null,
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double tileWidth =
            (constraints.maxWidth - Dimensions.paddingSmall) / 2;
        return Wrap(
          spacing: Dimensions.paddingSmall,
          runSpacing: Dimensions.paddingSmall,
          children: [
            for (final index in visibleIndices)
              SizedBox(
                width: tileWidth,
                child: _dayTile(
                  label: _weekDays[index].tr,
                  index: index,
                  height: tileHeight,
                  minTime: _weekdayIncludesToday(index)
                      ? TimeOfDay.now()
                      : null,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _monthlyGrid(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    DateTime baseDate = _range?.start ?? DateTime.now();
    final List<int> visibleDays = _visibleMonthDays();
    final Map<int, DateTime> firstDates = _monthDayFirstDatesInRange();

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 5 : 3,
        crossAxisSpacing: Dimensions.paddingSmall,
        mainAxisSpacing: Dimensions.paddingSmall,
        childAspectRatio: 2,
      ),
      itemCount: visibleDays.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemBuilder: (context, i) {
        final int dayOfMonth = visibleDays[i];
        final int index = dayOfMonth - 1;
        DateTime tileDate = _range != null
            ? firstDates[dayOfMonth]!
            : DateTime(baseDate.year, baseDate.month, dayOfMonth);
        bool isSelected = _selectedDays[index] != null;
        final TimeOfDay? minTime = _monthDayIncludesToday(dayOfMonth)
            ? TimeOfDay.now()
            : null;

        return InkWell(
          onTap: () {
            if (isSelected) {
              setState(() => _selectedDays[index] = null);
            } else {
              _pickTimeFor(index, minTime);
            }
          },
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.padding2xSmall,
            ),
            decoration: BoxDecoration(
              color: isSelected ? context.surfaceContainer : Colors.transparent,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: context.outline),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('dd MMM, yyyy').format(tileDate),
                  style: context.subHeading.defaultSize.regular,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                if (isSelected)
                  Text(
                    DateConverter.dateToTimeOnly(_selectedDays[index]!),
                    style: context.heading.small.strong.overrideWith(
                      color: Colors.blueAccent,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dayTile({
    required String? label,
    required int index,
    double? height,
    TimeOfDay? minTime,
  }) {
    bool isSelected = _selectedDays[index] != null;
    return InkWell(
      onTap: () {
        if (isSelected) {
          setState(() => _selectedDays[index] = null);
        } else {
          _pickTimeFor(index, minTime);
        }
      },
      child: Container(
        height: height ?? (label == null ? _tileHeight(context) : null),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: context.outline),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null)
              Text(
                label,
                style: context.subHeading.defaultSize.regular,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (label == null)
              Text(
                isSelected
                    ? DateConverter.dateToTimeOnly(_selectedDays[index]!)
                    : 'choose_time'.tr,
                style: context.subHeading.defaultSize.regular,
              ),
            if (label != null && isSelected)
              Text(
                DateConverter.dateToTimeOnly(_selectedDays[index]!),
                style: context.heading.small.strong.overrideWith(
                  color: Colors.blueAccent,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
