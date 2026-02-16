import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/i18n/translations.dart';

class ReminderConfigDialog extends ConsumerStatefulWidget {
  const ReminderConfigDialog({
    required this.initialTime,
    required this.initialDays,
    super.key,
  });

  final TimeOfDay initialTime;
  final Set<int> initialDays; // 1=Monday, 7=Sunday

  @override
  ConsumerState<ReminderConfigDialog> createState() => _ReminderConfigDialogState();
}

class _ReminderConfigDialogState extends ConsumerState<ReminderConfigDialog> {
  late TimeOfDay _selectedTime;
  late Set<int> _selectedDays;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
    _selectedDays = Set.from(widget.initialDays);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(i18nControllerProvider).valueOrNull ?? const Locale('en');
    final isPt = locale.languageCode == 'pt';

    final dayNames = isPt
        ? ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom']
        : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return AlertDialog(
      title: Text(isPt ? 'Configurar Lembrete' : 'Configure Reminder'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Picker
            Text(
              isPt ? 'Horário' : 'Time',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (picked != null) {
                  setState(() => _selectedTime = picked);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: const Icon(Icons.access_time),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                child: Text(
                  _selectedTime.format(context),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Days of Week Selector
            Text(
              isPt ? 'Dias da Semana' : 'Days of Week',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(7, (index) {
                final dayNumber = index + 1; // 1=Monday, 7=Sunday
                final isSelected = _selectedDays.contains(dayNumber);

                return FilterChip(
                  label: Text(dayNames[index]),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDays.add(dayNumber);
                      } else {
                        _selectedDays.remove(dayNumber);
                      }
                    });
                  },
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
                );
              }),
            ),
            const SizedBox(height: 8),

            // Quick select buttons
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() => _selectedDays = {1, 2, 3, 4, 5});
                  },
                  child: Text(isPt ? 'Dias úteis' : 'Weekdays'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    setState(() => _selectedDays = {1, 2, 3, 4, 5, 6, 7});
                  },
                  child: Text(isPt ? 'Todos os dias' : 'Every day'),
                ),
              ],
            ),

            if (_selectedDays.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  isPt
                      ? 'Selecione pelo menos um dia'
                      : 'Select at least one day',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr(ref, 'cancel')),
        ),
        ElevatedButton(
          onPressed: _selectedDays.isEmpty
              ? null
              : () {
                  Navigator.of(context).pop({
                    'time': _selectedTime,
                    'days': _selectedDays,
                  });
                },
          child: Text(isPt ? 'Confirmar' : 'Confirm'),
        ),
      ],
    );
  }
}
