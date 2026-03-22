import 'package:flutter/foundation.dart';

@immutable
class Lesson {
  const Lesson({
    required this.lessonIndex,
    required this.weekday,
    required this.startTime,
    required this.endTime,
    required this.subject,
    required this.group,
    this.teacher,
    this.room,
    this.subgroup,
    this.rawCellValue,
  });

  final int lessonIndex;
  final String weekday;
  final String startTime;
  final String endTime;
  final String subject;
  final String? teacher;
  final String? room;
  final String? subgroup;
  final String group;
  final String? rawCellValue;

  String get id {
    return '${group}_${subgroup}_${weekday}_${lessonIndex}_${startTime}_$endTime';
  }

  Lesson copyWith({
    int? lessonIndex,
    String? weekday,
    String? startTime,
    String? endTime,
    String? subject,
    Object? teacher = _lessonNoChange,
    Object? room = _lessonNoChange,
    Object? subgroup = _lessonNoChange,
    String? group,
    Object? rawCellValue = _lessonNoChange,
  }) {
    return Lesson(
      lessonIndex: lessonIndex ?? this.lessonIndex,
      weekday: weekday ?? this.weekday,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      subject: subject ?? this.subject,
      teacher: teacher == _lessonNoChange ? this.teacher : teacher as String?,
      room: room == _lessonNoChange ? this.room : room as String?,
      subgroup: subgroup == _lessonNoChange ? this.subgroup : subgroup as String?,
      group: group ?? this.group,
      rawCellValue: rawCellValue == _lessonNoChange
          ? this.rawCellValue
          : rawCellValue as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonIndex': lessonIndex,
      'weekday': weekday,
      'startTime': startTime,
      'endTime': endTime,
      'subject': subject,
      'teacher': teacher,
      'room': room,
      'subgroup': subgroup,
      'group': group,
      'rawCellValue': rawCellValue,
    };
  }

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      lessonIndex: _toInt(json['lessonIndex']) ?? 0,
      weekday: json['weekday']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      teacher: json['teacher']?.toString(),
      room: json['room']?.toString(),
      subgroup: json['subgroup']?.toString(),
      group: json['group']?.toString() ?? '',
      rawCellValue: json['rawCellValue']?.toString(),
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '');
  }
}

const Object _lessonNoChange = Object();

