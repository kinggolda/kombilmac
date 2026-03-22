import 'package:flutter/foundation.dart';
import 'package:schedule_app/features/schedule/domain/entities/lesson.dart';

@immutable
class ScheduleDay {
  const ScheduleDay({
    required this.weekday,
    required this.lessons,
  });

  final String weekday;
  final List<Lesson> lessons;

  Map<String, dynamic> toJson() {
    return {
      'weekday': weekday,
      'lessons': lessons.map((item) => item.toJson()).toList(growable: false),
    };
  }

  factory ScheduleDay.fromJson(Map<String, dynamic> json) {
    final rawLessons = json['lessons'];
    final lessons = rawLessons is List
        ? rawLessons
            .whereType<Map>()
            .map((item) => Lesson.fromJson(Map<String, dynamic>.from(item)))
            .toList(growable: false)
        : const <Lesson>[];

    return ScheduleDay(
      weekday: json['weekday']?.toString() ?? '',
      lessons: lessons,
    );
  }
}

