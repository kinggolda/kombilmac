import 'package:flutter/material.dart';
import 'package:schedule_app/core/utils/date_utils.dart';
import 'package:schedule_app/features/schedule/domain/entities/lesson.dart';
import 'package:schedule_app/shared/theme/design_tokens.dart';
import 'package:schedule_app/shared/widgets/premium_card.dart';

class ScheduleLessonCard extends StatelessWidget {
  const ScheduleLessonCard({
    super.key,
    required this.lesson,
    required this.localeCode,
    required this.use24HourFormat,
    this.onTap,
  });

  final Lesson lesson;
  final String localeCode;
  final bool use24HourFormat;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final start = formatClockTime(
      lesson.startTime,
      use24HourFormat: use24HourFormat,
      localeCode: localeCode,
    );
    final end = formatClockTime(
      lesson.endTime,
      use24HourFormat: use24HourFormat,
      localeCode: localeCode,
    );

    return Semantics(
      button: onTap != null,
      label: '${lesson.subject}, ${lesson.weekday}, $start - $end',
      child: PremiumCard(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Text(
                lesson.lessonIndex.toString(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$start - $end',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson.subject,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if ((lesson.teacher ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      lesson.teacher!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  if ((lesson.room ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      lesson.room!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if ((lesson.subgroup ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        child: Text(
                          lesson.subgroup!,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

