import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../history/presentation/history_page.dart';
import '../../settings/presentation/settings_page.dart';
import '../../log_entry/presentation/log_entry_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const String routePath = '/dashboard';
  static const String routeName = 'dashboard';

  @override
  Widget build(BuildContext context) {
    final location = GoRouter.of(context).location;
    int currentIndex = 0;
    if (location.startsWith(HistoryPage.routePath)) currentIndex = 1;
    if (location.startsWith(SettingsPage.routePath)) currentIndex = 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Weight Tracker'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () => context.go(SettingsPage.routePath),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const <Widget>[
          _SummaryCard(title: 'Today\'s Weight', value: '-- kg'),
          SizedBox(height: 12),
          _SummaryCard(title: 'Trend', value: 'No data yet'),
          SizedBox(height: 12),
          _SummaryCard(title: 'Goal Progress', value: 'Set a goal to begin'),
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
