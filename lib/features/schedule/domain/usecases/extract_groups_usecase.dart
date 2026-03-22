import 'package:schedule_app/features/schedule/domain/entities/group.dart';
import 'package:schedule_app/features/schedule/domain/entities/schedule_dataset.dart';

class ExtractGroupsUseCase {
  const ExtractGroupsUseCase();

  List<Group> call(ScheduleDataset dataset) {
    final groups = dataset.groups.toList(growable: false)
      ..sort((a, b) => a.name.compareTo(b.name));
    return groups;
  }
}

