import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../log_entry/services/reminder_service.dart';
import '../../../../core/i18n/translations.dart';
import 'reminder_config_dialog.dart';

class ReminderSection extends ConsumerStatefulWidget {
  const ReminderSection({super.key});

  @override
  ConsumerState<ReminderSection> createState() => _ReminderSectionState();
}

class _ReminderSectionState extends ConsumerState<ReminderSection> {
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  Set<int> _selectedDays = {1, 2, 3, 4, 5}; // Weekdays por padrão
  bool _hasReminders = false;

  @override
  void initState() {
    super.initState();
    _loadSavedConfig();
  }

  Future<void> _loadSavedConfig() async {
    final svc = ref.read(reminderServiceProvider);
    final saved = await svc.loadSavedReminderConfig();
    
    if (!mounted) return;
    
    if (saved != null) {
      setState(() {
        _time = TimeOfDay(hour: saved.hour, minute: saved.minute);
        _selectedDays = saved.daysOfWeek;
      });
    }

    final hasActive = await svc.hasActiveReminders();
    if (!mounted) return;
    
    setState(() => _hasReminders = hasActive);
  }

  Future<void> _openConfigDialog() async {
    if (!mounted) return;
    
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ReminderConfigDialog(
        initialTime: _time,
        initialDays: _selectedDays,
      ),
    );

    if (!mounted || result == null) return;

    final newTime = result['time'] as TimeOfDay;
    final newDays = result['days'] as Set<int>;

    setState(() {
      _time = newTime;
      _selectedDays = newDays;
    });

    // Agendar lembretes
    final svc = ref.read(reminderServiceProvider);
    
    // Verificar e solicitar permissões se necessário
    final canSchedule = await svc.canScheduleExactAlarms();
    
    if (!mounted) return;
    
    if (!canSchedule) {
      final shouldRequest = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Permissão Necessária'),
          content: const Text(
            'Este app precisa de permissão para agendar alarmes exatos. '
            'Isso garante que os lembretes sejam entregues no horário correto.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Conceder Permissão'),
            ),
          ],
        ),
      );

      if (shouldRequest == true) {
        await svc.requestExactAlarmPermission();
      }
    }

    // Agendar
    await svc.scheduleWeeklyReminders(
      baseId: 100,
      hour: newTime.hour,
      minute: newTime.minute,
      daysOfWeek: newDays,
    );

    await _loadSavedConfig();

    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${tr(ref, 'scheduledAt')} ${newTime.format(context)} '
          '(${newDays.length} ${tr(ref, 'days')})',
        ),
      ),
    );
  }

  Future<void> _cancelReminders() async {
    if (!mounted) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr(ref, 'cancel')),
        content: const Text('Deseja cancelar todos os lembretes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sim'),
          ),
        ],
      ),
    );

    if (!mounted || confirm != true) return;

    await ref.read(reminderServiceProvider).cancelAllReminders();
    await _loadSavedConfig();

    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lembretes cancelados')),
    );
  }

  String _formatDays() {
    if (_selectedDays.isEmpty) return '--';
    if (_selectedDays.length == 7) return '${tr(ref, 'all')} ${tr(ref, 'days')}';

    final locale = ref.watch(i18nControllerProvider).valueOrNull ?? const Locale('en');
    final isPt = locale.languageCode == 'pt';

    final dayNames = isPt
        ? ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom']
        : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final sorted = _selectedDays.toList()..sort();
    return sorted.map((d) => dayNames[d - 1]).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(ref, 'remindersTitle'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _hasReminders ? Icons.notifications_active : Icons.notifications_off,
                      color: _hasReminders ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _hasReminders ? 'Lembretes Ativos' : 'Nenhum Lembrete',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (_hasReminders) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${_time.format(context)} • ${_formatDays()}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _openConfigDialog,
                        icon: const Icon(Icons.alarm_add),
                        label: Text(_hasReminders ? 'Reconfigurar' : tr(ref, 'schedule')),
                      ),
                    ),
                    if (_hasReminders) ...[
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _cancelReminders,
                        icon: const Icon(Icons.alarm_off),
                        label: Text(tr(ref, 'cancel')),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
