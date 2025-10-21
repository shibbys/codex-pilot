import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/i18n/translations.dart';
import '../../log_entry/services/reminder_service.dart';
import '../../../data/local/app_database.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../data/sync/csv_service.dart';
import 'package:share_plus/share_plus.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  static const String routePath = '/settings';
  static const String routeName = 'settings';

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  bool _reminderSet = false;
  Future<void> _refreshReminderStatus() async {
    final svc = ref.read(reminderServiceProvider);
    final scheduled = await svc.isReminderScheduled(100);
    if (mounted) setState(() => _reminderSet = scheduled);
  }

  Future<String?> _askFirstName(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Export CSV'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'First name for file name',
              hintText: 'e.g., Marlon',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.of(ctx).pop(controller.text.trim()), child: const Text('Export')),
          ],
        );
      },
    );
    return result == null || result.isEmpty ? null : result;
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final saved = await ref.read(reminderServiceProvider).loadSavedReminderTime();
      if (saved != null && mounted) {
        setState(() => _time = TimeOfDay(hour: saved.hour, minute: saved.minute));
      }
      if (mounted) {
        setState(() => _reminderSet = saved != null);
      }
      await _refreshReminderStatus();
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
                segments: <ButtonSegment<ThemeMode>>[
                  ButtonSegment(value: ThemeMode.light, label: Text(tr(ref, 'light')), icon: const Icon(Icons.light_mode)),
                  ButtonSegment(value: ThemeMode.dark, label: Text(tr(ref, 'dark')), icon: const Icon(Icons.dark_mode)),
                  ButtonSegment(value: ThemeMode.system, label: Text(tr(ref, 'system')), icon: const Icon(Icons.auto_mode)),
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
                    .toList()
                  ..add(
                    GestureDetector(
                      onTap: () async {
                        final current = ref.read(themeControllerProvider).valueOrNull?.seedColor ?? kPresetAccentColors.first;
                        Color temp = current;
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) {
                            return AlertDialog(
                              title: Text(tr(ref, 'customColor')),
                              content: SingleChildScrollView(
                                child: BlockPicker(
                                  pickerColor: temp,
                                  onColorChanged: (c) => temp = c,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: Text(tr(ref, 'cancel')),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ref.read(themeControllerProvider.notifier).updateSeedColor(kPresetAccentColors.first);
                                    Navigator.of(ctx).pop(false);
                                  },
                                  child: Text(tr(ref, 'reset')),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: Text(tr(ref, 'done')),
                                ),
                              ],
                            );
                          },
                        );
                        if (ok == true) {
                          await ref.read(themeControllerProvider.notifier).updateSeedColor(temp);
                        }
                      },
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                        child: const Icon(Icons.color_lens, color: Colors.white),
                      ),
                    ),
                  ),
              ),
              const SizedBox(height: 24),
              Text(tr(ref, 'language'), style: Theme.of(context).textTheme.titleLarge),
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
              Text(tr(ref, 'remindersTitle'), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(Icons.schedule),
                    title: Text(tr(ref, 'dailyReminderTime')),
                    subtitle: Text(_time.format(context)),
                    trailing: Icon(
                      _reminderSet ? Icons.check_circle : Icons.cancel,
                      color: _reminderSet ? Colors.green : Colors.grey,
                    ),
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
                          await _refreshReminderStatus();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${tr(ref, 'scheduledAt')} ${t.format(context)}')),
                              );
                          }
                        },
                        icon: const Icon(Icons.alarm_add),
                        label: Text(tr(ref, 'schedule')),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await ref.read(reminderServiceProvider).cancelReminder(100);
                          await _refreshReminderStatus();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Reminder canceled')),
                            );
                          }
                        },
                        icon: const Icon(Icons.alarm_off),
                        label: Text(tr(ref, 'cancel')),
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
                onTap: () async {
                  final name = await _askFirstName(context) ?? 'User';
                  final file = await ref.read(csvServiceProvider).exportEntries(userFirstName: name);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Exported to ${file.path}')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: Text(tr(ref, 'shareCsv')),
                subtitle: Text(tr(ref, 'shareCsvSubtitle')),
                onTap: () async {
                  final name = await _askFirstName(context) ?? 'User';
                  final file = await ref.read(csvServiceProvider).exportEntries(userFirstName: name);
                  await Share.shareXFiles([XFile(file.path)], text: 'Daily Weight Tracker data');
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_open),
                title: Text(tr(ref, 'importCsv')),
                subtitle: Text(tr(ref, 'importCsvSubtitle')),
                onTap: () async {
                  final choice = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete all logs before import?'),
                      content: const Text('You can clear all existing entries before importing the CSV.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('No')),
                        ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Yes')),
                      ],
                    ),
                  );
                  if (choice == true) {
                    await ref.read(appDatabaseProvider).clearAllEntries();
                  }
                  final count = await ref.read(csvServiceProvider).pickAndImport();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Imported $count entr${count == 1 ? 'y' : 'ies'}')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                title: Text(tr(ref, 'clearAllLogs')),
                subtitle: Text(tr(ref, 'clearAllLogsSubtitle')),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(tr(ref, 'clearAllLogs')),
                      content: Text(tr(ref, 'clearAllLogsSubtitle')),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                        ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref.read(appDatabaseProvider).clearAllEntries();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All logs cleared')),
                    );
                  }
                },
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
        destinations: [
          NavigationDestination(icon: const Icon(Icons.dashboard_outlined), selectedIcon: const Icon(Icons.dashboard), label: tr(ref, 'home')),
          NavigationDestination(icon: const Icon(Icons.history_outlined), selectedIcon: const Icon(Icons.history), label: tr(ref, 'history')),
          NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings), label: tr(ref, 'settings')),
        ],
      ),
    );
  }
}

class _GoalEditor extends ConsumerStatefulWidget {
  @override
  ConsumerState<_GoalEditor> createState() => _GoalEditorState();
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
              final messenger = ScaffoldMessenger.of(context);
              final raw = _targetCtrl.text.trim().replaceAll(',', '.');
              final target = double.tryParse(raw);
              if (target == null) {
                messenger.showSnackBar(
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
              messenger.showSnackBar(
                SnackBar(content: Text('${tr(ref, 'goal')} ${tr(ref, 'save')}')),
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
