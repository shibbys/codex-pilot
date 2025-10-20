import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  ReminderService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);

    // Android 13+ runtime notification permission
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();

    // Timezone initialization
    tz.initializeTimeZones();
    try {
      final String localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (_) {
      // Fallback to UTC if timezone lookup fails
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  Future<void> scheduleDailyReminder({
    required int id,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    debugPrint('Scheduling reminder id=$id at ${scheduled.toLocal()}');

    await _plugin.zonedSchedule(
      id,
      'Weight Log Reminder',
      "Don't forget to record today's weight.",
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_weight',
          'Daily Weight Reminder',
          channelDescription: 'Daily reminder to log weight',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelReminder(int id) async {
    debugPrint('Cancel reminder id=$id');
    await _plugin.cancel(id);
  }

  Future<void> snoozeReminder({
    required int id,
    required Duration duration,
  }) async {
    debugPrint('Snoozing reminder id=$id for ${duration.inMinutes} minutes');
    // Placeholder: the actual implementation will reschedule using timezone-aware APIs.
  }
}

final reminderPluginProvider = Provider<FlutterLocalNotificationsPlugin>((ref) {
  return FlutterLocalNotificationsPlugin();
});

final reminderServiceProvider = Provider<ReminderService>((ref) {
  final plugin = ref.watch(reminderPluginProvider);
  return ReminderService(plugin);
});
