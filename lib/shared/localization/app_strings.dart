import 'package:flutter/widgets.dart';

class AppStrings {
  const AppStrings(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[
    Locale('ru'),
    Locale('en'),
  ];

  static AppStrings of(BuildContext context) {
    return AppStrings(Localizations.localeOf(context));
  }

  bool get _isRu => locale.languageCode.toLowerCase().startsWith('ru');

  String _t(String ru, String en) => _isRu ? ru : en;

  String get appTitle => 'Schedule App';
  String get scheduleTitle => _t('Расписание', 'Schedule');
  String get settingsTitle => _t('Настройки', 'Settings');
  String get eventDetails => _t('Детали события', 'Event details');

  String get today => _t('Сегодня', 'Today');
  String get tomorrow => _t('Завтра', 'Tomorrow');
  String get week => _t('Неделя', 'Week');

  String get searchHint => _t('Поиск по расписанию', 'Search in schedule');
  String get filters => _t('Фильтры', 'Filters');
  String get clearFilters => _t('Сбросить фильтры', 'Clear filters');
  String get all => _t('Все', 'All');
  String get apply => _t('Применить', 'Apply');
  String get close => _t('Закрыть', 'Close');

  String get retry => _t('Повторить', 'Retry');
  String get errorTitle => _t('Ошибка загрузки', 'Loading error');
  String get noDataTitle => _t('Пусто', 'Nothing here');
  String get noDataDescription => _t(
        'Расписание пока недоступно. Потяните вниз для обновления.',
        'Schedule is not available yet. Pull to refresh.',
      );
  String get noResultsTitle => _t('Ничего не найдено', 'No results found');
  String get noResultsDescription => _t(
        'Попробуйте изменить поисковый запрос или фильтры.',
        'Try changing your search query or filters.',
      );

  String get fromCacheBanner => _t(
        'Показаны кэшированные данные (офлайн).',
        'Showing cached data (offline).',
      );
  String get fromMockBanner => _t(
        'Показаны тестовые данные из mock spreadsheet.',
        'Showing fallback data from mock spreadsheet.',
      );

  String get updatedAtLabel => _t('Обновлено', 'Updated');
  String get cacheClearedMessage => _t('Кэш очищен.', 'Cache cleared.');
  String get rawCell => _t('Исходная ячейка', 'Raw cell');

  String get theme => _t('Тема', 'Theme');
  String get language => _t('Язык', 'Language');
  String get timeFormat => _t('Формат времени', 'Time format');
  String get use24HourFormat => _t('24-часовой формат', '24-hour format');
  String get pushReadyStructure =>
      _t('Push-ready структура (заглушка)', 'Push-ready structure (stub)');
  String get resetOnboarding => _t(
        'Сбросить onboarding',
        'Reset onboarding',
      );

  String get systemTheme => _t('Системная', 'System');
  String get lightTheme => _t('Светлая', 'Light');
  String get darkTheme => _t('Тёмная', 'Dark');
  String get russian => _t('Русский', 'Russian');
  String get english => _t('Английский', 'English');

  String get splashSubtitle => _t(
        'Быстрый обзор расписания в стильном интерфейсе',
        'Fast schedule overview in a premium interface',
      );

  String get skip => _t('Пропустить', 'Skip');
  String get next => _t('Далее', 'Next');
  String get start => _t('Начать', 'Start');

  String get onboardingTitleOne => _t(
        'Организованный день',
        'Plan your day effortlessly',
      );
  String get onboardingDescriptionOne => _t(
        'Всё расписание в одном месте: занятия, встречи и события.',
        'All classes, meetings and events in one place.',
      );

  String get onboardingTitleTwo => _t(
        'Мгновенный доступ',
        'Instant access',
      );
  String get onboardingDescriptionTwo => _t(
        'Быстрая навигация по дням и неделям, поиск и фильтрация.',
        'Quick day/week navigation, search and filtering.',
      );

  String get onboardingTitleThree => _t(
        'Офлайн-устойчивость',
        'Offline resilience',
      );
  String get onboardingDescriptionThree => _t(
        'Последнее успешное расписание сохраняется локально.',
        'Last successful schedule is cached locally.',
      );

  String get teacher => _t('Преподаватель', 'Teacher');
  String get location => _t('Локация', 'Location');
  String get category => _t('Категория', 'Category');
  String get group => _t('Группа', 'Group');
  String get subgroup => _t('Подгруппа', 'Subgroup');
  String get allSubgroups => _t('Все подгруппы', 'All subgroups');
  String get date => _t('Дата', 'Date');
  String get status => _t('Статус', 'Status');
  String get description => _t('Описание', 'Description');
  String get startTime => _t('Начало', 'Start');
  String get endTime => _t('Конец', 'End');
  String get important => _t('Важно', 'Important');
  String get unknown => _t('Не указано', 'Not specified');

  String get sourceLink => _t('Ссылка на источник', 'Source link');
  String get editSourceLink => _t('Изменить ссылку', 'Edit source link');
  String get clearCache => _t('Очистить кэш', 'Clear cache');
  String get reloadSchedule => _t('Перезагрузить расписание', 'Reload schedule');
  String get aboutApp => _t('О приложении', 'About app');
  String get save => _t('Сохранить', 'Save');
  String get cancel => _t('Отмена', 'Cancel');
}

