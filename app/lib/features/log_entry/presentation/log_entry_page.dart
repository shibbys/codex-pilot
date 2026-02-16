import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/local/app_database.dart';
import '../../dashboard/presentation/dashboard_page.dart';

class LogEntryPage extends ConsumerStatefulWidget {
  const LogEntryPage({super.key});

  static const String routePath = '/log';
  static const String routeName = 'log-entry';

  @override
  ConsumerState<LogEntryPage> createState() => _LogEntryPageState();
}

class _LogEntryPageState extends ConsumerState<LogEntryPage> {
  final TextEditingController _weightCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  final Set<String> _selectedTags = {};

  // Tags pré-definidas
  static const _quickTags = [
    '💪 Treino',
    '🍕 Cheat day',
    '😴 Pouco sono',
    '💧 Muita água',
    '🏃 Cardio',
    '🥗 Dieta',
    '🍺 Bebida',
    '😌 Bem-estar',
  ];

  @override
  void dispose() {
    _weightCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  String _buildNote() {
    final customNote = _noteCtrl.text.trim();
    final tags = _selectedTags.join(' • ');
    
    if (tags.isEmpty) return customNote;
    if (customNote.isEmpty) return tags;
    return '$tags\n$customNote';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Weight')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StreamBuilder(
              stream: ref.read(appDatabaseProvider).watchLatestEntry(),
              builder: (context, snapshot) {
                String hint = 'e.g., 72.5';
                if (snapshot.hasData && snapshot.data != null) {
                  try {
                    final w = (snapshot.data as WeightEntry).weightKg;
                    hint = w.toStringAsFixed(1);
                  } catch (_) {}
                }
                return TextField(
                  controller: _weightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  onTap: () => _weightCtrl.selection = TextSelection(baseOffset: 0, extentOffset: _weightCtrl.text.length),
                  inputFormatters: [
                    DecimalTextInputFormatter(decimals: 2),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Weight (kg)',
                    hintText: hint,
                    border: const OutlineInputBorder(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Text('${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Pick'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quick Tags Section
            Text(
              'Quick Tags',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (_) => _toggleTag(tag),
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  checkmarkColor: Theme.of(context).colorScheme.primary,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _noteCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Additional Note (optional)',
                hintText: 'Any other details...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  HapticFeedback.selectionClick();
                  final messenger = ScaffoldMessenger.of(context);
                  final router = GoRouter.of(context);
                  final raw = _weightCtrl.text.trim().replaceAll(',', '.');
                  final weight = double.tryParse(raw);
                  if (weight == null) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Enter a valid weight (e.g., 72.5)')),
                    );
                    return;
                  }

                  final finalNote = _buildNote();

                  final db = ref.read(appDatabaseProvider);
                  await db.addWeightEntry(
                    date: _date,
                    weightKg: weight,
                    note: finalNote.isEmpty ? null : finalNote,
                  );

                  messenger.showSnackBar(
                    const SnackBar(content: Text('Weight saved')),
                  );
                  router.go(DashboardPage.routePath);
                },
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimals = 2});
  final int decimals;
  final _allowed = RegExp(r'^[0-9]*[\.,]?[0-9]*');
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(',', '.');
    final match = _allowed.stringMatch(text) ?? '';
    final parts = match.split('.');
    String result = match;
    if (parts.length > 2) {
      result = oldValue.text; // reject second separator
    } else if (parts.length == 2 && parts[1].length > decimals) {
      result = '${parts[0]}.${parts[1].substring(0, decimals)}';
    }
    return TextEditingValue(text: result, selection: TextSelection.collapsed(offset: result.length));
  }
}
