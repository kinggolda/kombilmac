# Schedule App (Flutter, Google Sheets/XLSX)

Production-ready мобильное приложение расписания для iOS/Android на Flutter.

Источник данных: **публичная Google Sheets таблица или прямой XLSX URL**.

## Реализовано

- Splash screen
- Onboarding (включаемый/отключаемый)
- Главный экран расписания
  - режимы: **Сегодня / Завтра / Неделя**
  - выбор группы и подгруппы
  - выбор дня (для режима недели)
  - поиск по предмету/преподавателю/аудитории/группе
- Детальная карточка занятия
- Loading / Success / Empty / Error / Offline Cached состояния
- Pull-to-refresh
- Skeleton loading (shimmer)
- Локальный кэш последнего успешного набора расписания (Hive)
- Mock spreadsheet fallback (без интернета)
- Settings screen:
  - тема
  - язык
  - формат времени
  - push-ready stub
  - редактирование source URL
  - ручная перезагрузка
  - очистка кэша

## Технологический стек

- Flutter (stable)
- Dart
- Clean Architecture + feature-first structure
- Riverpod (state/DI)
- Dio (download + retry + timeouts + debug logs)
- go_router
- Hive
- excel package (XLSX parser)
- Material 3, adaptive light/dark UI

## Архитектура

```text
lib/
  app/
    app.dart
    bootstrap.dart
    providers/
      app_config_provider.dart
    router/
      app_router.dart

  core/
    env/
      app_config.dart
    errors/
      app_exception.dart
    network/
      dio_client.dart
      interceptors/
        retry_interceptor.dart
    services/
      local_storage_service.dart
      settings_service.dart
    utils/
      date_utils.dart

  features/
    schedule/
      data/
        datasources/
          schedule_remote_data_source.dart
          schedule_local_data_source.dart
          schedule_mock_data_source.dart
        models/
          downloaded_schedule_file.dart
          spreadsheet_source_info.dart
        parsing/
          spreadsheet_workbook_reader.dart
          logger/
            spreadsheet_parser_logger.dart
          models/
            spreadsheet_matrix.dart
            parsed_spreadsheet_payload.dart
          rules/
            spreadsheet_parsing_rules.dart
          strategy/
            spreadsheet_parser_strategy.dart
            default_spreadsheet_parser_strategy.dart
        repositories/
          schedule_repository_impl.dart
        utils/
          spreadsheet_source_url_resolver.dart
      domain/
        entities/
          group.dart
          subgroup.dart
          lesson.dart
          schedule_day.dart
          schedule_source_meta.dart
          schedule_dataset.dart
        repositories/
          schedule_repository.dart
        usecases/
          download_schedule_file_usecase.dart
          parse_spreadsheet_usecase.dart
          extract_groups_usecase.dart
          build_schedule_for_group_usecase.dart
      presentation/
        providers/
          schedule_providers.dart
        state/
          schedule_state.dart
        screens/
          schedule_screen.dart
          event_details_screen.dart
        widgets/
          schedule_item_card.dart
          schedule_shimmer_list.dart

    splash/
      presentation/
        splash_screen.dart

    onboarding/
      presentation/
        onboarding_screen.dart

    settings/
      domain/entities/
        app_settings.dart
      presentation/
        providers/settings_providers.dart
        screens/settings_screen.dart

  shared/
    localization/
      app_strings.dart
    theme/
      app_theme.dart
      design_tokens.dart
    widgets/
      app_search_field.dart
      app_segmented_control.dart
      app_shimmer.dart
      app_state_views.dart
      premium_card.dart

assets/
  mocks/
    mock_spreadsheet_matrix.json
```

## Parser layer (обязательно реализованные use cases)

- `DownloadScheduleFileUseCase` — загрузка XLSX файла
- `ParseSpreadsheetUseCase` — запуск парсинга и сбор нормализованной модели
- `ExtractGroupsUseCase` — извлечение списка групп/подгрупп
- `BuildScheduleForGroupUseCase` — построение финального списка занятий для выбранной группы/подгруппы/дня/поиска

### Data flow

1. Source URL -> `SpreadsheetSourceUrlResolver`
2. Download bytes -> `ScheduleFileRemoteDataSource`
3. Decode workbook -> `SpreadsheetWorkbookReader`
4. Parse matrix -> `DefaultSpreadsheetParserStrategy`
5. Normalize to domain entities -> `ScheduleRepositoryImpl`
6. Cache normalized dataset -> `ScheduleCacheDataSource`
7. UI builds schedule from domain use cases

## Где указать реальную ссылку на источник

По умолчанию ссылка задаётся в `lib/core/env/app_config.dart` через `SCHEDULE_SOURCE_URL`.

### Вариант 1: запуск с dart-define

```bash
flutter run --dart-define=SCHEDULE_SOURCE_URL=https://docs.google.com/spreadsheets/d/<SPREADSHEET_ID>/edit#gid=0
```

### Вариант 2: сохранить ссылку внутри приложения

`Settings -> Изменить ссылку`

## Поддерживаемые source URL

- Google Sheets URL, например:
  - `https://docs.google.com/spreadsheets/d/<ID>/edit#gid=0`
- Прямой XLSX URL

Для Google Sheets приложение автоматически конвертирует ссылку в export URL:

`https://docs.google.com/spreadsheets/d/<ID>/export?format=xlsx&gid=<gid>`

## Environment flags

- `SCHEDULE_SOURCE_URL` — исходная ссылка на таблицу
- `USE_MOCK_SPREADSHEET_FALLBACK=true/false` — fallback на локальный mock matrix
- `ENABLE_ONBOARDING=true/false` — включить/выключить onboarding
- `PARSER_DEBUG_LOGS=true/false` — логирование parser layer

Пример:

```bash
flutter run --dart-define=SCHEDULE_SOURCE_URL=https://docs.google.com/spreadsheets/d/<ID>/edit#gid=0 --dart-define=USE_MOCK_SPREADSHEET_FALLBACK=true --dart-define=ENABLE_ONBOARDING=true --dart-define=PARSER_DEBUG_LOGS=true
```

## JSON examples

Ниже 2 примера JSON, которые используются/поддерживаются в проекте.

### 1) Mock spreadsheet matrix (`assets/mocks/mock_spreadsheet_matrix.json`)

```json
{
  "rows": [
    ["День", "Время", "№", "ИС-101", "", "ИС-102", ""],
    ["", "", "", "1", "2", "1", "2"],
    ["Понедельник", "08:30-10:00", "1", "Математика\nИванов А.А.\nауд. 402", "", "Физика\nПетров П.П.\nауд. 312", ""]
  ]
}
```

### 2) Нормализованный dataset cache (структура `ScheduleDataset.toJson()`)

```json
{
  "groups": [
    {
      "id": "ис101",
      "name": "ИС-101",
      "subgroups": [{ "id": "ис101_1", "name": "1" }]
    }
  ],
  "days": [
    {
      "weekday": "Понедельник",
      "lessons": [
        {
          "lessonIndex": 1,
          "weekday": "Понедельник",
          "startTime": "08:30",
          "endTime": "10:00",
          "subject": "Математика",
          "teacher": "Иванов А.А.",
          "room": "ауд. 402",
          "subgroup": "1",
          "group": "ИС-101",
          "rawCellValue": "Математика\nИванов А.А.\nауд. 402"
        }
      ]
    }
  ],
  "sourceMeta": {
    "sourceType": "googleSheets",
    "originalUrl": "https://docs.google.com/spreadsheets/d/<ID>/edit#gid=0",
    "downloadUrl": "https://docs.google.com/spreadsheets/d/<ID>/export?format=xlsx&gid=0",
    "lastUpdated": "2026-03-22T18:00:00.000Z",
    "isOfflineCached": false,
    "parserWarnings": []
  }
}
```

## Запуск локально

```bash
flutter pub get
flutter run
```

Для production-конфигурации:

```bash
flutter run -t lib/main_prod.dart --dart-define=SCHEDULE_SOURCE_URL=https://docs.google.com/spreadsheets/d/<ID>/edit#gid=0
```

## How to build APK locally

```bash
flutter pub get
flutter build apk --release --dart-define=SCHEDULE_SOURCE_URL=https://docs.google.com/spreadsheets/d/<ID>/edit#gid=0
```

APK:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Примечания

- При сетевых ошибках используется fallback: cached dataset -> mock spreadsheet (если включён).
- Retry/timeout стратегия настроена в Dio layer.
- HTTP logging и parser logging доступны в dev-конфигурации.

