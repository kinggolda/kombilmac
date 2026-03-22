import 'package:schedule_app/features/schedule/domain/entities/schedule_source_meta.dart';

class SpreadsheetSourceInfo {
  const SpreadsheetSourceInfo({
    required this.sourceType,
    required this.originalUrl,
    required this.downloadUrl,
    this.spreadsheetId,
    this.gid,
  });

  final ScheduleSourceType sourceType;
  final String originalUrl;
  final String downloadUrl;
  final String? spreadsheetId;
  final String? gid;
}

