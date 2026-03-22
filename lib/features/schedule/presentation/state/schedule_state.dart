import 'package:flutter/foundation.dart';
import 'package:schedule_app/features/schedule/domain/entities/group.dart';
import 'package:schedule_app/features/schedule/domain/entities/lesson.dart';
import 'package:schedule_app/features/schedule/domain/entities/schedule_dataset.dart';

enum ScheduleLoadStatus {
  initial,
  loading,
  success,
  empty,
  error,
  offlineCached,
}

enum ScheduleViewMode {
  today,
  tomorrow,
  week,
}

const Object _scheduleNoChange = Object();

@immutable
class ScheduleState {
  const ScheduleState({
    required this.status,
    required this.dataset,
    required this.groups,
    required this.visibleLessons,
    required this.selectedGroupName,
    required this.selectedSubgroupName,
    required this.selectedWeekday,
    required this.viewMode,
    required this.searchQuery,
    required this.sourceUrl,
    required this.errorMessage,
    required this.isRefreshing,
    required this.recentGroups,
    required this.parserWarnings,
  });

  final ScheduleLoadStatus status;
  final ScheduleDataset? dataset;
  final List<Group> groups;
  final List<Lesson> visibleLessons;
  final String? selectedGroupName;
  final String? selectedSubgroupName;
  final String? selectedWeekday;
  final ScheduleViewMode viewMode;
  final String searchQuery;
  final String sourceUrl;
  final String? errorMessage;
  final bool isRefreshing;
  final List<String> recentGroups;
  final List<String> parserWarnings;

  factory ScheduleState.initial({required String sourceUrl}) {
    return ScheduleState(
      status: ScheduleLoadStatus.initial,
      dataset: null,
      groups: const <Group>[],
      visibleLessons: const <Lesson>[],
      selectedGroupName: null,
      selectedSubgroupName: null,
      selectedWeekday: null,
      viewMode: ScheduleViewMode.today,
      searchQuery: '',
      sourceUrl: sourceUrl,
      errorMessage: null,
      isRefreshing: false,
      recentGroups: const <String>[],
      parserWarnings: const <String>[],
    );
  }

  bool get hasData => dataset != null;

  bool get isOfflineCached => dataset?.sourceMeta.isOfflineCached ?? false;

  DateTime? get lastUpdated => dataset?.sourceMeta.lastUpdated;

  List<String> get weekdays {
    final set = <String>{};
    for (final lesson in dataset?.lessons ?? const <Lesson>[]) {
      if (lesson.weekday.trim().isNotEmpty) {
        set.add(lesson.weekday);
      }
    }

    final list = set.toList(growable: false);
    list.sort((a, b) => _weekdayOrder(a).compareTo(_weekdayOrder(b)));
    return list;
  }

  List<String> get availableSubgroups {
    final selectedGroup = selectedGroupName;
    if (selectedGroup == null) {
      return const <String>[];
    }

    Group? group;
    for (final item in groups) {
      if (item.name == selectedGroup) {
        group = item;
        break;
      }
    }

    final subgroups = group?.subgroups ?? const <Never>[];

    return subgroups
        .map((item) => item.name)
        .where((name) => name.trim().isNotEmpty)
        .toList(growable: false);
  }

  ScheduleState copyWith({
    ScheduleLoadStatus? status,
    Object? dataset = _scheduleNoChange,
    List<Group>? groups,
    List<Lesson>? visibleLessons,
    Object? selectedGroupName = _scheduleNoChange,
    Object? selectedSubgroupName = _scheduleNoChange,
    Object? selectedWeekday = _scheduleNoChange,
    ScheduleViewMode? viewMode,
    String? searchQuery,
    String? sourceUrl,
    Object? errorMessage = _scheduleNoChange,
    bool? isRefreshing,
    List<String>? recentGroups,
    List<String>? parserWarnings,
  }) {
    return ScheduleState(
      status: status ?? this.status,
      dataset: dataset == _scheduleNoChange ? this.dataset : dataset as ScheduleDataset?,
      groups: groups ?? this.groups,
      visibleLessons: visibleLessons ?? this.visibleLessons,
      selectedGroupName: selectedGroupName == _scheduleNoChange
          ? this.selectedGroupName
          : selectedGroupName as String?,
      selectedSubgroupName: selectedSubgroupName == _scheduleNoChange
          ? this.selectedSubgroupName
          : selectedSubgroupName as String?,
      selectedWeekday: selectedWeekday == _scheduleNoChange
          ? this.selectedWeekday
          : selectedWeekday as String?,
      viewMode: viewMode ?? this.viewMode,
      searchQuery: searchQuery ?? this.searchQuery,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      errorMessage:
          errorMessage == _scheduleNoChange ? this.errorMessage : errorMessage as String?,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      recentGroups: recentGroups ?? this.recentGroups,
      parserWarnings: parserWarnings ?? this.parserWarnings,
    );
  }

  int _weekdayOrder(String weekday) {
    const order = <String, int>{
      'Понедельник': 1,
      'Вторник': 2,
      'Среда': 3,
      'Четверг': 4,
      'Пятница': 5,
      'Суббота': 6,
      'Воскресенье': 7,
    };

    return order[weekday] ?? 99;
  }
}

