import 'dart:math';

import 'package:schedule_app/features/schedule/data/parsing/logger/spreadsheet_parser_logger.dart';
import 'package:schedule_app/features/schedule/data/parsing/models/parsed_spreadsheet_payload.dart';
import 'package:schedule_app/features/schedule/data/parsing/models/spreadsheet_matrix.dart';
import 'package:schedule_app/features/schedule/data/parsing/rules/spreadsheet_parsing_rules.dart';
import 'package:schedule_app/features/schedule/data/parsing/strategy/spreadsheet_parser_strategy.dart';
import 'package:schedule_app/features/schedule/domain/entities/lesson.dart';

class DefaultSpreadsheetParserStrategy implements SpreadsheetParserStrategy {
  const DefaultSpreadsheetParserStrategy({
    required this.logger,
  });

  final SpreadsheetParserLogger logger;

  @override
  ParsedSpreadsheetPayload parse({
    required SpreadsheetMatrix matrix,
    required SpreadsheetParsingRules rules,
  }) {
    final warnings = <String>[];

    final table = matrix.rectangular();
    if (table.isEmpty) {
      warnings.add('Spreadsheet is empty.');
      return ParsedSpreadsheetPayload(
        lessons: const <Lesson>[],
        subgroupsByGroup: const <String, Set<String>>{},
        warnings: warnings,
      );
    }

    final headerRow = _detectHeaderRow(table, rules);
    if (headerRow < 0) {
      warnings.add('Could not detect group header row.');
    }

    final subgroupRow = _detectSubgroupRow(table, rules, headerRow);

    final dayColumn = _detectWeekdayColumn(table, rules);
    final timeColumn = _detectTimeColumn(table, rules, dayColumn);
    final indexColumn = _detectIndexColumn(table, dayColumn, timeColumn);

    logger.log(
      'Detected layout: headerRow=$headerRow subgroupRow=$subgroupRow dayColumn=$dayColumn timeColumn=$timeColumn indexColumn=$indexColumn',
    );

    final bindings = _buildColumnBindings(
      table: table,
      rules: rules,
      headerRow: max(headerRow, 0),
      subgroupRow: subgroupRow,
      dayColumn: dayColumn,
      timeColumn: timeColumn,
      indexColumn: indexColumn,
    );

    if (bindings.isEmpty) {
      warnings.add('No group columns detected.');
      return ParsedSpreadsheetPayload(
        lessons: const <Lesson>[],
        subgroupsByGroup: const <String, Set<String>>{},
        warnings: warnings,
      );
    }

    final parseResult = _parseLessons(
      table: table,
      rules: rules,
      bindings: bindings,
      headerRow: max(headerRow, 0),
      subgroupRow: subgroupRow,
      dayColumn: dayColumn,
      timeColumn: timeColumn,
      indexColumn: indexColumn,
    );

    warnings.addAll(parseResult.warnings);

    return ParsedSpreadsheetPayload(
      lessons: parseResult.lessons,
      subgroupsByGroup: parseResult.subgroupsByGroup,
      warnings: warnings,
    );
  }

  int _detectHeaderRow(SpreadsheetMatrix table, SpreadsheetParsingRules rules) {
    final scanRows = min(table.rowCount, rules.headerScanRows);
    var bestRow = -1;
    var bestScore = 0;

    for (var row = 0; row < scanRows; row++) {
      var groupLikeCount = 0;
      for (var col = 0; col < table.columnCount; col++) {
        final value = table.cell(row, col);
        if (_looksLikeGroupName(value, rules)) {
          groupLikeCount += 1;
        }
      }

      if (groupLikeCount > bestScore) {
        bestScore = groupLikeCount;
        bestRow = row;
      }
    }

    return bestScore >= 2 ? bestRow : -1;
  }

  int? _detectSubgroupRow(
    SpreadsheetMatrix table,
    SpreadsheetParsingRules rules,
    int headerRow,
  ) {
    if (headerRow < 0) {
      return null;
    }

    var bestRow = -1;
    var bestScore = 0;

    final endRow = min(table.rowCount, headerRow + rules.subgroupScanDepth + 1);
    for (var row = headerRow + 1; row < endRow; row++) {
      var subgroupCount = 0;
      for (var col = 0; col < table.columnCount; col++) {
        if (rules.subgroupPattern.hasMatch(table.cell(row, col).trim())) {
          subgroupCount += 1;
        }
      }

      if (subgroupCount > bestScore) {
        bestScore = subgroupCount;
        bestRow = row;
      }
    }

    return bestScore >= 2 ? bestRow : null;
  }

  int _detectWeekdayColumn(SpreadsheetMatrix table, SpreadsheetParsingRules rules) {
    var bestColumn = 0;
    var bestScore = -1;

    for (var col = 0; col < table.columnCount; col++) {
      var score = 0;
      for (var row = 0; row < min(table.rowCount, 60); row++) {
        if (rules.isWeekday(table.cell(row, col))) {
          score += 1;
        }
      }

      if (score > bestScore) {
        bestScore = score;
        bestColumn = col;
      }
    }

    return bestColumn;
  }

  int _detectTimeColumn(
    SpreadsheetMatrix table,
    SpreadsheetParsingRules rules,
    int weekdayColumn,
  ) {
    var bestColumn = weekdayColumn == 0 ? 1 : 0;
    var bestScore = -1;

    for (var col = 0; col < table.columnCount; col++) {
      if (col == weekdayColumn) {
        continue;
      }

      var score = 0;
      for (var row = 0; row < min(table.rowCount, 80); row++) {
        if (rules.timeRangePattern.hasMatch(table.cell(row, col))) {
          score += 1;
        }
      }

      if (score > bestScore) {
        bestScore = score;
        bestColumn = col;
      }
    }

    return bestColumn;
  }

  int _detectIndexColumn(
    SpreadsheetMatrix table,
    int weekdayColumn,
    int timeColumn,
  ) {
    var bestColumn = 0;
    var bestScore = -1;

    for (var col = 0; col < table.columnCount; col++) {
      if (col == weekdayColumn || col == timeColumn) {
        continue;
      }

      var score = 0;
      for (var row = 0; row < min(table.rowCount, 80); row++) {
        final value = table.cell(row, col).trim();
        final number = int.tryParse(value);
        if (number != null && number > 0 && number < 20) {
          score += 1;
        }
      }

      if (score > bestScore) {
        bestScore = score;
        bestColumn = col;
      }
    }

    if (bestScore <= 1) {
      return max(0, min(weekdayColumn, timeColumn) - 1);
    }

    return bestColumn;
  }

  Map<int, _ColumnBinding> _buildColumnBindings({
    required SpreadsheetMatrix table,
    required SpreadsheetParsingRules rules,
    required int headerRow,
    required int? subgroupRow,
    required int dayColumn,
    required int timeColumn,
    required int indexColumn,
  }) {
    final startDataColumn = max(dayColumn, max(timeColumn, indexColumn)) + 1;
    final bindings = <int, _ColumnBinding>{};

    var currentGroup = '';

    for (var col = startDataColumn; col < table.columnCount; col++) {
      final headerValue = table.cell(headerRow, col);
      if (_looksLikeGroupName(headerValue, rules)) {
        currentGroup = _normalizeGroupName(headerValue);
        logger.log('Detected group "$currentGroup" at column $col');
      }

      if (currentGroup.isEmpty) {
        continue;
      }

      final subgroup = subgroupRow == null
          ? null
          : _normalizeSubgroup(table.cell(subgroupRow, col), rules);

      bindings[col] = _ColumnBinding(
        groupName: currentGroup,
        subgroupName: subgroup,
      );
    }

    return bindings;
  }

  _ParsedLessonsResult _parseLessons({
    required SpreadsheetMatrix table,
    required SpreadsheetParsingRules rules,
    required Map<int, _ColumnBinding> bindings,
    required int headerRow,
    required int? subgroupRow,
    required int dayColumn,
    required int timeColumn,
    required int indexColumn,
  }) {
    final warnings = <String>[];

    final dataStartRow = (subgroupRow ?? headerRow) + 1;
    var currentWeekday = '';
    var currentStart = '';
    var currentEnd = '';
    var currentLessonIndex = 0;

    final drafts = <String, _LessonDraft>{};
    final subgroupsByGroup = <String, Set<String>>{};

    for (var row = dataStartRow; row < table.rowCount; row++) {
      final weekdayFromCell = rules.normalizeWeekday(table.cell(row, dayColumn));
      if (weekdayFromCell != null) {
        currentWeekday = weekdayFromCell;
        currentLessonIndex = 0;
      }

      if (currentWeekday.isEmpty) {
        continue;
      }

      final rawTime = table.cell(row, timeColumn);
      final timeMatch = rules.timeRangePattern.firstMatch(rawTime);
      if (timeMatch != null) {
        currentStart = _normalizeTime(timeMatch.group(1) ?? '');
        currentEnd = _normalizeTime(timeMatch.group(2) ?? '');
      }

      final rawIndex = table.cell(row, indexColumn).trim();
      final parsedIndex = int.tryParse(rawIndex);
      if (parsedIndex != null) {
        currentLessonIndex = parsedIndex;
      } else if (timeMatch != null) {
        currentLessonIndex += 1;
      }

      if (currentStart.isEmpty || currentEnd.isEmpty) {
        continue;
      }
      if (currentLessonIndex <= 0) {
        currentLessonIndex = 1;
      }

      for (final entry in bindings.entries) {
        final column = entry.key;
        final binding = entry.value;

        final rawCell = table.cell(row, column);
        if (rawCell.isEmpty) {
          continue;
        }

        final parsedCell = _parseLessonCell(rawCell, rules);
        final key = _buildLessonKey(
          weekday: currentWeekday,
          index: currentLessonIndex,
          startTime: currentStart,
          endTime: currentEnd,
          group: binding.groupName,
          subgroup: binding.subgroupName,
        );

        if ((parsedCell.subject.isEmpty) &&
            (parsedCell.teacher != null || parsedCell.room != null)) {
          final existing = drafts[key];
          if (existing != null) {
            existing.teacher ??= parsedCell.teacher;
            existing.room ??= parsedCell.room;
            existing.rawCellValue =
                '${existing.rawCellValue ?? ''}\n${parsedCell.rawCellValue}'.trim();
          }
          continue;
        }

        final draft = drafts[key] ??
            _LessonDraft(
              lessonIndex: currentLessonIndex,
              weekday: currentWeekday,
              startTime: currentStart,
              endTime: currentEnd,
              group: binding.groupName,
              subgroup: binding.subgroupName,
            );

        if (parsedCell.subject.isNotEmpty) {
          draft.subject = parsedCell.subject;
        }
        draft.teacher ??= parsedCell.teacher;
        draft.room ??= parsedCell.room;
        draft.rawCellValue =
            '${draft.rawCellValue ?? ''}\n${parsedCell.rawCellValue}'.trim();
        drafts[key] = draft;

        final subgroupName = binding.subgroupName;
        if (subgroupName != null && subgroupName.isNotEmpty) {
          subgroupsByGroup.putIfAbsent(binding.groupName, () => <String>{});
          subgroupsByGroup[binding.groupName]!.add(subgroupName);
        }
      }
    }

    final lessons = drafts.values
        .where((item) => item.subject.trim().isNotEmpty)
        .map((item) => item.toEntity())
        .toList(growable: false)
      ..sort((a, b) {
        final weekdayOrder = _weekdayOrder(a.weekday).compareTo(_weekdayOrder(b.weekday));
        if (weekdayOrder != 0) {
          return weekdayOrder;
        }
        if (a.lessonIndex != b.lessonIndex) {
          return a.lessonIndex.compareTo(b.lessonIndex);
        }
        return a.startTime.compareTo(b.startTime);
      });

    if (lessons.isEmpty) {
      warnings.add('Parser produced zero lessons. Check parsing rules.');
    }

    logger.log('Parser produced ${lessons.length} lessons.');

    return _ParsedLessonsResult(
      lessons: lessons,
      subgroupsByGroup: subgroupsByGroup,
      warnings: warnings,
    );
  }

  _ParsedCell _parseLessonCell(String rawCell, SpreadsheetParsingRules rules) {
    final normalized = rawCell.replaceAll('\u00A0', ' ').trim();

    final segments = normalized
        .split(RegExp(r'[\n;|]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    var subject = '';
    String? teacher;
    String? room;

    for (final segment in segments) {
      if (teacher == null && rules.teacherPattern.hasMatch(segment)) {
        teacher = segment;
        continue;
      }
      if (room == null && rules.roomPattern.hasMatch(segment.toLowerCase())) {
        room = segment;
        continue;
      }
      if (subject.isEmpty) {
        subject = segment;
      }
    }

    if (subject.isNotEmpty && rules.teacherPattern.hasMatch(subject) && teacher == null) {
      teacher = subject;
      subject = '';
    }

    return _ParsedCell(
      subject: subject,
      teacher: teacher,
      room: room,
      rawCellValue: normalized,
    );
  }

  String _buildLessonKey({
    required String weekday,
    required int index,
    required String startTime,
    required String endTime,
    required String group,
    required String? subgroup,
  }) {
    return '$weekday|$index|$startTime|$endTime|$group|${subgroup ?? ''}';
  }

  bool _looksLikeGroupName(String value, SpreadsheetParsingRules rules) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return false;
    }

    if (rules.isWeekday(normalized)) {
      return false;
    }

    if (rules.timeRangePattern.hasMatch(normalized)) {
      return false;
    }

    if (rules.ignoredHeaderTokens.contains(normalized.toLowerCase())) {
      return false;
    }

    return rules.groupNamePattern.hasMatch(normalized);
  }

  String _normalizeGroupName(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String? _normalizeSubgroup(String value, SpreadsheetParsingRules rules) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (!rules.subgroupPattern.hasMatch(trimmed)) {
      return null;
    }
    return trimmed;
  }

  String _normalizeTime(String value) {
    final cleaned = value.replaceAll('.', ':').trim();
    if (cleaned.length == 4) {
      return '0$cleaned';
    }
    return cleaned;
  }

  int _weekdayOrder(String weekday) {
    switch (weekday) {
      case 'Понедельник':
        return 1;
      case 'Вторник':
        return 2;
      case 'Среда':
        return 3;
      case 'Четверг':
        return 4;
      case 'Пятница':
        return 5;
      case 'Суббота':
        return 6;
      case 'Воскресенье':
        return 7;
      default:
        return 99;
    }
  }
}

class _ColumnBinding {
  const _ColumnBinding({
    required this.groupName,
    required this.subgroupName,
  });

  final String groupName;
  final String? subgroupName;
}

class _ParsedCell {
  const _ParsedCell({
    required this.subject,
    required this.teacher,
    required this.room,
    required this.rawCellValue,
  });

  final String subject;
  final String? teacher;
  final String? room;
  final String rawCellValue;
}

class _LessonDraft {
  _LessonDraft({
    required this.lessonIndex,
    required this.weekday,
    required this.startTime,
    required this.endTime,
    required this.group,
    required this.subgroup,
  });

  final int lessonIndex;
  final String weekday;
  final String startTime;
  final String endTime;
  final String group;
  final String? subgroup;

  String subject = '';
  String? teacher;
  String? room;
  String? rawCellValue;

  Lesson toEntity() {
    return Lesson(
      lessonIndex: lessonIndex,
      weekday: weekday,
      startTime: startTime,
      endTime: endTime,
      subject: subject,
      teacher: teacher,
      room: room,
      subgroup: subgroup,
      group: group,
      rawCellValue: rawCellValue,
    );
  }
}

class _ParsedLessonsResult {
  const _ParsedLessonsResult({
    required this.lessons,
    required this.subgroupsByGroup,
    required this.warnings,
  });

  final List<Lesson> lessons;
  final Map<String, Set<String>> subgroupsByGroup;
  final List<String> warnings;
}

