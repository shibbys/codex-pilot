import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ReminderService {
  ReminderService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  static const _reminderConfigKey = 'reminder_config';

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);

    // Android 13+ runtime notification permission
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }

    // Timezone initialization
    tz.initializeTimeZones();
    final String localTz = await NativeTimezone.getLocalTimezone();
    try {
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  /// Agenda lembretes para os dias da semana especificados
  /// [baseId] - ID base (cada dia terá baseId + dayOfWeek)
  /// [hour] - Hora do lembrete (0-23)
  /// [minute] - Minuto do lembrete (0-59)
  /// [daysOfWeek] - Set de dias (1=Monday, 7=Sunday)
  Future<void> scheduleWeeklyReminders({
    required int baseId,
    required int hour,
    required int minute,
    required Set<int> daysOfWeek,
  }) async {
    // Cancela todos os lembretes anteriores
    await cancelAllReminders();

    // Agenda um lembrete para cada dia selecionado
    for (final dayOfWeek in daysOfWeek) {
      final id = baseId + dayOfWeek;
      await _scheduleWeeklyReminder(
        id: id,
        hour: hour,
        minute: minute,
        dayOfWeek: dayOfWeek,
      );
    }

    // Persiste configuração
    await _saveReminderConfig(
      hour: hour,
      minute: minute,
      daysOfWeek: daysOfWeek,
    );
  }

  Future<void> _scheduleWeeklyReminder({
    required int id,
    required int hour,
    required int minute,
    required int dayOfWeek, // 1=Monday, 7=Sunday
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    // Encontra a próxima ocorrência deste dia da semana
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Ajusta para o dia da semana correto
    while (scheduled.weekday != dayOfWeek) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    // Se já passou hoje, agenda para a próxima semana
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 7));
    }

    debugPrint('Scheduling reminder id=$id for ${_dayName(dayOfWeek)} at ${scheduled.toLocal()}');

    try {
      await _plugin.zonedSchedule(
        id,
        'Lembrete de Peso',
        'Não esqueça de registrar seu peso hoje!',
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_weight',
            'Lembrete de Peso Diário',
            channelDescription: 'Lembrete diário para registrar peso',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } on Exception catch (e) {
      debugPrint('Exact schedule failed ($e). Falling back to inexact.');
      
      // Tenta pedir permissão de alarme exato
      try {
        final androidImpl = _plugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        final hasPermission = await androidImpl?.canScheduleExactNotifications() ?? false;
        if (!hasPermission) {
          await androidImpl?.requestExactAlarmsPermission();
        }
      } catch (_) {}

      // Fallback para inexact
      await _plugin.zonedSchedule(
        id,
        'Lembrete de Peso',
        'Não esqueça de registrar seu peso hoje!',
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_weight',
            'Lembrete de Peso Diário',
            channelDescription: 'Lembrete diário para registrar peso',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  String _dayName(int dayOfWeek) {
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dayOfWeek];
  }

  Future<void> cancelAllReminders() async {
    debugPrint('Canceling all reminders');
    await _plugin.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_reminderConfigKey);
  }

  Future<bool> hasActiveReminders() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending.isNotEmpty;
  }

  Future<({int hour, int minute, Set<int> daysOfWeek})?> loadSavedReminderConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_reminderConfigKey);
    if (json == null) return null;

    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      final hour = map['hour'] as int;
      final minute = map['minute'] as int;
      final daysList = (map['daysOfWeek'] as List).cast<int>();
      return (
        hour: hour,
        minute: minute,
        daysOfWeek: daysList.toSet(),
      );
    } catch (e) {
      debugPrint('Failed to load reminder config: $e');
      return null;
    }
  }

  Future<void> _saveReminderConfig({
    required int hour,
    required int minute,
    required Set<int> daysOfWeek,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode({
      'hour': hour,
      'minute': minute,
      'daysOfWeek': daysOfWeek.toList(),
    });
    await prefs.setString(_reminderConfigKey, json);
  }

  Future<void> rescheduleSavedReminders({required int baseId}) async {
    final saved = await loadSavedReminderConfig();
    if (saved != null) {
      await scheduleWeeklyReminders(
        baseId: baseId,
        hour: saved.hour,
        minute: saved.minute,
        daysOfWeek: saved.daysOfWeek,
      );
    }
  }

  /// Verifica se o app tem permissão para agendar alarmes exatos
  Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;
    
    try {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await androidImpl?.canScheduleExactNotifications() ?? false;
    } catch (e) {
      debugPrint('Error checking exact alarm permission: $e');
      return false;
    }
  }

  /// Solicita permissão para agendar alarmes exatos (Android 12+)
  Future<void> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return;

    try {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.requestExactAlarmsPermission();
    } catch (e) {
      debugPrint('Error requesting exact alarm permission: $e');
    }
  }
}

final reminderPluginProvider = Provider<FlutterLocalNotificationsPlugin>((ref) {
  return FlutterLocalNotificationsPlugin();
});

final reminderServiceProvider = Provider<ReminderService>((ref) {
  final plugin = ref.watch(reminderPluginProvider);
  return ReminderService(plugin);
});
