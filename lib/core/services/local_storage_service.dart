import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static const String cacheBoxName = 'schedule_cache_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(cacheBoxName)) {
      await Hive.openBox<dynamic>(cacheBoxName);
    }
  }

  static Box<dynamic> get cacheBox => Hive.box<dynamic>(cacheBoxName);
}

