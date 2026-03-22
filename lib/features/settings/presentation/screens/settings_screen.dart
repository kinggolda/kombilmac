import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schedule_app/features/schedule/presentation/providers/schedule_providers.dart';
import 'package:schedule_app/features/settings/domain/entities/app_settings.dart';
import 'package:schedule_app/features/settings/presentation/providers/settings_providers.dart';
import 'package:schedule_app/shared/localization/app_strings.dart';
import 'package:schedule_app/shared/theme/design_tokens.dart';
import 'package:schedule_app/shared/widgets/app_segmented_control.dart';
import 'package:schedule_app/shared/widgets/premium_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const String routeName = 'settings';
  static const String routePath = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final settingsController = ref.read(settingsControllerProvider.notifier);
    final scheduleState = ref.watch(scheduleControllerProvider);
    final scheduleController = ref.read(scheduleControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.theme,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                AppSegmentedControl<AppThemePreference>(
                  selected: {settings.themePreference},
                  onSelectionChanged: (selected) {
                    settingsController.setThemePreference(selected.first);
                  },
                  segments: [
                    ButtonSegment<AppThemePreference>(
                      value: AppThemePreference.system,
                      label: Text(strings.systemTheme),
                    ),
                    ButtonSegment<AppThemePreference>(
                      value: AppThemePreference.light,
                      label: Text(strings.lightTheme),
                    ),
                    ButtonSegment<AppThemePreference>(
                      value: AppThemePreference.dark,
                      label: Text(strings.darkTheme),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.language,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                AppSegmentedControl<String>(
                  selected: {settings.localeCode},
                  onSelectionChanged: (selected) {
                    settingsController.setLocaleCode(selected.first);
                  },
                  segments: [
                    ButtonSegment<String>(
                      value: 'ru',
                      label: Text(strings.russian),
                    ),
                    ButtonSegment<String>(
                      value: 'en',
                      label: Text(strings.english),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PremiumCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  title: Text(strings.use24HourFormat),
                  value: settings.use24HourFormat,
                  onChanged: settingsController.set24HourFormat,
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  title: Text(strings.pushReadyStructure),
                  value: settings.pushStubEnabled,
                  onChanged: settingsController.setPushStubEnabled,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PremiumCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.link_rounded),
                  title: Text(strings.editSourceLink),
                  subtitle: Text(
                    scheduleState.sourceUrl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _showSourceEditDialog(
                    context: context,
                    strings: strings,
                    initialValue: scheduleState.sourceUrl,
                    onSave: (value) => scheduleController.updateSourceUrl(
                      value,
                      reload: true,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.refresh_rounded),
                  title: Text(strings.reloadSchedule),
                  onTap: scheduleController.reloadSchedule,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded),
                  title: Text(strings.clearCache),
                  onTap: () async {
                    await scheduleController.clearCache();
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(strings.cacheClearedMessage)),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: Text(strings.aboutApp),
                  subtitle: const Text('Schedule App · Flutter'),
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'Schedule App',
                    applicationVersion: '1.0.0',
                    children: const [
                      Text(
                        'Приложение для просмотра расписания из Google Sheets/XLSX с офлайн-кэшем и robust parser layer.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PremiumCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.restart_alt_rounded),
              title: Text(strings.resetOnboarding),
              onTap: settingsController.resetOnboarding,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSourceEditDialog({
    required BuildContext context,
    required AppStrings strings,
    required String initialValue,
    required Future<void> Function(String value) onSave,
  }) async {
    final controller = TextEditingController(text: initialValue);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(strings.editSourceLink),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: strings.sourceLink,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () async {
                final value = controller.text.trim();
                if (value.isEmpty) {
                  return;
                }
                await onSave(value);
                if (!dialogContext.mounted) {
                  return;
                }
                Navigator.of(dialogContext).pop();
              },
              child: Text(strings.save),
            ),
          ],
        );
      },
    );
  }
}

