import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  static const String routePath = '/settings';
  static const String routeName = 'settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettingsAsync = ref.watch(themeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: themeSettingsAsync.when(
        data: (themeSettings) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                segments: const <ButtonSegment<ThemeMode>>[
                  ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode)),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode)),
                  ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.auto_mode)),
                ],
                selected: <ThemeMode>{themeSettings.mode},
                onSelectionChanged: (selection) {
                  if (selection.isEmpty) {
                    return;
                  }
                  ref.read(themeControllerProvider.notifier).updateThemeMode(selection.first);
                },
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kPresetAccentColors
                    .map(
                      (color) => GestureDetector(
                        onTap: () => ref.read(themeControllerProvider.notifier).updateSeedColor(color),
                        child: CircleAvatar(
                          radius: themeSettings.seedColor == color ? 28 : 24,
                          backgroundColor: color,
                          child: themeSettings.seedColor == color
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 32),
              Text('Reminders', style: Theme.of(context).textTheme.titleLarge),
              const ListTile(
                leading: Icon(Icons.alarm),
                title: Text('Configure daily reminder'),
                subtitle: Text('Scheduling UI coming soon.'),
              ),
              const Divider(),
              Text('Data Management', style: Theme.of(context).textTheme.titleLarge),
              const ListTile(
                leading: Icon(Icons.table_view),
                title: Text('Export CSV'),
                subtitle: Text('Exports all weight entries to a CSV file.'),
              ),
              const ListTile(
                leading: Icon(Icons.cloud_upload),
                title: Text('Google Drive Sync'),
                subtitle: Text('Connect your Drive account to sync entries.'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Failed to load settings: $error')),
      ),
    );
  }
}
