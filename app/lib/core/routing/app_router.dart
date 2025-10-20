import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/history/presentation/history_page.dart';
import '../../features/log_entry/presentation/log_entry_page.dart';
import '../../features/settings/presentation/settings_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final navigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: DashboardPage.routePath,
    routes: <RouteBase>[
      GoRoute(
        path: DashboardPage.routePath,
        name: DashboardPage.routeName,
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: HistoryPage.routePath,
        name: HistoryPage.routeName,
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: SettingsPage.routePath,
        name: SettingsPage.routeName,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: LogEntryPage.routePath,
        name: LogEntryPage.routeName,
        builder: (context, state) => const LogEntryPage(),
      ),
    ],
  );
});
