import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/timeslote_model.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';

class DineInScheduleHelper {

  static TimeOfDay addHours(TimeOfDay time, int hoursOrMinutesToAdd, String type, {bool fromSchedule = false}) {
    if(fromSchedule) {
      int newHour = (time.hour + (type == 'hour' ? hoursOrMinutesToAdd : 0)) % 24;
      int newMin = (time.hour + (type == 'min' ? hoursOrMinutesToAdd : 0)) % 60;
      return TimeOfDay(hour: newHour, minute: newMin);
    }
    if(type == 'min') {
      final timeInMinutes = (time.hour * 60 + time.minute + hoursOrMinutesToAdd) % (24 * 60);
      final newHour = timeInMinutes ~/ 60;
      final newMinute = timeInMinutes % 60;
      return TimeOfDay(hour: newHour, minute: newMinute);
    } else if (type == 'hour') {
      final totalHours = (time.hour + hoursOrMinutesToAdd) % 24;
      final totalMinutes = (time.hour * 60 + time.minute + 1) % (24 * 60);
      final newMinute = totalMinutes % 60;
      return TimeOfDay(hour: totalHours, minute: newMinute);
    }
    return time;
  }

  static (bool, String?) isInDineInSchedule(List<TimeSlotModel>? timeSlots, DateTime datetime, TimeOfDay pickTime, String dineInTimeType, int duration) {
    TimeOfDay fixedTime = addHours(TimeOfDay.now(), duration, dineInTimeType, fromSchedule: false);
    for (var v in timeSlots!) {
      if(datetime.isAfter(v.startTime!) && datetime.isBefore(v.endTime!)) {
        if((dineInTimeType == 'hour' || dineInTimeType == 'min') && DateConverter.isToday(datetime) ? !isBeforeCurrentTime(pickTime, fixedTime) : true) {
          return (true, null);
        } else if(dineInTimeType == 'day') {
          return (true, null);
        } else {
          return (false, 'dine_in_order_is_unavailable_at_your_selected_time'.tr);
        }
      }
    }
    return (false, null);
  }

  static bool isBeforeCurrentTime(TimeOfDay selectedTime, TimeOfDay? fixedTime) {
    TimeOfDay now = fixedTime ?? TimeOfDay.now();
    if (selectedTime.hour < now.hour) {
      return true;
    } else if (selectedTime.hour == now.hour) {
      return selectedTime.minute < now.minute;
    } else {
      return false;
    }
  }
}
