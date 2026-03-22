enum AppEnvironment { dev, prod }

class AppConfig {
  const AppConfig({
    required this.environment,
    required this.scheduleSourceUrl,
    required this.enableOnboarding,
    required this.useMockSpreadsheetFallback,
    required this.enableDebugLogs,
    required this.enableParserLogs,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.retries,
  });

  final AppEnvironment environment;
  final String scheduleSourceUrl;
  final bool enableOnboarding;
  final bool useMockSpreadsheetFallback;
  final bool enableDebugLogs;
  final bool enableParserLogs;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final int retries;

  String get spreadsheetSourceUrl => scheduleSourceUrl;

  factory AppConfig.dev() {
    return const AppConfig(
      environment: AppEnvironment.dev,
      scheduleSourceUrl: String.fromEnvironment(
        'SCHEDULE_SOURCE_URL',
        defaultValue:
            'https://docs.google.com/spreadsheets/d/PUT_SPREADSHEET_ID_HERE/edit#gid=0',
      ),
      enableOnboarding: bool.fromEnvironment(
        'ENABLE_ONBOARDING',
        defaultValue: true,
      ),
      useMockSpreadsheetFallback: bool.fromEnvironment(
        'USE_MOCK_SPREADSHEET_FALLBACK',
        defaultValue: true,
      ),
      enableDebugLogs: true,
      enableParserLogs: bool.fromEnvironment(
        'PARSER_DEBUG_LOGS',
        defaultValue: true,
      ),
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 15),
      retries: 2,
    );
  }

  factory AppConfig.prod() {
    return const AppConfig(
      environment: AppEnvironment.prod,
      scheduleSourceUrl: String.fromEnvironment(
        'SCHEDULE_SOURCE_URL',
        defaultValue:
            'https://docs.google.com/spreadsheets/d/PUT_SPREADSHEET_ID_HERE/edit#gid=0',
      ),
      enableOnboarding: bool.fromEnvironment(
        'ENABLE_ONBOARDING',
        defaultValue: false,
      ),
      useMockSpreadsheetFallback: bool.fromEnvironment(
        'USE_MOCK_SPREADSHEET_FALLBACK',
        defaultValue: false,
      ),
      enableDebugLogs: false,
      enableParserLogs: bool.fromEnvironment(
        'PARSER_DEBUG_LOGS',
        defaultValue: false,
      ),
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 15),
      retries: 1,
    );
  }

  bool get isDev => environment == AppEnvironment.dev;
}

