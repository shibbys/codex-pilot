import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/user_height_service.dart';

import '../../../core/theme/theme_controller.dart';
import '../../../core/i18n/translations.dart';
import '../../../data/local/app_database.dart';
import '../../../data/sync/csv_service.dart';
import 'package:share_plus/share_plus.dart';
import 'widgets/reminder_section.dart';
import 'widgets/theme_presets_section.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  static const String routePath = '/settings';
  static const String routeName = 'settings';

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
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
              //Seleção dos temas pré-definidos
              const ThemePresetsSection(),
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
              const SizedBox(height: 24),
              Text('Altura / Height', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              _HeightConfig(),
              const SizedBox(height: 24),
              const ReminderSection(),
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

class _HeightConfig extends ConsumerStatefulWidget {
  const _HeightConfig();

  @override
  ConsumerState<_HeightConfig> createState() => _HeightConfigState();
}

class _HeightConfigState extends ConsumerState<_HeightConfig> {
  final TextEditingController _heightCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHeight();
  }

  Future<void> _loadHeight() async {
    final height = await ref.read(userHeightServiceProvider).getHeight();
    if (height != null && mounted) {
      _heightCtrl.text = height.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _heightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _heightCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Altura (cm)',
              hintText: 'ex: 175',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.straighten),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () async {
            final value = double.tryParse(_heightCtrl.text);
            if (value != null && value > 0 && value < 300) {
              await ref.read(userHeightServiceProvider).setHeight(value);
              ref.invalidate(userHeightProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Altura salva!')),
                );
              }
            } else if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Altura inválida')),
              );
            }
          },
          icon: const Icon(Icons.save),
          label: const Text('Salvar'),
        ),
      ],
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
