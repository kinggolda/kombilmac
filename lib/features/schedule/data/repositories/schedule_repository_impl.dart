import 'package:schedule_app/core/env/app_config.dart';
import 'package:schedule_app/core/errors/app_exception.dart';
import 'package:schedule_app/features/schedule/data/datasources/schedule_local_data_source.dart';
import 'package:schedule_app/features/schedule/data/datasources/schedule_mock_data_source.dart';
import 'package:schedule_app/features/schedule/data/datasources/schedule_remote_data_source.dart';
import 'package:schedule_app/features/schedule/data/models/spreadsheet_source_info.dart';
import 'package:schedule_app/features/schedule/data/parsing/models/parsed_spreadsheet_payload.dart';
import 'package:schedule_app/features/schedule/data/parsing/rules/spreadsheet_parsing_rules.dart';
import 'package:schedule_app/features/schedule/data/parsing/spreadsheet_workbook_reader.dart';
import 'package:schedule_app/features/schedule/data/parsing/strategy/spreadsheet_parser_strategy.dart';
import 'package:schedule_app/features/schedule/domain/entities/group.dart';
import 'package:schedule_app/features/schedule/domain/entities/lesson.dart';
import 'package:schedule_app/features/schedule/domain/entities/schedule_dataset.dart';
import 'package:schedule_app/features/schedule/domain/entities/schedule_day.dart';
import 'package:schedule_app/features/schedule/domain/entities/schedule_source_meta.dart';
import 'package:schedule_app/features/schedule/domain/entities/subgroup.dart';
import 'package:schedule_app/features/schedule/domain/repositories/schedule_repository.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  const ScheduleRepositoryImpl({
    required this.remoteDataSource,
    required this.cacheDataSource,
    required this.mockDataSource,
    required this.workbookReader,
    required this.parserStrategy,
    required this.parsingRules,
    required this.config,
  });

  final ScheduleFileRemoteDataSource remoteDataSource;
  final ScheduleCacheDataSource cacheDataSource;
  final ScheduleMockDataSource mockDataSource;
  final SpreadsheetWorkbookReader workbookReader;
  final SpreadsheetParserStrategy parserStrategy;
  final SpreadsheetParsingRules parsingRules;
  final AppConfig config;

  @override
  Future<void> downloadScheduleFile({required String sourceUrl}) async {
    await remoteDataSource.downloadFile(sourceUrl: sourceUrl);
  }

  @override
  Future<ScheduleDataset> loadAndParseSchedule({
    required String sourceUrl,
    bool forceRefresh = false,
  }) async {
    try {
      final file = await remoteDataSource.downloadFile(sourceUrl: sourceUrl);
      final matrix = workbookReader.readFromBytes(file.bytes);
      final parsed = parserStrategy.parse(matrix: matrix, rules: parsingRules);

      final dataset = _buildDataset(
        parsed: parsed,
        sourceInfo: file.sourceInfo,
        localFilePath: file.localFilePath,
        isOfflineCached: false,
      );

      await cacheDataSource.saveDataset(dataset);
      await cacheDataSource.saveSourceUrl(sourceUrl);

      return dataset;
    } on AppException {
      final cached = await loadCachedSchedule();
      if (cached != null) {
        return cached;
      }

      if (config.useMockSpreadsheetFallback) {
        final matrix = await mockDataSource.loadMockMatrix();
        final parsed = parserStrategy.parse(matrix: matrix, rules: parsingRules);
        final sourceInfo = SpreadsheetSourceInfo(
          sourceType: ScheduleSourceType.mockAsset,
          originalUrl: sourceUrl,
          downloadUrl: 'assets/mocks/mock_spreadsheet_matrix.json',
        );

        final dataset = _buildDataset(
          parsed: parsed,
          sourceInfo: sourceInfo,
          localFilePath: null,
          isOfflineCached: true,
        );

        await cacheDataSource.saveDataset(dataset);
        return dataset;
      }

      rethrow;
    }
  }

  @override
  Future<ScheduleDataset?> loadCachedSchedule() async {
    final cached = await cacheDataSource.readDataset();
    if (cached == null) {
      return null;
    }

    return cached.copyWith(
      sourceMeta: cached.sourceMeta.copyWith(
        isOfflineCached: true,
      ),
    );
  }

  @override
  Future<void> clearCache() => cacheDataSource.clearCache();

  @override
  Future<void> saveSourceUrl(String sourceUrl) {
    return cacheDataSource.saveSourceUrl(sourceUrl);
  }

  @override
  String? getStoredSourceUrl() => cacheDataSource.getSourceUrl();

  @override
  Future<void> saveLastSelection({
    String? groupName,
    String? subgroupName,
  }) {
    return cacheDataSource.saveSelection(
      groupName: groupName,
      subgroupName: subgroupName,
    );
  }

  @override
  String? getLastSelectedGroup() => cacheDataSource.getLastSelectedGroup();

  @override
  String? getLastSelectedSubgroup() => cacheDataSource.getLastSelectedSubgroup();

  ScheduleDataset _buildDataset({
    required ParsedSpreadsheetPayload parsed,
    required SpreadsheetSourceInfo sourceInfo,
    required String? localFilePath,
    required bool isOfflineCached,
  }) {
    final groupsMap = <String, Set<String>>{};

    for (final lesson in parsed.lessons) {
      groupsMap.putIfAbsent(lesson.group, () => <String>{});
      if ((lesson.subgroup ?? '').trim().isNotEmpty) {
        groupsMap[lesson.group]!.add(lesson.subgroup!.trim());
      }
    }

    for (final entry in parsed.subgroupsByGroup.entries) {
      groupsMap.putIfAbsent(entry.key, () => <String>{});
      groupsMap[entry.key]!.addAll(entry.value);
    }

    final groups = groupsMap.entries
        .map(
          (entry) => Group(
            id: _slugify(entry.key),
            name: entry.key,
            subgroups: entry.value
                .where((item) => item.trim().isNotEmpty)
                .map(
                  (subgroup) => Subgroup(
                    id: _slugify('${entry.key}_$subgroup'),
                    name: subgroup,
                  ),
                )
                .toList(growable: false)
              ..sort((a, b) => a.name.compareTo(b.name)),
          ),
        )
        .toList(growable: false)
      ..sort((a, b) => a.name.compareTo(b.name));

    final dayBuckets = <String, List<Lesson>>{};
    for (final lesson in parsed.lessons) {
      dayBuckets.putIfAbsent(lesson.weekday, () => <Lesson>[]);
      dayBuckets[lesson.weekday]!.add(lesson);
    }

    final days = dayBuckets.entries
        .map(
          (entry) => ScheduleDay(
            weekday: entry.key,
            lessons: entry.value,
          ),
        )
        .toList(growable: false)
      ..sort((a, b) => _weekdayOrder(a.weekday).compareTo(_weekdayOrder(b.weekday)));

    final sourceMeta = ScheduleSourceMeta(
      sourceType: sourceInfo.sourceType,
      originalUrl: sourceInfo.originalUrl,
      downloadUrl: sourceInfo.downloadUrl,
      lastUpdated: DateTime.now(),
      isOfflineCached: isOfflineCached,
      localFilePath: localFilePath,
      parserWarnings: parsed.warnings,
    );

    return ScheduleDataset(
      groups: groups,
      days: days,
      lessons: parsed.lessons,
      sourceMeta: sourceMeta,
    );
  }

  String _slugify(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-zа-я0-9_]'), '');
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

