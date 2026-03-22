import 'package:schedule_app/features/schedule/domain/entities/lesson.dart';

class ParsedSpreadsheetPayload {
  const ParsedSpreadsheetPayload({
    required this.lessons,
    required this.subgroupsByGroup,
    required this.warnings,
  });

  final List<Lesson> lessons;
  final Map<String, Set<String>> subgroupsByGroup;
  final List<String> warnings;
}

