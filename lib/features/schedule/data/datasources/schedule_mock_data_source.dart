import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:schedule_app/core/errors/app_exception.dart';
import 'package:schedule_app/features/schedule/data/parsing/models/spreadsheet_matrix.dart';

class ScheduleMockDataSource {
  const ScheduleMockDataSource();

  Future<SpreadsheetMatrix> loadMockMatrix() async {
    try {
      final payload = await rootBundle.loadString(
        'assets/mocks/mock_spreadsheet_matrix.json',
      );

      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        throw const CacheException('Mock spreadsheet asset has invalid format.');
      }

      final rawRows = decoded['rows'];
      if (rawRows is! List) {
        throw const CacheException('Mock spreadsheet rows are missing.');
      }

      final rows = rawRows
          .whereType<List>()
          .map(
            (row) => row.map((cell) => cell?.toString() ?? '').toList(growable: false),
          )
          .toList(growable: false);

      return SpreadsheetMatrix(rows);
    } on AppException {
      rethrow;
    } catch (error) {
      throw CacheException('Failed to load mock spreadsheet matrix: $error');
    }
  }
}

