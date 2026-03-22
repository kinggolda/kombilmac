import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:schedule_app/features/schedule/domain/entities/schedule_source_meta.dart';
import 'package:schedule_app/features/schedule/presentation/providers/schedule_providers.dart';
import 'package:schedule_app/features/schedule/presentation/screens/event_details_screen.dart';
import 'package:schedule_app/features/schedule/presentation/state/schedule_state.dart';
import 'package:schedule_app/features/schedule/presentation/widgets/schedule_item_card.dart';
import 'package:schedule_app/features/schedule/presentation/widgets/schedule_shimmer_list.dart';
import 'package:schedule_app/features/settings/presentation/providers/settings_providers.dart';
import 'package:schedule_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:schedule_app/shared/localization/app_strings.dart';
import 'package:schedule_app/shared/theme/design_tokens.dart';
import 'package:schedule_app/shared/widgets/app_search_field.dart';
import 'package:schedule_app/shared/widgets/app_segmented_control.dart';
import 'package:schedule_app/shared/widgets/app_state_views.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  static const String routeName = 'schedule';
  static const String routePath = '/schedule';

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  static const String _allSubgroupsValue = '__all_subgroups';

  late final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final scheduleState = ref.watch(scheduleControllerProvider);
    final scheduleController = ref.read(scheduleControllerProvider.notifier);
    final settings = ref.watch(settingsControllerProvider);

    if (_searchController.text != scheduleState.searchQuery) {
      _searchController.value = _searchController.value.copyWith(
        text: scheduleState.searchQuery,
        selection: TextSelection.collapsed(
          offset: scheduleState.searchQuery.length,
        ),
        composing: TextRange.empty,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.scheduleTitle),
        actions: [
          IconButton(
            onPressed: () => context.push(SettingsScreen.routePath),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _ControlsSection(
              state: scheduleState,
              searchController: _searchController,
              onSearchChanged: scheduleController.setSearchQuery,
              onSearchClear: () {
                _searchController.clear();
                scheduleController.setSearchQuery('');
              },
              onGroupChanged: scheduleController.selectGroup,
              onSubgroupChanged: scheduleController.selectSubgroup,
              onViewModeChanged: scheduleController.setViewMode,
              onWeekdayChanged: scheduleController.selectWeekday,
              onRecentGroupSelected: scheduleController.selectGroup,
            ),
            Expanded(
              child: RefreshIndicator.adaptive(
                onRefresh: scheduleController.reloadSchedule,
                child: _buildContent(
                  context: context,
                  strings: strings,
                  state: scheduleState,
                  use24HourFormat: settings.use24HourFormat,
                  localeCode: settings.localeCode,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required AppStrings strings,
    required ScheduleState state,
    required bool use24HourFormat,
    required String localeCode,
  }) {
    if (state.status == ScheduleLoadStatus.loading ||
        state.status == ScheduleLoadStatus.initial) {
      return const ScheduleShimmerList();
    }

    if (state.status == ScheduleLoadStatus.error) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          AppErrorState(
            title: strings.errorTitle,
            message: state.errorMessage,
            retryLabel: strings.retry,
            onRetry: () => ref.read(scheduleControllerProvider.notifier).reloadSchedule(),
          ),
        ],
      );
    }

    if (state.status == ScheduleLoadStatus.empty && state.visibleLessons.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          AppEmptyState(
            title: strings.noDataTitle,
            description: strings.noDataDescription,
          ),
        ],
      );
    }

    if (state.visibleLessons.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          AppEmptyState(
            title: strings.noResultsTitle,
            description: strings.noResultsDescription,
          ),
        ],
      );
    }

    final children = <Widget>[];

    if (state.isOfflineCached || state.status == ScheduleLoadStatus.offlineCached) {
      final sourceType = state.dataset?.sourceMeta.sourceType;
      final bannerText = sourceType == ScheduleSourceType.mockAsset
          ? strings.fromMockBanner
          : strings.fromCacheBanner;

      children.add(AppInfoBanner(text: bannerText));
      children.add(const SizedBox(height: AppSpacing.sm));
    }

    if (state.parserWarnings.isNotEmpty) {
      children.add(
        AppInfoBanner(
          text: state.parserWarnings.first,
          icon: Icons.warning_amber_rounded,
        ),
      );
      children.add(const SizedBox(height: AppSpacing.sm));
    }

    if (state.lastUpdated != null) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text(
            '${strings.updatedAtLabel}: ${DateFormat('dd.MM.yyyy HH:mm', localeCode).format(state.lastUpdated!)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }

    for (final lesson in state.visibleLessons) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ScheduleLessonCard(
            lesson: lesson,
            localeCode: localeCode,
            use24HourFormat: use24HourFormat,
            onTap: () {
              context.push(
                EventDetailsScreen.locationForId(lesson.id),
                extra: lesson,
              );
            },
          ),
        ),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      children: children,
    );
  }
}

class _ControlsSection extends StatelessWidget {
  const _ControlsSection({
    required this.state,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSearchClear,
    required this.onGroupChanged,
    required this.onSubgroupChanged,
    required this.onViewModeChanged,
    required this.onWeekdayChanged,
    required this.onRecentGroupSelected,
  });

  final ScheduleState state;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClear;
  final ValueChanged<String> onGroupChanged;
  final ValueChanged<String?> onSubgroupChanged;
  final ValueChanged<ScheduleViewMode> onViewModeChanged;
  final ValueChanged<String> onWeekdayChanged;
  final ValueChanged<String> onRecentGroupSelected;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final subgroups = state.availableSubgroups;
    final selectedSubgroupValue = state.selectedSubgroupName ??
        (subgroups.isEmpty ? null : _ScheduleScreenState._allSubgroupsValue);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.recentGroups.isNotEmpty) ...[
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final groupName in state.recentGroups)
                  ActionChip(
                    label: Text(groupName),
                    onPressed: () => onRecentGroupSelected(groupName),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (state.groups.isNotEmpty)
            DropdownButtonFormField<String>(
              value: state.selectedGroupName,
              decoration: InputDecoration(labelText: strings.group),
              isExpanded: true,
              items: state.groups
                  .map(
                    (group) => DropdownMenuItem<String>(
                      value: group.name,
                      child: Text(group.name),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) {
                  onGroupChanged(value);
                }
              },
            ),
          if (subgroups.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              value: selectedSubgroupValue,
              decoration: InputDecoration(labelText: strings.subgroup),
              isExpanded: true,
              items: [
                DropdownMenuItem<String>(
                  value: _ScheduleScreenState._allSubgroupsValue,
                  child: Text(strings.allSubgroups),
                ),
                ...subgroups.map(
                  (subgroup) => DropdownMenuItem<String>(
                    value: subgroup,
                    child: Text(subgroup),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value == null ||
                    value == _ScheduleScreenState._allSubgroupsValue) {
                  onSubgroupChanged(null);
                  return;
                }
                onSubgroupChanged(value);
              },
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          AppSegmentedControl<ScheduleViewMode>(
            selected: {state.viewMode},
            onSelectionChanged: (selected) {
              onViewModeChanged(selected.first);
            },
            segments: [
              ButtonSegment<ScheduleViewMode>(
                value: ScheduleViewMode.today,
                label: Text(strings.today),
              ),
              ButtonSegment<ScheduleViewMode>(
                value: ScheduleViewMode.tomorrow,
                label: Text(strings.tomorrow),
              ),
              ButtonSegment<ScheduleViewMode>(
                value: ScheduleViewMode.week,
                label: Text(strings.week),
              ),
            ],
          ),
          if (state.viewMode == ScheduleViewMode.week && state.weekdays.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: state.weekdays.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: AppSpacing.xs),
                itemBuilder: (context, index) {
                  final weekday = state.weekdays[index];
                  final selected = weekday == state.selectedWeekday;

                  return ChoiceChip(
                    label: Text(weekday),
                    selected: selected,
                    onSelected: (_) => onWeekdayChanged(weekday),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          AppSearchField(
            hintText: strings.searchHint,
            controller: searchController,
            onChanged: onSearchChanged,
            onClear: onSearchClear,
          ),
        ],
      ),
    );
  }
}

