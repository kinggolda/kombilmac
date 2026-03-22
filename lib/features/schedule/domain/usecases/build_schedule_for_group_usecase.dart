import 'package:schedule_app/features/schedule/domain/entities/lesson.dart';
import 'package:schedule_app/features/schedule/domain/entities/schedule_dataset.dart';

class BuildScheduleForGroupUseCase {
  const BuildScheduleForGroupUseCase();

  List<Lesson> call({
    required ScheduleDataset dataset,
    required String groupName,
    String? subgroupName,
    String? weekday,
    String? searchQuery,
  }) {
    Iterable<Lesson> output = dataset.lessons;

    output = output.where((item) => item.group == groupName);

    if (subgroupName != null && subgroupName.trim().isNotEmpty) {
      output = output.where((item) {
        final subgroup = (item.subgroup ?? '').trim();
        return subgroup.isEmpty || subgroup == subgroupName;
      });
    }

    if (weekday != null && weekday.trim().isNotEmpty) {
      output = output.where((item) => item.weekday == weekday);
    }

    final query = searchQuery?.trim().toLowerCase() ?? '';
    if (query.isNotEmpty) {
      output = output.where((item) {
        final values = <String?>[
          item.subject,
          item.teacher,
          item.room,
          item.group,
          item.subgroup,
        ];

        for (final value in values) {
          if ((value ?? '').toLowerCase().contains(query)) {
            return true;
          }
        }
        return false;
      });
    }

    final list = output.toList(growable: false)
      ..sort((a, b) {
        final weekdayOrder = _weekdayToIndex(a.weekday).compareTo(
          _weekdayToIndex(b.weekday),
        );
        if (weekdayOrder != 0) {
          return weekdayOrder;
        }

        if (a.lessonIndex != b.lessonIndex) {
          return a.lessonIndex.compareTo(b.lessonIndex);
        }

        return a.startTime.compareTo(b.startTime);
      });

    return list;
  }

  int _weekdayToIndex(String weekday) {
    const order = <String, int>{
      'Понедельник': 1,
      'Вторник': 2,
      'Среда': 3,
      'Четверг': 4,
      'Пятница': 5,
      'Суббота': 6,
      'Воскресенье': 7,
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
      'Sunday': 7,
    };

    return order[weekday] ?? 99;
  }
}

