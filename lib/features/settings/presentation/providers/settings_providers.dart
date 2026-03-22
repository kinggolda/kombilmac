import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schedule_app/core/services/settings_service.dart';
import 'package:schedule_app/features/settings/domain/entities/app_settings.dart';

final settingsServiceProvider = Provider<SettingsService>(
  (ref) => throw UnimplementedError(
    'SettingsService must be overridden in bootstrap.',
  ),
);

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AppSettings>(
  (ref) {
    final service = ref.watch(settingsServiceProvider);
    return SettingsController(service);
  },
);

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController(SettingsService service)
      : _service = service,
        super(
          AppSettings(
            themePreference: service.themePreference,
            localeCode: service.localeCode,
            use24HourFormat: service.use24HourFormat,
            onboardingCompleted: service.onboardingCompleted,
            pushStubEnabled: service.pushStubEnabled,
          ),
        );

  final SettingsService _service;

  Future<void> setThemePreference(AppThemePreference preference) async {
    await _service.saveThemePreference(preference);
    state = state.copyWith(themePreference: preference);
  }

  Future<void> setLocaleCode(String localeCode) async {
    await _service.saveLocaleCode(localeCode);
    state = state.copyWith(localeCode: localeCode);
  }

  Future<void> set24HourFormat(bool enabled) async {
    await _service.save24HourFormat(enabled);
    state = state.copyWith(use24HourFormat: enabled);
  }

  Future<void> setPushStubEnabled(bool enabled) async {
    await _service.savePushStubEnabled(enabled);
    state = state.copyWith(pushStubEnabled: enabled);
  }

  Future<void> completeOnboarding() async {
    await _service.saveOnboardingCompleted(true);
    state = state.copyWith(onboardingCompleted: true);
  }

  Future<void> resetOnboarding() async {
    await _service.saveOnboardingCompleted(false);
    state = state.copyWith(onboardingCompleted: false);
  }
}

