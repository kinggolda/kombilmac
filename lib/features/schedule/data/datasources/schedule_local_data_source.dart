import 'dart:convert';

import 'package:schedule_app/core/errors/app_exception.dart';
import 'package:schedule_app/core/services/local_storage_service.dart';
import 'package:schedule_app/features/schedule/domain/entities/schedule_dataset.dart';

class ScheduleCacheDataSource {
  static const String _datasetKey = 'schedule_dataset_json';
  static const String _sourceUrlKey = 'schedule_source_url';
  static const String _selectedGroupKey = 'selected_group_name';
  static const String _selectedSubgroupKey = 'selected_subgroup_name';

  Future<void> saveDataset(ScheduleDataset dataset) async {
    try {
      final raw = jsonEncode(dataset.toJson());
      await LocalStorageService.cacheBox.put(_datasetKey, raw);
    } catch (error) {
      throw CacheException('Failed to save schedule dataset cache: $error');
    }
  }

  Future<ScheduleDataset?> readDataset() async {
    try {
      final raw = LocalStorageService.cacheBox.get(_datasetKey);
      if (raw is! String || raw.trim().isEmpty) {
        return null;
      }

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return ScheduleDataset.fromJson(decoded);
    } catch (error) {
      throw CacheException('Failed to read schedule dataset cache: $error');
    }
  }

  Future<void> clearCache() async {
    try {
      await LocalStorageService.cacheBox.delete(_datasetKey);
      await LocalStorageService.cacheBox.delete(_selectedGroupKey);
      await LocalStorageService.cacheBox.delete(_selectedSubgroupKey);
    } catch (error) {
      throw CacheException('Failed to clear schedule cache: $error');
    }
  }

  Future<void> saveSourceUrl(String sourceUrl) async {
    await LocalStorageService.cacheBox.put(_sourceUrlKey, sourceUrl);
  }

  String? getSourceUrl() {
    final raw = LocalStorageService.cacheBox.get(_sourceUrlKey);
    if (raw is String && raw.trim().isNotEmpty) {
      return raw;
    }
    return null;
  }

  Future<void> saveSelection({
    String? groupName,
    String? subgroupName,
  }) async {
    if (groupName == null || groupName.trim().isEmpty) {
      await LocalStorageService.cacheBox.delete(_selectedGroupKey);
    } else {
      await LocalStorageService.cacheBox.put(_selectedGroupKey, groupName);
    }

    if (subgroupName == null || subgroupName.trim().isEmpty) {
      await LocalStorageService.cacheBox.delete(_selectedSubgroupKey);
    } else {
      await LocalStorageService.cacheBox.put(_selectedSubgroupKey, subgroupName);
    }
  }

  String? getLastSelectedGroup() {
    final raw = LocalStorageService.cacheBox.get(_selectedGroupKey);
    if (raw is String && raw.trim().isNotEmpty) {
      return raw;
    }
    return null;
  }

  String? getLastSelectedSubgroup() {
    final raw = LocalStorageService.cacheBox.get(_selectedSubgroupKey);
    if (raw is String && raw.trim().isNotEmpty) {
      return raw;
    }
    return null;
  }
}

