import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schedule_app/app/app.dart';
import 'package:schedule_app/app/providers/app_config_provider.dart';
import 'package:schedule_app/core/env/app_config.dart';
import 'package:schedule_app/core/services/local_storage_service.dart';
import 'package:schedule_app/core/services/settings_service.dart';
import 'package:schedule_app/features/settings/presentation/providers/settings_providers.dart';

Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorageService.init();

  final settingsService = SettingsService();
  await settingsService.init();

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
        settingsServiceProvider.overrideWithValue(settingsService),
      ],
      child: const ScheduleApp(),
    ),
  );
}

