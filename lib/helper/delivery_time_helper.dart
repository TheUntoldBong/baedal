class DeliveryTimeHelper {
  DeliveryTimeHelper._();

  static int toMinutes(int value, String? unit) {
    final String normalizedUnit = unit?.toLowerCase() ?? 'min';
    return (normalizedUnit.contains('hour') || normalizedUnit.contains('hr')) ? value * 60 : value;
  }

  static List<int> parseStoreMinutes(String? deliveryTime) {
    if (deliveryTime != null && deliveryTime.trim().isNotEmpty) {
      final List<String> parts = deliveryTime.split('-');
      if (parts.length >= 2) {
        try {
          final String unit = parts.length >= 3 ? parts[2] : 'min';
          final int a = toMinutes(int.parse(parts[0].trim()), unit);
          final int b = toMinutes(int.parse(parts[1].trim()), unit);
          return a <= b ? [a, b] : [b, a];
        } catch (_) {}
      }
      final List<int> nums = RegExp(r'\d+').allMatches(deliveryTime).map((m) => int.parse(m.group(0)!)).toList();
      if (nums.isNotEmpty) {
        return nums.length >= 2 ? [nums[0], nums[1]] : [nums[0], nums[0]];
      }
    }
    return const [];
  }

  static List<DateTime> arrivalWindow(
    DateTime base,
    int minMinutes,
    int maxMinutes, {
    DateTime? now,
    int stepMinutes = 5,
  }) {
    final DateTime current = now ?? DateTime.now();
    DateTime start = base.add(Duration(minutes: minMinutes));
    DateTime end = base.add(Duration(minutes: maxMinutes));

    // If estimated delivery start time is in the past (e.g. delayed or timezone offset),
    // calculate dynamic upcoming ETA from current time so it never shows past times.
    if (start.isBefore(current)) {
      int span = maxMinutes > minMinutes ? (maxMinutes - minMinutes) : 5;
      if (span < 5) span = 5;
      start = _nextMark(current, stepMinutes);
      end = start.add(Duration(minutes: span));
    } else {
      final DateTime nextMark = _nextMark(current, stepMinutes);
      if (end.isBefore(nextMark)) {
        end = nextMark;
      }
    }
    return [start, end];
  }

  static DateTime _nextMark(DateTime time, int stepMinutes) {
    final DateTime floored = DateTime(time.year, time.month, time.day, time.hour, time.minute);
    final int remainder = floored.minute % stepMinutes;
    final int add = remainder == 0 ? stepMinutes : stepMinutes - remainder;
    return floored.add(Duration(minutes: add));
  }
}
