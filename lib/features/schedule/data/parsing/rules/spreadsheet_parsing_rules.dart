class SpreadsheetParsingRules {
  const SpreadsheetParsingRules({
    required this.headerScanRows,
    required this.subgroupScanDepth,
    required this.weekdayAliases,
    required this.groupNamePattern,
    required this.subgroupPattern,
    required this.timeRangePattern,
    required this.teacherPattern,
    required this.roomPattern,
    required this.ignoredHeaderTokens,
  });

  final int headerScanRows;
  final int subgroupScanDepth;
  final Map<String, List<String>> weekdayAliases;
  final RegExp groupNamePattern;
  final RegExp subgroupPattern;
  final RegExp timeRangePattern;
  final RegExp teacherPattern;
  final RegExp roomPattern;
  final Set<String> ignoredHeaderTokens;

  factory SpreadsheetParsingRules.defaults() {
    return SpreadsheetParsingRules(
      headerScanRows: 18,
      subgroupScanDepth: 5,
      weekdayAliases: const {
        'Понедельник': ['понедельник', 'пн', 'monday', 'mon'],
        'Вторник': ['вторник', 'вт', 'tuesday', 'tue'],
        'Среда': ['среда', 'ср', 'wednesday', 'wed'],
        'Четверг': ['четверг', 'чт', 'thursday', 'thu'],
        'Пятница': ['пятница', 'пт', 'friday', 'fri'],
        'Суббота': ['суббота', 'сб', 'saturday', 'sat'],
        'Воскресенье': ['воскресенье', 'вс', 'sunday', 'sun'],
      },
      groupNamePattern: RegExp(
        r'([A-Za-zА-Яа-я]{1,8}[\-/ ]?\d{1,4}|\d{1,2}[A-Za-zА-Яа-я]{1,6}|группа\s*\d+)',
        caseSensitive: false,
      ),
      subgroupPattern: RegExp(
        r'^(?:подгрупп[аы]?\s*)?(?:1|2|3|4|I|II|III|IV|A|B)$',
        caseSensitive: false,
      ),
      timeRangePattern: RegExp(
        r'(\d{1,2}[:.]\d{2})\s*[-–—]\s*(\d{1,2}[:.]\d{2})',
      ),
      teacherPattern: RegExp(
        r'([А-ЯA-Z][а-яa-z]+\s+[А-ЯA-Z]\.?[А-ЯA-Z]?\.?|[А-ЯA-Z][а-яa-z]+\s+[А-ЯA-Z][а-яa-z]+)',
      ),
      roomPattern: RegExp(
        r'(?:ауд\.?|каб\.?|room|корп\.?|зал)\s*\w*',
        caseSensitive: false,
      ),
      ignoredHeaderTokens: const {
        'день',
        'дни',
        'weekday',
        'time',
        'время',
        'пара',
        '№',
        'номер',
        'lesson',
      },
    );
  }

  String? normalizeWeekday(String value) {
    final normalized = value.toLowerCase().trim();
    if (normalized.isEmpty) {
      return null;
    }

    for (final entry in weekdayAliases.entries) {
      for (final alias in entry.value) {
        if (normalized.contains(alias)) {
          return entry.key;
        }
      }
    }
    return null;
  }

  bool isWeekday(String value) => normalizeWeekday(value) != null;
}

