import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:schedule_app/core/errors/app_exception.dart';
import 'package:schedule_app/features/schedule/data/models/downloaded_schedule_file.dart';
import 'package:schedule_app/features/schedule/data/utils/spreadsheet_source_url_resolver.dart';

class ScheduleFileRemoteDataSource {
  const ScheduleFileRemoteDataSource({
    required Dio dio,
    required SpreadsheetSourceUrlResolver resolver,
  })  : _dio = dio,
        _resolver = resolver;

  final Dio _dio;
  final SpreadsheetSourceUrlResolver _resolver;

  Future<DownloadedScheduleFile> downloadFile({
    required String sourceUrl,
  }) async {
    final sourceInfo = _resolver.resolve(sourceUrl);

    try {
      final response = await _dio.get<List<int>>(
        sourceInfo.downloadUrl,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
      );

      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        throw const NetworkException('Downloaded file is empty.');
      }

      final typedBytes = Uint8List.fromList(bytes);
      final localPath = await _persistLocalCopy(typedBytes);

      return DownloadedScheduleFile(
        bytes: typedBytes,
        sourceInfo: sourceInfo,
        downloadedAt: DateTime.now(),
        localFilePath: localPath,
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    } on AppException {
      rethrow;
    } catch (error) {
      throw NetworkException('Failed to download spreadsheet file: $error');
    }
  }

  Future<String?> _persistLocalCopy(Uint8List bytes) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/schedule_latest.xlsx');
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (_) {
      return null;
    }
  }
}

