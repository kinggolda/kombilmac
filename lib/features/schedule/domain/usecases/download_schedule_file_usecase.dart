import 'package:schedule_app/features/schedule/domain/repositories/schedule_repository.dart';

class DownloadScheduleFileUseCase {
  const DownloadScheduleFileUseCase(this._repository);

  final ScheduleRepository _repository;

  Future<void> call({
    required String sourceUrl,
  }) {
    return _repository.downloadScheduleFile(sourceUrl: sourceUrl);
  }
}

