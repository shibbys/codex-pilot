import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
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

final chartEntriesProvider = StreamProvider<List<Object?>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchAllEntries();
});

final chartDaysProvider = StateProvider<int>((ref) => 7); // 7, 15, 30
final chartByDaysProvider = StateProvider<bool>((ref) => false); // false: entries, true: days

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  static const String routePath = '/dashboard';
  static const String routeName = 'dashboard';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latest = ref.watch(latestEntryProvider).value;
    final goal = ref.watch(currentGoalProvider).value;
    final locale = ref.watch(i18nControllerProvider).valueOrNull ?? const Locale('en');
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
    // Compact goal display: e.g., 100kg by 03/Jan/26
    if (goal != null) {
      try {
        final g = goal as dynamic;
        final tgt = (g.targetWeightKg as double);
        final targetStr = tgt % 1 == 0 ? '${tgt.toInt()}kg' : '${tgt.toStringAsFixed(1)}kg';
        final date = g.targetDate as DateTime?;
        if (date != null) {
          final dd = DateFormat('dd', locale.languageCode).format(date);
          var mon = DateFormat('MMM', locale.languageCode).format(date).replaceAll('.', '');
          if (mon.isNotEmpty) mon = mon[0].toUpperCase() + mon.substring(1);
          final yy = DateFormat('yy', locale.languageCode).format(date);
          goalText = '$targetStr ${tr(ref, 'by')} $dd/$mon/$yy';
        } else {
          goalText = targetStr;
        }
      } catch (_) {}
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
          Row(
            children: [
              ChoiceChip(
                label: const Text('7'),
                selected: ref.watch(chartDaysProvider) == 7,
                onSelected: (_) => ref.read(chartDaysProvider.notifier).state = 7,
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('15'),
                selected: ref.watch(chartDaysProvider) == 15,
                onSelected: (_) => ref.read(chartDaysProvider.notifier).state = 15,
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('30'),
                selected: ref.watch(chartDaysProvider) == 30,
                onSelected: (_) => ref.read(chartDaysProvider.notifier).state = 30,
              ),
              const Spacer(),
              FilterChip(
                label: Text(ref.watch(chartByDaysProvider) ? tr(ref, 'days') : tr(ref, 'entries')),
                selected: ref.watch(chartByDaysProvider),
                onSelected: (v) => ref.read(chartByDaysProvider.notifier).state = v,
              ),
            ],
          ),
          const SizedBox(height: 8),
          TrendChart(days: ref.watch(chartDaysProvider), byDays: ref.watch(chartByDaysProvider)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(LogEntryPage.routePath),
        icon: const Icon(Icons.add),
        label: Text(tr(ref, 'logWeight')),
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

class TrendChart extends ConsumerWidget {
  const TrendChart({required this.days, required this.byDays, super.key});
  final int days;
  final bool byDays;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(chartEntriesProvider);
    final goalObj = ref.watch(currentGoalProvider).value;
    final double? goalWeight = () {
      try {
        if (goalObj == null) return null;
        return (goalObj as dynamic).targetWeightKg as double;
      } catch (_) {
        return null;
      }
    }();

    return SizedBox(
      height: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: entriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('$e')),
            data: (items) {
              if (items.isEmpty) {
                return const Center(child: Text('-'));
              }

              List<dynamic> list = List<dynamic>.from(items);
              List<FlSpot> series = [];
              if (!byDays) {
                final recent = list.take(days).toList().reversed.toList();
                for (int i = 0; i < recent.length; i++) {
                  final w = (recent[i] as dynamic).weightKg as double;
                  series.add(FlSpot(i.toDouble(), w));
                }
              } else {
                final now = DateTime.now();
                final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));
                final map = <DateTime, double?>{};
                for (int i = 0; i < days; i++) {
                  final d = DateTime(start.year, start.month, start.day).add(Duration(days: i));
                  map[d] = null;
                }
                for (final e in list) {
                  final d = (e as dynamic).entryDate as DateTime;
                  final key = DateTime(d.year, d.month, d.day);
                  if (map.containsKey(key) && map[key] == null) {
                    map[key] = e.weightKg as double;
                  }
                }
                int idx = 0;
                for (final v in map.values) {
                  if (v != null) series.add(FlSpot(idx.toDouble(), v));
                  idx++;
                }
              }

              if (series.isEmpty) {
                return const Center(child: Text('-'));
              }

              // Linear trendline
              List<FlSpot> trend = [];
              final n = series.length;
              final sumX = series.fold<double>(0, (s, p) => s + p.x);
              final sumY = series.fold<double>(0, (s, p) => s + p.y);
              final sumXX = series.fold<double>(0, (s, p) => s + p.x * p.x);
              final sumXY = series.fold<double>(0, (s, p) => s + p.x * p.y);
              final denom = (n * sumXX - sumX * sumX);
              if (denom != 0) {
                final b = (n * sumXY - sumX * sumY) / denom;
                final a = (sumY - b * sumX) / n;
                trend = [
                  FlSpot(series.first.x, a + b * series.first.x),
                  FlSpot(series.last.x, a + b * series.last.x),
                ];
              }

              return LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: true, border: const Border.fromBorderSide(BorderSide(color: Colors.grey))),
                  lineBarsData: [
                    LineChartBarData(
                      spots: series,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      dotData: const FlDotData(show: false),
                    ),
                    if (trend.isNotEmpty)
                      LineChartBarData(
                        spots: trend,
                        isCurved: false,
                        color: Theme.of(context).colorScheme.secondary,
                        dotData: const FlDotData(show: false),
                        dashArray: [8, 4],
                        strokeWidth: 2,
                      ),
                  ],
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      if (goalWeight != null)
                        HorizontalLine(
                          y: goalWeight,
                          color: Colors.redAccent,
                          strokeWidth: 1.5,
                          dashArray: [6, 4],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
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
