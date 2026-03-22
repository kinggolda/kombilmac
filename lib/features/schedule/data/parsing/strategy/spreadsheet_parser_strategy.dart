import 'package:schedule_app/features/schedule/data/parsing/models/parsed_spreadsheet_payload.dart';
import 'package:schedule_app/features/schedule/data/parsing/models/spreadsheet_matrix.dart';
import 'package:schedule_app/features/schedule/data/parsing/rules/spreadsheet_parsing_rules.dart';

abstract class SpreadsheetParserStrategy {
  ParsedSpreadsheetPayload parse({
    required SpreadsheetMatrix matrix,
    required SpreadsheetParsingRules rules,
  });
}

