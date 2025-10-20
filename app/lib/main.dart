import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/log_entry/services/reminder_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AppRoot()));
}

class AppRoot extends ConsumerStatefulWidget {
  const AppRoot({super.key});

  @override
  ConsumerState<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<AppRoot> {
  @override
  void initState() {
    super.initState();
    // Initialize local notifications + timezone and reschedule saved reminders.
    // Skip during widget tests to avoid platform channel hangs.
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      Future.microtask(() async {
        final svc = ref.read(reminderServiceProvider);
        await svc.initialize();
        await svc.rescheduleSavedDailyReminder(id: 100);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final theme = ref.watch(themeControllerProvider);

    return theme.when(
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (e, st) => MaterialApp(
        home: Scaffold(body: Center(child: Text('Theme load error: $e'))),
      ),
      data: (settings) => MaterialApp.router(
        title: 'Daily Weight Tracker',
        theme: buildLightTheme(settings.seedColor),
        darkTheme: buildDarkTheme(settings.seedColor),
        themeMode: settings.mode,
        routerConfig: router,
      ),
    );
  }
}
