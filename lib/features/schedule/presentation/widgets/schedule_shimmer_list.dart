import 'package:flutter/material.dart';
import 'package:schedule_app/shared/theme/design_tokens.dart';
import 'package:schedule_app/shared/widgets/app_shimmer.dart';

class ScheduleShimmerList extends StatelessWidget {
  const ScheduleShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: 6,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.2),
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppShimmerBox(height: 14, width: 110),
              SizedBox(height: AppSpacing.sm),
              AppShimmerBox(height: 18),
              SizedBox(height: AppSpacing.xs),
              AppShimmerBox(height: 16, width: 180),
              SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(child: AppShimmerBox(height: 28)),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(child: AppShimmerBox(height: 28)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

