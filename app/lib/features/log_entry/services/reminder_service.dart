import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReminderService {
  ReminderService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);
  }

  Future<void> scheduleDailyReminder({
    required int id,
    required Time time,
  }) async {
    debugPrint('Scheduling reminder with id=$id at ${time.hour}:${time.minute}');
    await _plugin.showDailyAtTime(
      id,
      'Weight Log Reminder',
      'Don\'t forget to record today\'s weight.',
      time,
      const NotificationDetails(
        android: AndroidNotificationDetails('daily_weight', 'Daily Weight Reminder'),
      ),
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
