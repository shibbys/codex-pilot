import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/i18n/translations.dart';
import '../../log_entry/services/reminder_service.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  static const String routePath = '/settings';
  static const String routeName = 'settings';

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final saved = await ref.read(reminderServiceProvider).loadSavedReminderTime();
      if (saved != null && mounted) {
        setState(() => _time = TimeOfDay(hour: saved.hour, minute: saved.minute));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeSettingsAsync = ref.watch(themeControllerProvider);
    final localeAsync = ref.watch(i18nControllerProvider);

    const int currentIndex = 2;

    return Scaffold(
      appBar: AppBar(title: Text(tr(ref, 'settingsTitle'))),
      body: themeSettingsAsync.when(
        data: (themeSettings) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text(tr(ref, 'appearance'), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                segments: const <ButtonSegment<ThemeMode>>[
                  ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode)),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode)),
                  ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.auto_mode)),
                ],
                selected: <ThemeMode>{themeSettings.mode},
                onSelectionChanged: (selection) {
                  if (selection.isEmpty) return;
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
              const SizedBox(height: 24),
              Text('Language', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.language),
                  const SizedBox(width: 12),
                  DropdownButton<Locale>(
                    value: localeAsync.valueOrNull ?? const Locale('en'),
                    items: const [
                      DropdownMenuItem(value: Locale('en'), child: Text('English')),
                      DropdownMenuItem(value: Locale('pt'), child: Text('Português')),
                    ],
                    onChanged: (loc) {
                      if (loc != null) {
                        ref.read(i18nControllerProvider.notifier).setLocale(loc);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Reminders', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(Icons.schedule),
                    title: const Text('Daily reminder time'),
                    subtitle: Text(_time.format(context)),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _time,
                      );
                      if (picked != null) {
                        setState(() => _time = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final t = _time;
                          await ref.read(reminderServiceProvider).scheduleDailyReminder(
                                id: 100,
                                hour: t.hour,
                                minute: t.minute,
                              );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${tr(ref, 'scheduledAt')} ${t.format(context)}')),
                              );
                          }
                        },
                        icon: const Icon(Icons.alarm_add),
                        label: const Text('Schedule'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await ref.read(reminderServiceProvider).cancelReminder(100);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Reminder canceled')),
                            );
                          }
                        },
                        icon: const Icon(Icons.alarm_off),
                        label: const Text('Cancel'),
                      ),
                    ],
                  )
                ],
              ),
              const Divider(),
              Text(tr(ref, 'dataManagement'), style: Theme.of(context).textTheme.titleLarge),
              ListTile(
                leading: const Icon(Icons.table_view),
                title: Text(tr(ref, 'exportCsv')),
                subtitle: Text(tr(ref, 'exportCsvSubtitle')),
              ),
              ListTile(
                leading: const Icon(Icons.cloud_upload),
                title: Text(tr(ref, 'googleDriveSync')),
                subtitle: Text(tr(ref, 'googleDriveSyncSubtitle')),
              ),
              const SizedBox(height: 24),
              Text(tr(ref, 'goal'), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              _GoalEditor(),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Failed to load settings: $error')),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/dashboard');
              break;
            case 1:
              context.go('/history');
              break;
            case 2:
              context.go('/settings');
              break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class _GoalEditor extends ConsumerStatefulWidget {
  @override
  State<_GoalEditor> createState() => _GoalEditorState();
}

class _GoalEditorState extends ConsumerState<_GoalEditor> {
  final TextEditingController _targetCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();
  DateTime? _targetDate;

  @override
  void dispose() {
    _targetCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _targetCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: tr(ref, 'targetWeight'),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: tr(ref, 'targetDate'),
                  border: const OutlineInputBorder(),
                ),
                child: Text(_targetDate == null
                    ? '--'
                    : '${_targetDate!.year}-${_targetDate!.month.toString().padLeft(2, '0')}-${_targetDate!.day.toString().padLeft(2, '0')}'),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                setState(() => _targetDate = picked);
              },
              child: Text(tr(ref, 'pick')),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _noteCtrl,
          decoration: InputDecoration(
            labelText: tr(ref, 'note'),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final raw = _targetCtrl.text.trim().replaceAll(',', '.');
              final target = double.tryParse(raw);
              if (target == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(tr(ref, 'enterValidWeight'))),
                );
                return;
              }
              // Persist goal (keeps previous goals for history)
              final db = ref.read(appDatabaseProvider);
              await db.addGoal(
                targetWeightKg: target,
                targetDate: _targetDate,
                note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
              );
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(tr(ref, 'goal') + ' ' + tr(ref, 'save'))),
              );
            },
            icon: const Icon(Icons.flag),
            label: Text(tr(ref, 'setNewGoal')),
          ),
        ),
      ],
    );
  }
}
