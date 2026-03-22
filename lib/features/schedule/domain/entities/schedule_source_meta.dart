import 'package:flutter/foundation.dart';

enum ScheduleSourceType {
  googleSheets,
  directXlsx,
  mockAsset,
}

@immutable
class ScheduleSourceMeta {
  const ScheduleSourceMeta({
    required this.sourceType,
    required this.originalUrl,
    required this.downloadUrl,
    required this.lastUpdated,
    required this.isOfflineCached,
    this.localFilePath,
    this.parserWarnings = const <String>[],
  });

  final ScheduleSourceType sourceType;
  final String originalUrl;
  final String downloadUrl;
  final DateTime lastUpdated;
  final bool isOfflineCached;
  final String? localFilePath;
  final List<String> parserWarnings;

  ScheduleSourceMeta copyWith({
    ScheduleSourceType? sourceType,
    String? originalUrl,
    String? downloadUrl,
    DateTime? lastUpdated,
    bool? isOfflineCached,
    Object? localFilePath = _metaNoChange,
    List<String>? parserWarnings,
  }) {
    return ScheduleSourceMeta(
      sourceType: sourceType ?? this.sourceType,
      originalUrl: originalUrl ?? this.originalUrl,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isOfflineCached: isOfflineCached ?? this.isOfflineCached,
      localFilePath: localFilePath == _metaNoChange
          ? this.localFilePath
          : localFilePath as String?,
      parserWarnings: parserWarnings ?? this.parserWarnings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceType': sourceType.name,
      'originalUrl': originalUrl,
      'downloadUrl': downloadUrl,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isOfflineCached': isOfflineCached,
      'localFilePath': localFilePath,
      'parserWarnings': parserWarnings,
    };
  }

  factory ScheduleSourceMeta.fromJson(Map<String, dynamic> json) {
    final sourceType = ScheduleSourceType.values.firstWhere(
      (item) => item.name == json['sourceType']?.toString(),
      orElse: () => ScheduleSourceType.directXlsx,
    );

    final rawWarnings = json['parserWarnings'];
    final warnings = rawWarnings is List
        ? rawWarnings.map((item) => item.toString()).toList(growable: false)
        : const <String>[];

    return ScheduleSourceMeta(
      sourceType: sourceType,
      originalUrl: json['originalUrl']?.toString() ?? '',
      downloadUrl: json['downloadUrl']?.toString() ?? '',
      lastUpdated: DateTime.tryParse(json['lastUpdated']?.toString() ?? '') ??
          DateTime.now(),
      isOfflineCached: json['isOfflineCached'] == true,
      localFilePath: json['localFilePath']?.toString(),
      parserWarnings: warnings,
    );
  }
}

const Object _metaNoChange = Object();

