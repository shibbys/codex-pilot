import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../data/local/app_database.dart';

class EditEntryPage extends ConsumerStatefulWidget {
  const EditEntryPage({
    super.key,
    required this.id,
    required this.initialDate,
    required this.initialWeight,
    this.initialNote,
  });

  final int id;
  final DateTime initialDate;
  final double initialWeight;
  final String? initialNote;

  @override
  ConsumerState<EditEntryPage> createState() => _EditEntryPageState();
}

class _EditEntryPageState extends ConsumerState<EditEntryPage> {
  late DateTime _date;
  late TextEditingController _weightCtrl;
  late TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate;
    _weightCtrl = TextEditingController(text: widget.initialWeight.toStringAsFixed(1));
    _noteCtrl = TextEditingController(text: widget.initialNote ?? '');
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _weightCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final raw = _weightCtrl.text.trim().replaceAll(',', '.');
                      final weight = double.tryParse(raw);
                      if (weight == null) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enter a valid weight (e.g., 72.5)')),
                        );
                        return;
                      }
                      final db = ref.read(appDatabaseProvider);
                      await db.updateWeightEntry(
                        id: widget.id,
                        date: _date,
                        weightKg: weight,
                        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
                      );
                      if (!context.mounted) return;
                      Navigator.of(context).pop(true);
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Entry'),
                        content: const Text('This will permanently delete this entry.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref.read(appDatabaseProvider).deleteWeightEntry(widget.id);
                      if (!context.mounted) return;
                      Navigator.of(context).pop(true);
                    }
                  },
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                )
              ],
            )
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
