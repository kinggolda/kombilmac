import 'package:schedule_app/features/schedule/domain/entities/schedule_dataset.dart';

abstract class ScheduleRepository {
  Future<void> downloadScheduleFile({
    required String sourceUrl,
  });

  Future<ScheduleDataset> loadAndParseSchedule({
    required String sourceUrl,
    bool forceRefresh = false,
  });

  Future<ScheduleDataset?> loadCachedSchedule();

  Future<void> clearCache();

  Future<void> saveSourceUrl(String sourceUrl);

  String? getStoredSourceUrl();

  Future<void> saveLastSelection({
    String? groupName,
    String? subgroupName,
  });

  String? getLastSelectedGroup();

  String? getLastSelectedSubgroup();
}

