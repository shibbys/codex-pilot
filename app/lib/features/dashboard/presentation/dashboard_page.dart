import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../history/presentation/history_page.dart';
import '../../settings/presentation/settings_page.dart';
import '../../log_entry/presentation/log_entry_page.dart';
import '../../../data/local/app_database.dart';
import '../../../core/i18n/translations.dart';

final latestEntryProvider = StreamProvider<Object?>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchLatestEntry();
});

final currentGoalProvider = StreamProvider<Object?>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchCurrentGoal();
});

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  static const String routePath = '/dashboard';
  static const String routeName = 'dashboard';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latest = ref.watch(latestEntryProvider).value;
    final goal = ref.watch(currentGoalProvider).value;
    String latestText = '-- kg';
    if (latest != null) {
      try {
        final w = (latest as dynamic).weightKg as double;
        latestText = '${w.toStringAsFixed(1)} kg';
      } catch (_) {}
    }
    String goalText = tr(ref, 'goalProgress');
    if (goal != null) {
      try {
        final g = goal as dynamic;
        final target = (g.targetWeightKg as double).toStringAsFixed(1);
        final date = g.targetDate as DateTime?;
        goalText = date != null ? 'Target: $target kg by ${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}' : 'Target: $target kg';
        if (latestText != '-- kg') {
          final lw = (latest as dynamic).weightKg as double;
          final diff = (lw - (g.targetWeightKg as double));
          final remaining = diff > 0 ? '${diff.toStringAsFixed(1)} kg remaining' : 'Goal reached!';
          goalText = '$goalText  •  $remaining';
        }
      } catch (_) {}
    } else {
      goalText = 'No goal set';
    }
    // Current page is Dashboard, keep index fixed to 0.
    const int currentIndex = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(ref, 'dashboardTitle')),
        actions: [
          IconButton(
            tooltip: tr(ref, 'settingsTitle'),
            icon: const Icon(Icons.settings),
            onPressed: () => context.go(SettingsPage.routePath),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _SummaryCard(title: tr(ref, 'latestWeight'), value: latestText),
          const SizedBox(height: 12),
          _SummaryCard(title: tr(ref, 'goal'), value: goalText),
          const SizedBox(height: 12),
          _SummaryCard(title: tr(ref, 'trend'), value: '—'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(LogEntryPage.routePath),
        icon: const Icon(Icons.add),
        label: const Text('Log Weight'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go(DashboardPage.routePath);
              break;
            case 1:
              context.go(HistoryPage.routePath);
              break;
            case 2:
              context.go(SettingsPage.routePath);
              break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}
