import 'dart:typed_data';

import 'package:schedule_app/features/schedule/data/models/spreadsheet_source_info.dart';

class DownloadedScheduleFile {
  const DownloadedScheduleFile({
    required this.bytes,
    required this.sourceInfo,
    required this.downloadedAt,
    this.localFilePath,
  });

  final Uint8List bytes;
  final SpreadsheetSourceInfo sourceInfo;
  final DateTime downloadedAt;
  final String? localFilePath;
}

