import 'package:schedule_app/features/schedule/data/models/spreadsheet_source_info.dart';
import 'package:schedule_app/features/schedule/domain/entities/schedule_source_meta.dart';

class SpreadsheetSourceUrlResolver {
  const SpreadsheetSourceUrlResolver();

  SpreadsheetSourceInfo resolve(String sourceUrl) {
    final trimmed = sourceUrl.trim();

    final google = _resolveGoogleSheets(trimmed);
    if (google != null) {
      return google;
    }

    return SpreadsheetSourceInfo(
      sourceType: ScheduleSourceType.directXlsx,
      originalUrl: trimmed,
      downloadUrl: trimmed,
    );
  }

  SpreadsheetSourceInfo? _resolveGoogleSheets(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return null;
    }

    if (!uri.host.contains('docs.google.com')) {
      return null;
    }

    final match = RegExp(r'/spreadsheets/d/([a-zA-Z0-9-_]+)').firstMatch(uri.path);
    if (match == null) {
      return null;
    }

    final spreadsheetId = match.group(1);
    if (spreadsheetId == null || spreadsheetId.isEmpty) {
      return null;
    }

    var gid = uri.queryParameters['gid'];
    if ((gid == null || gid.isEmpty) && uri.fragment.contains('gid=')) {
      final fragmentMatch = RegExp(r'gid=(\d+)').firstMatch(uri.fragment);
      gid = fragmentMatch?.group(1);
    }
    gid ??= '0';

    final downloadUrl =
        'https://docs.google.com/spreadsheets/d/$spreadsheetId/export?format=xlsx&gid=$gid';

    return SpreadsheetSourceInfo(
      sourceType: ScheduleSourceType.googleSheets,
      originalUrl: url,
      downloadUrl: downloadUrl,
      spreadsheetId: spreadsheetId,
      gid: gid,
    );
  }
}

