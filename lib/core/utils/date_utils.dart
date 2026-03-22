import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateUtilsX on DateTime {
  DateTime get atStartOfDay => DateTime(year, month, day);

  DateTime get startOfWeek {
    final normalized = atStartOfDay;
    final diff = normalized.weekday - DateTime.monday;
    return normalized.subtract(Duration(days: diff));
  }

  DateTime get endOfWeek => startOfWeek.add(const Duration(days: 6));

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

String formatWeekRange(
  DateTime weekStart, {
  required String localeCode,
}) {
  final weekEnd = weekStart.add(const Duration(days: 6));
  final sameMonth = weekStart.month == weekEnd.month;

  if (sameMonth) {
    return '${DateFormat('d', localeCode).format(weekStart)}–${DateFormat('d MMM', localeCode).format(weekEnd)}';
  }

  return '${DateFormat('d MMM', localeCode).format(weekStart)} – ${DateFormat('d MMM', localeCode).format(weekEnd)}';
}

String formatWeekdayShort(DateTime date, {required String localeCode}) {
  return DateFormat('EEE', localeCode).format(date);
}

String formatDayLabel(DateTime date, {required String localeCode}) {
  return DateFormat('d MMMM', localeCode).format(date);
}

String formatDayWithWeekday(DateTime date, {required String localeCode}) {
  return DateFormat('EEEE, d MMMM', localeCode).format(date);
}

String formatClockTime(
  String raw, {
  required bool use24HourFormat,
  required String localeCode,
}) {
  final parsed = _tryParseTime(raw);
  if (parsed == null) {
    return raw;
  }

  final anchor = DateTime(2000, 1, 1, parsed.hour, parsed.minute);
  final pattern = use24HourFormat ? 'HH:mm' : 'h:mm a';
  return DateFormat(pattern, localeCode).format(anchor);
}

DateTime combineDateAndTime({
  required DateTime date,
  required String time,
}) {
  final parsed = _tryParseTime(time) ?? const TimeOfDay(hour: 0, minute: 0);
  return DateTime(
    date.year,
    date.month,
    date.day,
    parsed.hour,
    parsed.minute,
  );
}

TimeOfDay? _tryParseTime(String raw) {
  final patterns = <String>['HH:mm', 'H:mm', 'HH:mm:ss'];
  for (final pattern in patterns) {
    try {
      final date = DateFormat(pattern).parseStrict(raw);
      return TimeOfDay(hour: date.hour, minute: date.minute);
    } catch (_) {
      continue;
    }
  }
  return null;
}

