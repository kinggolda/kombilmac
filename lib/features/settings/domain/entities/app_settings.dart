import 'package:flutter/material.dart';

enum AppThemePreference { system, light, dark }

extension AppThemePreferenceX on AppThemePreference {
  String get storageKey => name;

  ThemeMode toThemeMode() {
    switch (this) {
      case AppThemePreference.system:
        return ThemeMode.system;
      case AppThemePreference.light:
        return ThemeMode.light;
      case AppThemePreference.dark:
        return ThemeMode.dark;
    }
  }

  static AppThemePreference fromStorage(String? value) {
    return AppThemePreference.values.firstWhere(
      (item) => item.name == value,
      orElse: () => AppThemePreference.system,
    );
  }
}

@immutable
class AppSettings {
  const AppSettings({
    required this.themePreference,
    required this.localeCode,
    required this.use24HourFormat,
    required this.onboardingCompleted,
    required this.pushStubEnabled,
  });

  final AppThemePreference themePreference;
  final String localeCode;
  final bool use24HourFormat;
  final bool onboardingCompleted;
  final bool pushStubEnabled;

  AppSettings copyWith({
    AppThemePreference? themePreference,
    String? localeCode,
    bool? use24HourFormat,
    bool? onboardingCompleted,
    bool? pushStubEnabled,
  }) {
    return AppSettings(
      themePreference: themePreference ?? this.themePreference,
      localeCode: localeCode ?? this.localeCode,
      use24HourFormat: use24HourFormat ?? this.use24HourFormat,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      pushStubEnabled: pushStubEnabled ?? this.pushStubEnabled,
    );
  }
}

