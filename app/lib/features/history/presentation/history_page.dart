import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../dashboard/presentation/dashboard_page.dart';
import '../../settings/presentation/settings_page.dart';
import '../../../data/local/app_database.dart';

final allEntriesProvider = StreamProvider<List<Object?>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchAllEntries();
});

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  static const String routePath = '/history';
  static const String routeName = 'history';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Current page is History, keep index fixed to 1.
    const int currentIndex = 1;

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: ref.watch(allEntriesProvider).when(
            data: (items) => ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final e = items[index] as dynamic;
                final d = e.entryDate as DateTime;
                final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                return ListTile(
                  leading: const Icon(Icons.monitor_weight),
                  title: Text('${(e.weightKg as double).toStringAsFixed(1)} kg'),
                  subtitle: Text(dateStr + (e.note == null ? '' : '  •  ${e.note as String}')),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Failed to load: $e')),
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
