import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:schedule_app/core/errors/app_exception.dart';
import 'package:schedule_app/features/schedule/data/parsing/logger/spreadsheet_parser_logger.dart';
import 'package:schedule_app/features/schedule/data/parsing/models/spreadsheet_matrix.dart';

class SpreadsheetWorkbookReader {
  const SpreadsheetWorkbookReader({
    required this.logger,
  });

  final SpreadsheetParserLogger logger;

  SpreadsheetMatrix readFromBytes(Uint8List bytes) {
    try {
      final workbook = Excel.decodeBytes(bytes);
      if (workbook.tables.isEmpty) {
        throw const CacheException('Workbook has no sheets.');
      }

      final sheetName = workbook.tables.keys.first;
      final sheet = workbook.tables[sheetName];
      if (sheet == null) {
        throw const CacheException('Failed to open first sheet.');
      }

      logger.log('Reading sheet "$sheetName" with ${sheet.rows.length} rows.');

      final rows = <List<String>>[];
      for (final row in sheet.rows) {
        rows.add(
          row
              .map((cell) => _cellToString(cell))
              .toList(growable: false),
        );
      }

      return SpreadsheetMatrix(rows);
    } catch (error) {
      if (error is AppException) {
        rethrow;
      }
      throw CacheException('Failed to decode spreadsheet bytes: $error');
    }
  }

  String _cellToString(Data? data) {
    final value = data?.value;
    if (value == null) {
      return '';
    }
    return value.toString();
  }
}

