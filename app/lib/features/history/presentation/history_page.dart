import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../dashboard/presentation/dashboard_page.dart';
import '../../settings/presentation/settings_page.dart';
import '../../../data/local/app_database.dart';
import '../../../core/i18n/translations.dart';

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

    final locale = ref.watch(i18nControllerProvider).valueOrNull ?? const Locale('en');
    final df = DateFormat('dd-MMM-yy', locale.languageCode);
    return Scaffold(
      appBar: AppBar(title: Text(tr(ref, 'historyTitle'))),
      body: ref.watch(allEntriesProvider).when(
            data: (items) => ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final e = items[index] as dynamic;
                final d = e.entryDate as DateTime;
                final dateStr = df.format(d);
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
        destinations: [
          NavigationDestination(icon: const Icon(Icons.dashboard_outlined), selectedIcon: const Icon(Icons.dashboard), label: tr(ref, 'home')),
          NavigationDestination(icon: const Icon(Icons.history_outlined), selectedIcon: const Icon(Icons.history), label: tr(ref, 'history')),
          NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings), label: tr(ref, 'settings')),
        ],
      ),
    );
  }
}
