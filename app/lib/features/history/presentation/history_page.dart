import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../dashboard/presentation/dashboard_page.dart';
import '../../settings/presentation/settings_page.dart';
import '../../../data/local/app_database.dart';
import '../../../core/i18n/translations.dart';
import 'edit_entry_page.dart';

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
    const int currentIndex = 1; // History tab index

    final locale = ref.watch(i18nControllerProvider).valueOrNull ?? const Locale('en');
    return Scaffold(
      appBar: AppBar(title: Text(tr(ref, 'historyTitle'))),
      body: ref.watch(allEntriesProvider).when(
            data: (items) {
              final list = List<dynamic>.from(items);
              list.sort((a, b) => (b as dynamic).entryDate.compareTo((a as dynamic).entryDate));
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (ctx, __) => Divider(height: 1, color: Theme.of(ctx).dividerColor.withValues(alpha: 0.08)),
                itemBuilder: (context, index) {
                  final e = list[index] as dynamic;
                  final d = e.entryDate as DateTime;
                  final day = DateFormat('dd', locale.languageCode).format(d);
                  var mon = DateFormat('MMM', locale.languageCode).format(d).replaceAll('.', '');
                  if (mon.isNotEmpty) {
                    mon = mon[0].toUpperCase() + mon.substring(1);
                  }
                  final yr = DateFormat('yy', locale.languageCode).format(d);
                  final dateStr = '$day/$mon/$yr';
                  return ListTile(
                    leading: const Icon(Icons.monitor_weight_outlined),
                    title: Text('${(e.weightKg as double).toStringAsFixed(1)} kg'),
                    subtitle: Text(dateStr + (e.note == null ? '' : '  •  ${e.note as String}')),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final changed = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => EditEntryPage(
                            id: (e.id as int),
                            initialDate: d,
                            initialWeight: (e.weightKg as double),
                            initialNote: e.note as String?,
                          ),
                        ),
                      );
                      if (changed == true && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Entry updated')),
                        );
                      }
                    },
                  );
                },
              );
            },
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
