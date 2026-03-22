import 'package:shared_preferences/shared_preferences.dart';
import 'package:schedule_app/features/settings/domain/entities/app_settings.dart';

class SettingsService {
  static const String _themeModeKey = 'theme_mode';
  static const String _localeCodeKey = 'locale_code';
  static const String _is24HourFormatKey = 'is_24_hour_format';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _pushStubEnabledKey = 'push_stub_enabled';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get _instance {
    final instance = _prefs;
    if (instance == null) {
      throw StateError('SettingsService was not initialized.');
    }
    return instance;
  }

  AppThemePreference get themePreference {
    final raw = _instance.getString(_themeModeKey);
    return AppThemePreferenceX.fromStorage(raw);
  }

  String get localeCode {
    final raw = _instance.getString(_localeCodeKey);
    return _normalizeLocale(raw);
  }

  bool get use24HourFormat => _instance.getBool(_is24HourFormatKey) ?? true;

  bool get onboardingCompleted =>
      _instance.getBool(_onboardingCompletedKey) ?? false;

  bool get pushStubEnabled => _instance.getBool(_pushStubEnabledKey) ?? false;

  Future<void> saveThemePreference(AppThemePreference preference) async {
    await _instance.setString(_themeModeKey, preference.storageKey);
  }

  Future<void> saveLocaleCode(String localeCode) async {
    await _instance.setString(_localeCodeKey, _normalizeLocale(localeCode));
  }

  Future<void> save24HourFormat(bool enabled) async {
    await _instance.setBool(_is24HourFormatKey, enabled);
  }

  Future<void> saveOnboardingCompleted(bool completed) async {
    await _instance.setBool(_onboardingCompletedKey, completed);
  }

  Future<void> savePushStubEnabled(bool enabled) async {
    await _instance.setBool(_pushStubEnabledKey, enabled);
  }

  String _normalizeLocale(String? localeCode) {
    if (localeCode == 'en') {
      return 'en';
    }
    return 'ru';
  }
}

