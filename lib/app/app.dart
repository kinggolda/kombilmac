import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schedule_app/app/router/app_router.dart';
import 'package:schedule_app/features/settings/domain/entities/app_settings.dart';
import 'package:schedule_app/features/settings/presentation/providers/settings_providers.dart';
import 'package:schedule_app/shared/localization/app_strings.dart';
import 'package:schedule_app/shared/theme/app_theme.dart';

class ScheduleApp extends ConsumerWidget {
  const ScheduleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);

    return MaterialApp.router(
      title: 'Schedule App',
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(appRouterProvider),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themePreference.toThemeMode(),
      locale: Locale(settings.localeCode),
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.25,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

