import 'package:schedule_app/features/schedule/domain/entities/schedule_dataset.dart';
import 'package:schedule_app/features/schedule/domain/repositories/schedule_repository.dart';

class ParseSpreadsheetUseCase {
  const ParseSpreadsheetUseCase(this._repository);

  final ScheduleRepository _repository;

  Future<ScheduleDataset> call({
    required String sourceUrl,
    bool forceRefresh = false,
  }) {
    return _repository.loadAndParseSchedule(
      sourceUrl: sourceUrl,
      forceRefresh: forceRefresh,
    );
  }
}

