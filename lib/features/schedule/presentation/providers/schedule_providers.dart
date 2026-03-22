import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schedule_app/app/providers/app_config_provider.dart';
import 'package:schedule_app/core/errors/app_exception.dart';
import 'package:schedule_app/core/network/dio_client.dart';
import 'package:schedule_app/features/schedule/data/datasources/schedule_local_data_source.dart';
import 'package:schedule_app/features/schedule/data/datasources/schedule_mock_data_source.dart';
import 'package:schedule_app/features/schedule/data/datasources/schedule_remote_data_source.dart';
import 'package:schedule_app/features/schedule/data/parsing/logger/spreadsheet_parser_logger.dart';
import 'package:schedule_app/features/schedule/data/parsing/rules/spreadsheet_parsing_rules.dart';
import 'package:schedule_app/features/schedule/data/parsing/spreadsheet_workbook_reader.dart';
import 'package:schedule_app/features/schedule/data/parsing/strategy/default_spreadsheet_parser_strategy.dart';
import 'package:schedule_app/features/schedule/data/parsing/strategy/spreadsheet_parser_strategy.dart';
import 'package:schedule_app/features/schedule/data/repositories/schedule_repository_impl.dart';
import 'package:schedule_app/features/schedule/data/utils/spreadsheet_source_url_resolver.dart';
import 'package:schedule_app/features/schedule/domain/entities/group.dart';
import 'package:schedule_app/features/schedule/domain/entities/lesson.dart';
import 'package:schedule_app/features/schedule/domain/entities/schedule_dataset.dart';
import 'package:schedule_app/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:schedule_app/features/schedule/domain/usecases/build_schedule_for_group_usecase.dart';
import 'package:schedule_app/features/schedule/domain/usecases/download_schedule_file_usecase.dart';
import 'package:schedule_app/features/schedule/domain/usecases/extract_groups_usecase.dart';
import 'package:schedule_app/features/schedule/domain/usecases/parse_spreadsheet_usecase.dart';
import 'package:schedule_app/features/schedule/presentation/state/schedule_state.dart';

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  return createDioClient(config);
});

final spreadsheetSourceUrlResolverProvider =
    Provider<SpreadsheetSourceUrlResolver>((ref) {
  return const SpreadsheetSourceUrlResolver();
});

final spreadsheetParserLoggerProvider = Provider<SpreadsheetParserLogger>((ref) {
  final config = ref.watch(appConfigProvider);
  return SpreadsheetParserLogger(enabled: config.enableParserLogs);
});

final spreadsheetParsingRulesProvider = Provider<SpreadsheetParsingRules>((ref) {
  return SpreadsheetParsingRules.defaults();
});

final spreadsheetWorkbookReaderProvider = Provider<SpreadsheetWorkbookReader>((ref) {
  return SpreadsheetWorkbookReader(
    logger: ref.watch(spreadsheetParserLoggerProvider),
  );
});

final spreadsheetParserStrategyProvider = Provider<SpreadsheetParserStrategy>((ref) {
  return DefaultSpreadsheetParserStrategy(
    logger: ref.watch(spreadsheetParserLoggerProvider),
  );
});

final scheduleRemoteDataSourceProvider = Provider<ScheduleFileRemoteDataSource>((ref) {
  return ScheduleFileRemoteDataSource(
    dio: ref.watch(dioProvider),
    resolver: ref.watch(spreadsheetSourceUrlResolverProvider),
  );
});

final scheduleCacheDataSourceProvider = Provider<ScheduleCacheDataSource>((ref) {
  return ScheduleCacheDataSource();
});

final scheduleMockDataSourceProvider = Provider<ScheduleMockDataSource>((ref) {
  return const ScheduleMockDataSource();
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepositoryImpl(
    remoteDataSource: ref.watch(scheduleRemoteDataSourceProvider),
    cacheDataSource: ref.watch(scheduleCacheDataSourceProvider),
    mockDataSource: ref.watch(scheduleMockDataSourceProvider),
    workbookReader: ref.watch(spreadsheetWorkbookReaderProvider),
    parserStrategy: ref.watch(spreadsheetParserStrategyProvider),
    parsingRules: ref.watch(spreadsheetParsingRulesProvider),
    config: ref.watch(appConfigProvider),
  );
});

final downloadScheduleFileUseCaseProvider =
    Provider<DownloadScheduleFileUseCase>((ref) {
  return DownloadScheduleFileUseCase(ref.watch(scheduleRepositoryProvider));
});

final parseSpreadsheetUseCaseProvider = Provider<ParseSpreadsheetUseCase>((ref) {
  return ParseSpreadsheetUseCase(ref.watch(scheduleRepositoryProvider));
});

final extractGroupsUseCaseProvider = Provider<ExtractGroupsUseCase>((ref) {
  return const ExtractGroupsUseCase();
});

final buildScheduleForGroupUseCaseProvider =
    Provider<BuildScheduleForGroupUseCase>((ref) {
  return const BuildScheduleForGroupUseCase();
});

final scheduleControllerProvider =
    StateNotifierProvider<ScheduleController, ScheduleState>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  final config = ref.watch(appConfigProvider);

  final sourceUrl = repository.getStoredSourceUrl() ?? config.spreadsheetSourceUrl;

  return ScheduleController(
    repository: repository,
    parseSpreadsheetUseCase: ref.watch(parseSpreadsheetUseCaseProvider),
    extractGroupsUseCase: ref.watch(extractGroupsUseCaseProvider),
    buildScheduleForGroupUseCase: ref.watch(buildScheduleForGroupUseCaseProvider),
    initialSourceUrl: sourceUrl,
  );
});

class ScheduleController extends StateNotifier<ScheduleState> {
  ScheduleController({
    required ScheduleRepository repository,
    required ParseSpreadsheetUseCase parseSpreadsheetUseCase,
    required ExtractGroupsUseCase extractGroupsUseCase,
    required BuildScheduleForGroupUseCase buildScheduleForGroupUseCase,
    required String initialSourceUrl,
  })  : _repository = repository,
        _parseSpreadsheetUseCase = parseSpreadsheetUseCase,
        _extractGroupsUseCase = extractGroupsUseCase,
        _buildScheduleForGroupUseCase = buildScheduleForGroupUseCase,
        super(ScheduleState.initial(sourceUrl: initialSourceUrl)) {
    unawaited(loadSchedule());
  }

  final ScheduleRepository _repository;
  final ParseSpreadsheetUseCase _parseSpreadsheetUseCase;
  final ExtractGroupsUseCase _extractGroupsUseCase;
  final BuildScheduleForGroupUseCase _buildScheduleForGroupUseCase;

  Future<void> loadSchedule({bool refresh = false}) async {
    if (!refresh) {
      state = state.copyWith(
        status: ScheduleLoadStatus.loading,
        errorMessage: null,
        isRefreshing: false,
      );
    } else {
      state = state.copyWith(
        isRefreshing: true,
        errorMessage: null,
      );
    }

    try {
      final dataset = await _parseSpreadsheetUseCase(
        sourceUrl: state.sourceUrl,
        forceRefresh: refresh,
      );

      final groups = _extractGroupsUseCase(dataset);
      if (groups.isEmpty || dataset.lessons.isEmpty) {
        state = state.copyWith(
          dataset: dataset,
          groups: groups,
          visibleLessons: const <Lesson>[],
          parserWarnings: dataset.sourceMeta.parserWarnings,
          status: ScheduleLoadStatus.empty,
          isRefreshing: false,
          errorMessage: null,
        );
        return;
      }

      final resolvedGroup = _resolveGroup(groups);
      final resolvedSubgroup = _resolveSubgroup(groups, resolvedGroup);
      final resolvedWeekday = _resolveWeekday(dataset);

      final visibleLessons = _buildScheduleForGroupUseCase(
        dataset: dataset,
        groupName: resolvedGroup,
        subgroupName: resolvedSubgroup,
        weekday: _effectiveWeekday(
          mode: state.viewMode,
          selectedWeekday: resolvedWeekday,
          availableWeekdays: _extractWeekdays(dataset),
        ),
        searchQuery: state.searchQuery,
      );

      await _repository.saveLastSelection(
        groupName: resolvedGroup,
        subgroupName: resolvedSubgroup,
      );

      final recentGroups = _pushRecentGroup(
        current: state.recentGroups,
        groupName: resolvedGroup,
      );

      state = state.copyWith(
        dataset: dataset,
        groups: groups,
        selectedGroupName: resolvedGroup,
        selectedSubgroupName: resolvedSubgroup,
        selectedWeekday: resolvedWeekday,
        visibleLessons: visibleLessons,
        parserWarnings: dataset.sourceMeta.parserWarnings,
        recentGroups: recentGroups,
        status: dataset.sourceMeta.isOfflineCached
            ? ScheduleLoadStatus.offlineCached
            : ScheduleLoadStatus.success,
        isRefreshing: false,
        errorMessage: null,
      );
    } on AppException catch (error) {
      state = state.copyWith(
        status: ScheduleLoadStatus.error,
        errorMessage: error.message,
        isRefreshing: false,
      );
    } catch (error) {
      state = state.copyWith(
        status: ScheduleLoadStatus.error,
        errorMessage: 'Unexpected error: $error',
        isRefreshing: false,
      );
    }
  }

  Future<void> reloadSchedule() => loadSchedule(refresh: true);

  Future<void> updateSourceUrl(String sourceUrl, {bool reload = false}) async {
    final normalized = sourceUrl.trim();
    if (normalized.isEmpty) {
      return;
    }

    await _repository.saveSourceUrl(normalized);
    state = state.copyWith(sourceUrl: normalized);

    if (reload) {
      await loadSchedule(refresh: true);
    }
  }

  Future<void> clearCache() async {
    await _repository.clearCache();
    state = ScheduleState.initial(sourceUrl: state.sourceUrl).copyWith(
      recentGroups: state.recentGroups,
    );
  }

  void setViewMode(ScheduleViewMode mode) {
    state = state.copyWith(viewMode: mode);
    _rebuildVisibleLessons();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _rebuildVisibleLessons();
  }

  void selectGroup(String groupName) {
    final subgroup = _resolveSubgroup(state.groups, groupName);

    state = state.copyWith(
      selectedGroupName: groupName,
      selectedSubgroupName: subgroup,
      recentGroups: _pushRecentGroup(
        current: state.recentGroups,
        groupName: groupName,
      ),
    );

    unawaited(
      _repository.saveLastSelection(
        groupName: groupName,
        subgroupName: subgroup,
      ),
    );

    _rebuildVisibleLessons();
  }

  void selectSubgroup(String? subgroupName) {
    state = state.copyWith(selectedSubgroupName: subgroupName);

    unawaited(
      _repository.saveLastSelection(
        groupName: state.selectedGroupName,
        subgroupName: subgroupName,
      ),
    );

    _rebuildVisibleLessons();
  }

  void selectWeekday(String weekday) {
    state = state.copyWith(
      selectedWeekday: weekday,
      viewMode: ScheduleViewMode.week,
    );
    _rebuildVisibleLessons();
  }

  String _resolveGroup(List<Group> groups) {
    final previous = state.selectedGroupName ?? _repository.getLastSelectedGroup();
    if (previous != null && groups.any((item) => item.name == previous)) {
      return previous;
    }
    return groups.first.name;
  }

  String? _resolveSubgroup(List<Group> groups, String groupName) {
    Group? group;
    for (final item in groups) {
      if (item.name == groupName) {
        group = item;
        break;
      }
    }

    final available = group?.subgroups.map((item) => item.name).toList(growable: false) ??
        const <String>[];

    if (available.isEmpty) {
      return null;
    }

    final previous = state.selectedSubgroupName ?? _repository.getLastSelectedSubgroup();
    if (previous != null && available.contains(previous)) {
      return previous;
    }

    return available.first;
  }

  String _resolveWeekday(ScheduleDataset dataset) {
    final weekdays = _extractWeekdays(dataset);
    if (weekdays.isEmpty) {
      return '';
    }

    final today = _todayWeekday();
    if (weekdays.contains(today)) {
      return today;
    }

    final selected = state.selectedWeekday;
    if (selected != null && weekdays.contains(selected)) {
      return selected;
    }

    return weekdays.first;
  }

  List<String> _extractWeekdays(ScheduleDataset dataset) {
    final weekdays = <String>{};
    for (final lesson in dataset.lessons) {
      if (lesson.weekday.trim().isNotEmpty) {
        weekdays.add(lesson.weekday);
      }
    }

    final list = weekdays.toList(growable: false)
      ..sort((a, b) => _weekdayOrder(a).compareTo(_weekdayOrder(b)));
    return list;
  }

  String? _effectiveWeekday({
    required ScheduleViewMode mode,
    required String? selectedWeekday,
    required List<String> availableWeekdays,
  }) {
    if (availableWeekdays.isEmpty) {
      return null;
    }

    if (mode == ScheduleViewMode.today) {
      final today = _todayWeekday();
      if (availableWeekdays.contains(today)) {
        return today;
      }
      return availableWeekdays.first;
    }

    if (mode == ScheduleViewMode.tomorrow) {
      final tomorrow = _tomorrowWeekday();
      if (availableWeekdays.contains(tomorrow)) {
        return tomorrow;
      }
      return availableWeekdays.first;
    }

    if (selectedWeekday != null && availableWeekdays.contains(selectedWeekday)) {
      return selectedWeekday;
    }

    return availableWeekdays.first;
  }

  void _rebuildVisibleLessons() {
    final dataset = state.dataset;
    final group = state.selectedGroupName;

    if (dataset == null || group == null || group.isEmpty) {
      return;
    }

    final weekdays = _extractWeekdays(dataset);
    final effectiveWeekday = _effectiveWeekday(
      mode: state.viewMode,
      selectedWeekday: state.selectedWeekday,
      availableWeekdays: weekdays,
    );

    final lessons = _buildScheduleForGroupUseCase(
      dataset: dataset,
      groupName: group,
      subgroupName: state.selectedSubgroupName,
      weekday: effectiveWeekday,
      searchQuery: state.searchQuery,
    );

    final status = lessons.isEmpty
        ? ScheduleLoadStatus.empty
        : (dataset.sourceMeta.isOfflineCached
            ? ScheduleLoadStatus.offlineCached
            : ScheduleLoadStatus.success);

    state = state.copyWith(
      selectedWeekday: effectiveWeekday,
      visibleLessons: lessons,
      status: status,
    );
  }

  List<String> _pushRecentGroup({
    required List<String> current,
    required String groupName,
  }) {
    final items = <String>[groupName, ...current.where((item) => item != groupName)];
    if (items.length > 6) {
      return items.sublist(0, 6);
    }
    return items;
  }

  String _todayWeekday() {
    return _relativeWeekday(deltaDays: 0);
  }

  String _tomorrowWeekday() {
    return _relativeWeekday(deltaDays: 1);
  }

  String _relativeWeekday({required int deltaDays}) {
    const map = <int, String>{
      DateTime.monday: 'Понедельник',
      DateTime.tuesday: 'Вторник',
      DateTime.wednesday: 'Среда',
      DateTime.thursday: 'Четверг',
      DateTime.friday: 'Пятница',
      DateTime.saturday: 'Суббота',
      DateTime.sunday: 'Воскресенье',
    };

    final targetWeekday = DateTime.now().add(Duration(days: deltaDays)).weekday;
    return map[targetWeekday] ?? 'Понедельник';
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

