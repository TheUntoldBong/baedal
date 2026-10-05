import 'package:flutter/cupertino.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';


class TimeWheelBottomSheet {
  static Future<TimeOfDay?> pick(BuildContext context, {TimeOfDay? initialTime, String? title, TimeOfDay? minTime}) {
    return showModalBottomSheet<TimeOfDay?>(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => _TimeWheelSheet(initialTime: initialTime ?? TimeOfDay.now(), title: title, minTime: minTime),
    );
  }
}

class _TimeWheelSheet extends StatefulWidget {
  final TimeOfDay initialTime;
  final String? title;
  final TimeOfDay? minTime;
  const _TimeWheelSheet({required this.initialTime, this.title, this.minTime});

  @override
  State<_TimeWheelSheet> createState() => _TimeWheelSheetState();
}

class _TimeWheelSheetState extends State<_TimeWheelSheet> {
  late int _hour12;
  late int _minute;
  late bool _isPM;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    TimeOfDay initial = widget.initialTime;
    final TimeOfDay? minTime = widget.minTime;
    if(minTime != null && (initial.hour < minTime.hour || (initial.hour == minTime.hour && initial.minute < minTime.minute))) {
      initial = minTime;
    }
    _isPM = initial.period == DayPeriod.pm;
    _hour12 = initial.hourOfPeriod == 0 ? 12 : initial.hourOfPeriod;
    _minute = initial.minute;
    _hourController = FixedExtentScrollController(initialItem: _hour12 - 1);
    _minuteController = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  TimeOfDay get _selectedTime {
    int hour24 = _isPM ? (_hour12 == 12 ? 12 : _hour12 + 12) : (_hour12 == 12 ? 0 : _hour12);
    return TimeOfDay(hour: hour24, minute: _minute);
  }

  int _hour24For(int hour12, bool isPM) => isPM ? (hour12 == 12 ? 12 : hour12 + 12) : (hour12 == 12 ? 0 : hour12);

  int _hour12For(TimeOfDay time) => time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;

  bool _isAmDisabled() => widget.minTime != null && widget.minTime!.hour >= 12;

  bool _isHourDisabled(int hour12, bool isPM) {
    final TimeOfDay? minTime = widget.minTime;
    if(minTime == null) return false;
    return _hour24For(hour12, isPM) < minTime.hour;
  }

  bool _isMinuteDisabled(int minute) {
    final TimeOfDay? minTime = widget.minTime;
    if(minTime == null) return false;
    final int hour24 = _hour24For(_hour12, _isPM);
    if(hour24 != minTime.hour) return hour24 < minTime.hour;
    return minute < minTime.minute;
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: isDesktop ? BorderRadius.circular(Dimensions.radiusDefault)
            : const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: SafeArea(
        top: false,
        child: Column( mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: Dimensions.padding2xSmall, right: Dimensions.padding2xSmall),
              child: Align( alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: context.surfaceContainer,
                    child: Icon(Icons.close, size: 18, color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault+1, vertical: Dimensions.paddingSmall),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.title ?? 'choose_time'.tr, style: context.heading.extraLarge.strong),
                const SizedBox(width: Dimensions.paddingSmall),
              
                const SizedBox(height: Dimensions.paddingLarge),
              
                Container(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
                  decoration: BoxDecoration(
                    color: context.surfaceContainer,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: SizedBox(
                        height: 160,
                        child: CupertinoTheme(
                          data: CupertinoThemeData(brightness: Theme.of(context).brightness),
                          child: Row(children: [
                            Expanded(child: CupertinoPicker(
                              scrollController: _hourController,
                              itemExtent: 36,
                              looping: true,
                              selectionOverlay: const SizedBox.shrink(),
                              onSelectedItemChanged: (i) {
                                final int pickedHour12 = i + 1;
                                if(_isHourDisabled(pickedHour12, _isPM)) {
                                  final int fallbackHour12 = _hour12For(widget.minTime!);
                                  WidgetsBinding.instance.addPostFrameCallback((_) => _hourController.jumpToItem(fallbackHour12 - 1));
                                  setState(() => _hour12 = fallbackHour12);
                                } else {
                                  setState(() => _hour12 = pickedHour12);
                                }
                                if(_isMinuteDisabled(_minute)) {
                                  final int fallbackMinute = widget.minTime!.minute;
                                  WidgetsBinding.instance.addPostFrameCallback((_) => _minuteController.jumpToItem(fallbackMinute));
                                  setState(() => _minute = fallbackMinute);
                                }
                              },
                              children: List.generate(12, (i) {
                                final bool disabled = _isHourDisabled(i + 1, _isPM);
                                return Center(
                                  child: Text(
                                    (i + 1).toString().padLeft(2, '0'),
                                    style: context.heading.large.strong.overrideWith(color: disabled ? context.textBaseLight : null),
                                  ),
                                );
                              }),
                            )),
                            Text(':', style: context.heading.large.strong),
                            Expanded(child: CupertinoPicker(
                              scrollController: _minuteController,
                              itemExtent: 36,
                              looping: true,
                              selectionOverlay: const SizedBox.shrink(),
                              onSelectedItemChanged: (i) {
                                if(_isMinuteDisabled(i)) {
                                  final int fallbackMinute = widget.minTime!.minute;
                                  WidgetsBinding.instance.addPostFrameCallback((_) => _minuteController.jumpToItem(fallbackMinute));
                                  setState(() => _minute = fallbackMinute);
                                } else {
                                  setState(() => _minute = i);
                                }
                              },
                              children: List.generate(60, (i) {
                                final bool disabled = _isMinuteDisabled(i);
                                return Center(
                                  child: Text(
                                    i.toString().padLeft(2, '0'),
                                    style: context.heading.large.strong.overrideWith(color: disabled ? context.textBaseLight : null),
                                  ),
                                );
                              }),
                            )),
                          ]),
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSmall),
              
                    Padding(
                      padding: const EdgeInsets.only(right: Dimensions.paddingSmall),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: context.surfaceContainer,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          _meridiemButton(context, 'am', !_isPM),
                          _meridiemButton(context, 'pm', _isPM),
                        ]),
                      ),
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
                    onPressed: () => Navigator.pop(context),
                  )),
                  const SizedBox(width: Dimensions.paddingSmall),
              
                  Expanded(child: CustomButtonWidget(
                    buttonText: 'confirm'.tr,
                    fontSize: Dimensions.fontSizeDefault,
                    onPressed: () => Navigator.pop(context, _selectedTime),
                  )),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _meridiemButton(BuildContext context, String value, bool selected) {
    final bool disabled = value == 'am' && _isAmDisabled();
    return InkWell(
      onTap: disabled ? null : () => setState(() {
        _isPM = value == 'pm';
        if(_isHourDisabled(_hour12, _isPM)) {
          _hour12 = _hour12For(widget.minTime!);
          WidgetsBinding.instance.addPostFrameCallback((_) => _hourController.jumpToItem(_hour12 - 1));
        }
        if(_isMinuteDisabled(_minute)) {
          _minute = widget.minTime!.minute;
          WidgetsBinding.instance.addPostFrameCallback((_) => _minuteController.jumpToItem(_minute));
        }
      }),
      child: Container(
        width: 38, height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? context.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
        ),
        child: Text(
          value.toUpperCase(),
          style: context.heading.small.strong.overrideWith(color: disabled ? context.textBaseLight : (selected ? Colors.white : context.textBaseMedium)),
        ),
      ),
    );
  }
}
