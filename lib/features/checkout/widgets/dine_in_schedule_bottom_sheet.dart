import 'package:flutter/cupertino.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/dine_in_date_select_bottom_sheet.dart' show checkRestaurantClose;
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/dine_in_schedule_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DineInScheduleBottomSheet extends StatefulWidget {
  final Restaurant restaurant;

  final DateTime? scheduleEndsAt;

  const DineInScheduleBottomSheet({super.key, required this.restaurant, this.scheduleEndsAt});

  @override
  State<DineInScheduleBottomSheet> createState() => _DineInScheduleBottomSheetState();
}

class _DineInScheduleBottomSheetState extends State<DineInScheduleBottomSheet> {
  DateTime? _selectedDate;
  int _hour12 = 12;
  int _minute = 0;
  bool _isPM = true;

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  DateTime get _today => DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  DateTime? get _maxSelectableDate {
    final int? days = Get.find<SplashController>().configModel?.customerOrderDate;
    final DateTime? storeMax = (days == null || days <= 0) ? null : _today.add(Duration(days: days));

    final DateTime? offerEnd = widget.scheduleEndsAt;
    final DateTime? offerMax = offerEnd == null ? null : DateTime(offerEnd.year, offerEnd.month, offerEnd.day);
    if(storeMax == null || offerMax == null) {
      return storeMax ?? offerMax;
    }
    return storeMax.isBefore(offerMax) ? storeMax : offerMax;
  }

  bool _isBeyondMaxDate(DateTime date) {
    final DateTime? maxDate = _maxSelectableDate;
    if(maxDate == null) return false;
    return DateTime(date.year, date.month, date.day).isAfter(maxDate);
  }

  @override
  void initState() {
    super.initState();
    final checkoutController = Get.find<CheckoutController>();
    _selectedDate = checkoutController.selectedDineInDate ?? DateTime.now();
    if(_isBeyondMaxDate(_selectedDate!)) {
      _selectedDate = DateTime.now();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkoutController.updateDateSlot(_selectedDate!, true);
    });

    debugPrint('===> DINE-IN LEAD TIME | restaurant: ${widget.restaurant.name} (id: ${widget.restaurant.id})'
        ' | schedule_advance_dine_in_booking_duration: ${widget.restaurant.dineInBookingDuration}'
        ' | time_format: ${widget.restaurant.dineInBookingDurationTimeFormat}'
        ' | now: ${TimeOfDay.now()} | min allowed today: $_minAllowedTime');

    TimeOfDay initialTime = _parseTimeOfDay(checkoutController.estimateDineInTime) ?? DineInScheduleHelper.addHours(
      TimeOfDay.now(), widget.restaurant.dineInBookingDuration ?? 0, widget.restaurant.dineInBookingDurationTimeFormat ?? 'min',
    );

    final TimeOfDay? minTime = _minAllowedTime;
    if(minTime != null && DineInScheduleHelper.isBeforeCurrentTime(initialTime, minTime)) {
      initialTime = minTime;
    }

    _isPM = initialTime.period == DayPeriod.pm;
    _hour12 = initialTime.hourOfPeriod == 0 ? 12 : initialTime.hourOfPeriod;
    _minute = initialTime.minute;

    _hourController = FixedExtentScrollController(initialItem: _hour12 - 1);
    _minuteController = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  TimeOfDay? _parseTimeOfDay(String? formatted) {
    if(formatted == null) return null;
    try {
      final parts = formatted.trim().split(' ');
      final hm = parts[0].split(':');
      int hour = int.parse(hm[0]);
      int minute = int.parse(hm[1]);
      bool pm = parts.length > 1 && parts[1].toUpperCase() == 'PM';
      if(pm && hour != 12) hour += 12;
      if(!pm && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  TimeOfDay get _selectedTime {
    int hour24 = _isPM ? (_hour12 == 12 ? 12 : _hour12 + 12) : (_hour12 == 12 ? 0 : _hour12);
    return TimeOfDay(hour: hour24, minute: _minute);
  }

  TimeOfDay? get _minAllowedTime {
    if(_selectedDate == null || !DateConverter.isToday(_selectedDate!)) return null;
    final String timeType = widget.restaurant.dineInBookingDurationTimeFormat ?? 'min';
    if(timeType != 'hour' && timeType != 'min') return null;
    return DineInScheduleHelper.addHours(TimeOfDay.now(), widget.restaurant.dineInBookingDuration ?? 0, timeType);
  }

  void _clampTimeIfPast() {
    final TimeOfDay? minTime = _minAllowedTime;
    if(minTime == null || !DineInScheduleHelper.isBeforeCurrentTime(_selectedTime, minTime)) return;

    showCustomSnackBar('advance_booking_required_please_select_a_later_time'.tr);

    setState(() {
      _isPM = minTime.period == DayPeriod.pm;
      _hour12 = minTime.hourOfPeriod == 0 ? 12 : minTime.hourOfPeriod;
      _minute = minTime.minute;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(!mounted) return;
      _hourController.jumpToItem(_hour12 - 1);
      _minuteController.jumpToItem(_minute);
    });
  }

  bool _canSelectDate(DateTime value) {
    int duration = widget.restaurant.dineInBookingDuration ?? 0;
    String? timeFormat = widget.restaurant.dineInBookingDurationTimeFormat;
    for (int i = 0; i < 100; i++) {
      DateTime candidate = DateTime.now().add(Duration(days: i));
      if(candidate.month == value.month && candidate.day == value.day) {
        return timeFormat == 'day' ? i > (duration - 1) : true;
      }
    }
    return false;
  }

  void _onSave() {
    if(_selectedDate == null) {
      showCustomSnackBar('please_select_dine_in_date_first'.tr);
      return;
    }
    final checkoutController = Get.find<CheckoutController>();
    TimeOfDay pickedTime = _selectedTime;
    DateTime datetime = DateConverter.formattingDineInDateTime(pickedTime, _selectedDate!);

    final (bool inTime, String? message) = DineInScheduleHelper.isInDineInSchedule(
      checkoutController.timeSlots, datetime, pickedTime,
      widget.restaurant.dineInBookingDurationTimeFormat ?? 'min', widget.restaurant.dineInBookingDuration ?? 0,
    );

    final DateTime? offerEnd = widget.scheduleEndsAt;
    if(offerEnd != null && datetime.isAfter(offerEnd)) {
      showCustomSnackBar('offer_ends_on_pick_earlier_time'.trParams({
        'date': DateConverter.dateTimeStringToDateTime(DateFormat('yyyy-MM-dd HH:mm:ss').format(offerEnd)),
      }));
      return;
    }

    if(inTime) {
      checkoutController.setSelectedDineInDate(_selectedDate, willUpdate: false);
      checkoutController.setEstimateDineInTime(pickedTime.format(context));
      checkoutController.setOrderPlaceDineInDateTime(datetime);
      Get.back();
    } else {
      showCustomSnackBar(message ?? 'restaurant_is_close_on_your_selected_time'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      width: isDesktop ? 420 : double.infinity,
      
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: isDesktop ? BorderRadius.circular(Dimensions.radiusDefault)
            : const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.all(6),
          child: Align( alignment: Alignment.topRight,
            child: InkWell(
                onTap: () => Get.back(),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: context.surfaceContainer,
                  child: Icon(Icons.close, size: 18, color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
              ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(Dimensions.paddingDefault+1, 0, Dimensions.paddingDefault+1, Dimensions.paddingDefault+1),
          child: Column(children: [
            Align( alignment: Alignment.topLeft, child: Text('select_date_and_time'.tr, style: context.heading.extraLarge.strong)),
            const SizedBox(height: Dimensions.paddingLarge),

            Container(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(color: context.outline),
              ),
              child: SfDateRangePicker(
                backgroundColor: Colors.transparent,
                view: DateRangePickerView.month,
                headerStyle: DateRangePickerHeaderStyle(
                  textAlign: TextAlign.center,
                  textStyle: context.heading.large.strong,
                  backgroundColor: Colors.transparent,
                ),
                monthViewSettings: DateRangePickerMonthViewSettings(
                  dayFormat: 'EEEEE',
                  viewHeaderStyle: DateRangePickerViewHeaderStyle(
                    textStyle: context.body.defaultSize.medium.overrideWith(color: context.textBaseMedium),
                  ),
                ),
                selectionColor: context.primary,
                selectionTextStyle: context.heading.defaultSize.strong.overrideWith(color: context.onPrimary),
                selectionShape: DateRangePickerSelectionShape.rectangle,
                selectionRadius: 10,
                initialSelectedDate: _selectedDate,
                minDate: _today,
                maxDate: _maxSelectableDate,
                showNavigationArrow: true,
                selectableDayPredicate: _canSelectDate,
                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                  DateTime selectedDate = DateConverter.dateStringToDate(args.value.toString());
                  bool isClose = checkRestaurantClose(selectedDate);
                  if(isClose) {
                    showCustomSnackBar('restaurant_is_close_on_your_selected_date'.tr);
                  } else {
                    setState(() => _selectedDate = selectedDate);
                    _clampTimeIfPast();
                  }
                },
              ),
            ),
            const SizedBox(height: Dimensions.paddingLarge),

            Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
              decoration: BoxDecoration(
                border: Border.all(color: context.outline),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Row(children: [
                Text('arrival_time'.tr, style: context.subHeading.defaultSize.medium),
                const Spacer(),

                SizedBox(
                  width: 90, height: 90,
                  child: CupertinoTheme(
                    data: CupertinoThemeData(brightness: Theme.of(context).brightness),
                    child: Row(children: [
                      Expanded(child: CupertinoPicker(
                        scrollController: _hourController,
                        itemExtent: 30,
                        looping: true,
                        selectionOverlay: const SizedBox.shrink(),
                        onSelectedItemChanged: (i) {
                          setState(() => _hour12 = i + 1);
                          _clampTimeIfPast();
                        },
                        children: List.generate(12, (i) => Center(
                          child: Text((i + 1).toString().padLeft(2, '0'), style: context.heading.large.strong),
                        )),
                      )),
                      Text(':', style: context.heading.large.strong),
                      Expanded(child: CupertinoPicker(
                        scrollController: _minuteController,
                        itemExtent: 30,
                        looping: true,
                        selectionOverlay: const SizedBox.shrink(),
                        onSelectedItemChanged: (i) {
                          setState(() => _minute = i);
                          _clampTimeIfPast();
                        },
                        children: List.generate(60, (i) => Center(
                          child: Text(i.toString().padLeft(2, '0'), style: context.heading.large.strong),
                        )),
                      )),
                    ]),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSmall),

                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: context.surfaceContainer,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    _meridiemButton('am', !_isPM),
                    _meridiemButton('pm', _isPM),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingLarge),

            Row(children: [
              Expanded(child: CustomButtonWidget(
                buttonText: 'cancel'.tr,
                fontSize: Dimensions.fontSizeDefault,
                color: context.bgNeutralLight,
                textColor: Theme.of(context).textTheme.bodyLarge?.color,
                onPressed: () => Get.back(),
              )),
              const SizedBox(width: Dimensions.paddingSmall),
              Expanded(child: CustomButtonWidget(
                buttonText: 'save'.tr,
                onPressed: _onSave,
              )),
            ]),
          
          ]),
        ),
      ]),
    );
  }

  Widget _meridiemButton(String value, bool selected) {
    return InkWell(
      onTap: () {
        setState(() => _isPM = value == 'pm');
        _clampTimeIfPast();
      },
      child: Container(
        width: 38, height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? context.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
        ),
        child: Text(
          value.toUpperCase(),
          style: context.subHeading.small.strong.overrideWith(color: selected ? context.onPrimary : context.textBaseMedium),
        ),
      ),
    );
  }
}
