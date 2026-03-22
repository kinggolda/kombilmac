import 'package:flutter/foundation.dart';
import 'package:schedule_app/features/schedule/domain/entities/group.dart';
import 'package:schedule_app/features/schedule/domain/entities/lesson.dart';
import 'package:schedule_app/features/schedule/domain/entities/schedule_day.dart';
import 'package:schedule_app/features/schedule/domain/entities/schedule_source_meta.dart';

@immutable
class ScheduleDataset {
  const ScheduleDataset({
    required this.groups,
    required this.days,
    required this.lessons,
    required this.sourceMeta,
  });

  final List<Group> groups;
  final List<ScheduleDay> days;
  final List<Lesson> lessons;
  final ScheduleSourceMeta sourceMeta;

  ScheduleDataset copyWith({
    List<Group>? groups,
    List<ScheduleDay>? days,
    List<Lesson>? lessons,
    ScheduleSourceMeta? sourceMeta,
  }) {
    return ScheduleDataset(
      groups: groups ?? this.groups,
      days: days ?? this.days,
      lessons: lessons ?? this.lessons,
      sourceMeta: sourceMeta ?? this.sourceMeta,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groups': groups.map((item) => item.toJson()).toList(growable: false),
      'days': days.map((item) => item.toJson()).toList(growable: false),
      'lessons': lessons.map((item) => item.toJson()).toList(growable: false),
      'sourceMeta': sourceMeta.toJson(),
    };
  }

  factory ScheduleDataset.fromJson(Map<String, dynamic> json) {
    final rawGroups = json['groups'];
    final rawDays = json['days'];
    final rawLessons = json['lessons'];

    final groups = rawGroups is List
        ? rawGroups
            .whereType<Map>()
            .map((item) => Group.fromJson(Map<String, dynamic>.from(item)))
            .toList(growable: false)
        : const <Group>[];

    final days = rawDays is List
        ? rawDays
            .whereType<Map>()
            .map((item) => ScheduleDay.fromJson(Map<String, dynamic>.from(item)))
            .toList(growable: false)
        : const <ScheduleDay>[];

    final lessons = rawLessons is List
        ? rawLessons
            .whereType<Map>()
            .map((item) => Lesson.fromJson(Map<String, dynamic>.from(item)))
            .toList(growable: false)
        : const <Lesson>[];

    return ScheduleDataset(
      groups: groups,
      days: days,
      lessons: lessons,
      sourceMeta: ScheduleSourceMeta.fromJson(
        Map<String, dynamic>.from(json['sourceMeta'] ?? const <String, dynamic>{}),
      ),
    );
  }
}

