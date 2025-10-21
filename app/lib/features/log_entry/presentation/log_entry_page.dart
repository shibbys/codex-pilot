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

  @override
  void dispose() {
    _weightCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Weight')),
      body: Padding(
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
                    final w = (snapshot.data as dynamic).weightKg as double;
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
            const SizedBox(height: 12),\n            // Nudge chips moved to History/Edit screen\n
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
            const SizedBox(height: 12),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
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

                  final db = ref.read(appDatabaseProvider);
                  await db.addWeightEntry(
                    date: _date,
                    weightKg: weight,
                    note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
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

