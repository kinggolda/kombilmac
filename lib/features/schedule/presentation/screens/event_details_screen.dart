import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schedule_app/core/utils/date_utils.dart';
import 'package:schedule_app/features/schedule/domain/entities/lesson.dart';
import 'package:schedule_app/features/settings/presentation/providers/settings_providers.dart';
import 'package:schedule_app/shared/localization/app_strings.dart';
import 'package:schedule_app/shared/theme/design_tokens.dart';
import 'package:schedule_app/shared/widgets/premium_card.dart';

class EventDetailsScreen extends ConsumerWidget {
  const EventDetailsScreen({
    super.key,
    required this.lesson,
  });

  static const String routeName = 'eventDetails';
  static const String routePath = '/event/:id';

  static String locationForId(String id) => '/event/${Uri.encodeComponent(id)}';

  final Lesson lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final settings = ref.watch(settingsControllerProvider);

    final start = formatClockTime(
      lesson.startTime,
      use24HourFormat: settings.use24HourFormat,
      localeCode: settings.localeCode,
    );
    final end = formatClockTime(
      lesson.endTime,
      use24HourFormat: settings.use24HourFormat,
      localeCode: settings.localeCode,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.eventDetails),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.subject,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                _MetaRow(label: strings.group, value: lesson.group),
                if ((lesson.subgroup ?? '').trim().isNotEmpty)
                  _MetaRow(label: strings.subgroup, value: lesson.subgroup!),
                _MetaRow(label: strings.status, value: lesson.weekday),
                _MetaRow(label: strings.startTime, value: start),
                _MetaRow(label: strings.endTime, value: end),
                _MetaRow(label: strings.teacher, value: lesson.teacher ?? strings.unknown),
                _MetaRow(label: strings.location, value: lesson.room ?? strings.unknown),
                if ((lesson.rawCellValue ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    strings.rawCell,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(lesson.rawCellValue!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

