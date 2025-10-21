import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          const SizedBox(height: 8),
          _SummaryCard(title: tr(ref, 'goal'), value: goalText),
          const SizedBox(height: 8),
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
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(tr(ref, 'all')),
                selected: ref.watch(chartDaysProvider) == 0,
                onSelected: (_) => ref.read(chartDaysProvider.notifier).state = 0,
              ),
              const Spacer(),
              Tooltip(
                message: ref.watch(chartByDaysProvider) ? tr(ref, 'days') : tr(ref, 'entries'),
                child: FilterChip(
                  label: Icon(ref.watch(chartByDaysProvider) ? Icons.calendar_today : Icons.view_list),
                  selected: ref.watch(chartByDaysProvider),
                  onSelected: (v) => ref.read(chartByDaysProvider.notifier).state = v,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TrendChart(days: ref.watch(chartDaysProvider), byDays: ref.watch(chartByDaysProvider)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(LogEntryPage.routePath),
        tooltip: tr(ref, 'logWeight'),
        child: const Icon(Icons.add),
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
  const TrendChart({
    required this.days,
    required this.byDays,
    this.showMetrics = true,
    this.expandChart = false,
    super.key,
  });
  final int days;
  final bool byDays;
  final bool showMetrics;
  final bool expandChart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(chartEntriesProvider);
    final goalObj = ref.watch(currentGoalProvider).value;
    final locale = ref.watch(i18nControllerProvider).valueOrNull ?? const Locale('en');
    final double? goalWeight = () {
      try {
        if (goalObj == null) return null;
        return (goalObj as dynamic).targetWeightKg as double;
      } catch (_) {
        return null;
      }
    }();

    final content = entriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('$e')),
            data: (items) {
              if (items.isEmpty) {
                return const Center(child: Text('-'));
              }

              List<dynamic> list = List<dynamic>.from(items);
              List<FlSpot> series = [];
              final List<DateTime> xDates = [];
              if (!byDays) {
                // Entries mode
                final takeAll = days == 0;
                final recent = takeAll ? List<dynamic>.from(list) : list.take(days).toList();
                recent.sort((a, b) => ((a as dynamic).entryDate as DateTime)
                    .compareTo(((b as dynamic).entryDate as DateTime)));
                for (int i = 0; i < recent.length; i++) {
                  final w = (recent[i] as dynamic).weightKg as double;
                  series.add(FlSpot(i.toDouble(), w));
                  xDates.add((recent[i] as dynamic).entryDate as DateTime);
                }
              } else {
                final takeAll = days == 0;
                DateTime start;
                DateTime end;
                if (takeAll) {
                  // From earliest entry to today
                  DateTime earliest = DateTime.now();
                  DateTime latest = DateTime(1900);
                  for (final e in list) {
                    final d = (e as dynamic).entryDate as DateTime;
                    if (d.isBefore(earliest)) earliest = d;
                    if (d.isAfter(latest)) latest = d;
                  }
                  start = DateTime(earliest.year, earliest.month, earliest.day);
                  end = DateTime.now();
                } else {
                  // Anchor window to latest entry
                  DateTime latest = DateTime.now();
                  for (final e in list) {
                    final d = (e as dynamic).entryDate as DateTime;
                    if (d.isAfter(latest)) latest = d;
                  }
                  final base = DateTime(latest.year, latest.month, latest.day);
                  start = base.subtract(Duration(days: days - 1));
                  end = base;
                }
                final dayCount = end.difference(start).inDays + 1;
                final map = <DateTime, double?>{};
                for (int i = 0; i < dayCount; i++) {
                  final d = DateTime(start.year, start.month, start.day).add(Duration(days: i));
                  map[d] = null;
                }
                // Use the latest entry per day; ensure we iterate ascending so later entries overwrite earlier ones during fill-forward
                final sorted = List<dynamic>.from(list)
                  ..sort((a, b) => ((a as dynamic).entryDate as DateTime)
                      .compareTo(((b as dynamic).entryDate as DateTime)));
                for (final e in sorted) {
                  final d = (e as dynamic).entryDate as DateTime;
                  final key = DateTime(d.year, d.month, d.day);
                  if (map.containsKey(key)) {
                    map[key] = e.weightKg as double;
                  }
                }
                int idx = 0;
                double? last;
                for (final v in map.values) {
                  if (v != null) last = v;
                  if (last != null) {
                    series.add(FlSpot(idx.toDouble(), last));
                  }
                  xDates.add(DateTime(start.year, start.month, start.day).add(Duration(days: idx)));
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

              // Axis labels: bottom shows dd/MM on a few evenly spaced points
              List<String> bottomLabels = List.generate(xDates.length, (i) {
                final d = xDates[i];
                final dd = d.day.toString().padLeft(2, '0');
                final mm = d.month.toString().padLeft(2, '0');
                return '$dd/$mm';
              });

              // Show exactly 7 evenly spaced labels when possible (including first & last)
              // If there are fewer than 7 points, show all of them.
              final int desiredLabelCount = 7;
              final Set<int> labelIndices = <int>{};
              if (bottomLabels.length <= desiredLabelCount) {
                for (int i = 0; i < bottomLabels.length; i++) {
                  labelIndices.add(i);
                }
              } else {
                for (int k = 0; k < desiredLabelCount; k++) {
                  final double pos = k * (bottomLabels.length - 1) / (desiredLabelCount - 1);
                  labelIndices.add(pos.round());
                }
              }

              // Compute y-bounds with padding
              double minY = series.first.y;
              double maxY = series.first.y;
              for (final s in series) {
                if (s.y < minY) minY = s.y;
                if (s.y > maxY) maxY = s.y;
              }
              if (goalWeight != null) {
                if (goalWeight < minY) minY = goalWeight;
                if (goalWeight > maxY) maxY = goalWeight;
              }
              final padding = (maxY - minY).abs() * 0.1 + 0.5;
              minY -= padding;
              maxY += padding;

              final chart = LineChart(
                LineChartData(
                  minX: 0,
                  maxX: series.last.x,
                  minY: minY,
                  maxY: maxY,
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: ((maxY - minY) / 2).clamp(0.5, double.infinity),
                        getTitlesWidget: (value, meta) {
                          return Text(value.toStringAsFixed(0), style: Theme.of(context).textTheme.bodySmall);
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final i = value.round();
                          if (i < 0 || i >= bottomLabels.length) return const SizedBox.shrink();
                          if (!labelIndices.contains(i)) return const SizedBox.shrink();
                          final label = Text(
                            bottomLabels[i],
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Transform.rotate(angle: -math.pi / 4, child: label),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true, border: const Border.fromBorderSide(BorderSide(color: Colors.grey))),
                  lineBarsData: [
                    LineChartBarData(
                      spots: series,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                          radius: 3,
                          color: Theme.of(context).colorScheme.primary,
                          strokeWidth: 1.5,
                          strokeColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    if (trend.isNotEmpty)
                      LineChartBarData(
                        spots: trend,
                        isCurved: false,
                        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
                        dotData: const FlDotData(show: false),
                        dashArray: [8, 4],
                        barWidth: 2,
                      ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
                      tooltipRoundedRadius: 8,
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((t) {
                          final i = t.x.round().clamp(0, bottomLabels.length - 1);
                          final dateLabel = bottomLabels[i];
                          final txtStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ) ??
                              const TextStyle(color: Colors.black);
                          return LineTooltipItem('${t.y.toStringAsFixed(1)} kg\n$dateLabel', txtStyle);
                        }).toList();
                      },
                    ),
                  ),
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

              // Goal distance and ETA / needed per day card
              Widget metricsCard() {
                double? goal = goalWeight;
                final theme = Theme.of(context);
                if (goal == null) return const SizedBox.shrink();
                final last = series.last.y;
                final delta = goal - last; // + need to gain, - need to lose

                // Trend slope per x-unit
                double? slope;
                {
                  final n = series.length;
                  final sumX = series.fold<double>(0, (s, p) => s + p.x);
                  final sumY = series.fold<double>(0, (s, p) => s + p.y);
                  final sumXX = series.fold<double>(0, (s, p) => s + p.x * p.x);
                  final sumXY = series.fold<double>(0, (s, p) => s + p.x * p.y);
                  final denom2 = (n * sumXX - sumX * sumX);
                  if (denom2 != 0) {
                    slope = (n * sumXY - sumX * sumY) / denom2;
                  }
                }

                double? etaDays;
                if (slope != null && slope != 0) {
                  double stepDays = 1;
                  if (!byDays && xDates.length >= 2) {
                    final totalDays = (xDates.last.difference(xDates.first).inDays).abs();
                    if (totalDays > 0) {
                      stepDays = totalDays / (xDates.length - 1);
                    }
                  }
                  final estSteps = delta / slope;
                  final estDays = estSteps * stepDays;
                  if (estDays >= 0) { etaDays = estDays; }
                }
                final int? etaD = etaDays?.round();

                // Average per day over selected window (or all), using first/last points
                double? neededPerDay; // reuse UI slot for average
                if (xDates.isNotEmpty) {
                  final spanDays = (xDates.last.difference(xDates.first).inDays).abs();
                  if (spanDays > 0) {
                    neededPerDay = (series.last.y - series.first.y) / spanDays;
                  } else {
                    neededPerDay = 0;
                  }
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              delta >= 0 ? Icons.north_east : Icons.south_east,
                              size: 16,
                              color: theme.colorScheme.onSurface,
                            ),
                            const SizedBox(width: 8),
                            Text('${delta.abs().toStringAsFixed(1)} kg ${tr(ref, 'toGoal')}', style: theme.textTheme.bodyMedium),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.trending_up, size: 16),
                            const SizedBox(width: 8),
                            Text('${tr(ref, 'trend')}: ${(slope ?? 0).toStringAsFixed(2)} kg/${tr(ref, 'daysShort')}', style: theme.textTheme.bodyMedium),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (etaD != null)
                          Row(
                            children: [
                              const Icon(Icons.schedule, size: 16),
                              const SizedBox(width: 8),
                              Builder(builder: (_) {
                                final now = DateTime.now();
                                final etaDate = DateTime(now.year, now.month, now.day).add(Duration(days: etaD));
                                final dd = DateFormat('dd', locale.languageCode).format(etaDate);
                                var mon = DateFormat('MMM', locale.languageCode)
                                    .format(etaDate)
                                    .replaceAll('.', '')
                                    .toLowerCase();
                                final yy = DateFormat('yy', locale.languageCode).format(etaDate);
                                final etaStr = '$dd/$mon/$yy';
                                return Text(
                                  '${tr(ref, 'eta')} ~ $etaD${tr(ref, 'daysShort')} (${tr(ref, 'byApprox')} $etaStr)',
                                  style: theme.textTheme.bodyMedium,
                                );
                              }),
                            ],
                          )
                        else if (slope != null && slope != 0)
                          Text(tr(ref, 'movingAway'), style: theme.textTheme.bodyMedium)
                        else
                          const SizedBox.shrink(),
                        if (neededPerDay != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.speed, size: 16),
                              const SizedBox(width: 8),
                              Text('${tr(ref, 'average')}: ${neededPerDay.toStringAsFixed(2)} kg/${tr(ref, 'daysShort')}', style: theme.textTheme.bodyMedium),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }

              // Two modes:
              // - Default: compact card with fixed-height chart + metrics below.
              // - Fullscreen: expand chart to fill available space and hide metrics to avoid overflow.
              if (expandChart) {
                return SizedBox.expand(child: chart);
              } else {
                return Column(
                  children: [
                    SizedBox(\n                      height: 160,\n                      child: Stack(\n                        children: [\n                          Positioned.fill(child: chart),\n                          Positioned(\n                            bottom: 6,\n                            right: 6,\n                            child: IconButton(\n                              tooltip: tr(ref, 'fullscreen'),\n                              icon: const Icon(Icons.fullscreen),\n                              onPressed: () async {\n                                await Navigator.of(context).push(MaterialPageRoute(\n                                  builder: (_) => FullscreenChartPage(days: days, byDays: byDays),\n                                ));\n                              },\n                            ),\n                          ),\n                        ],\n                      ),\n                    ),
                    if (showMetrics) ...[
                      const SizedBox(height: 8),
                      metricsCard(),
                    ],
                  ],
                );
              }
            },
          );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: expandChart
            // Ensure the chart can grow to fill in fullscreen
            ? LayoutBuilder(
                builder: (context, constraints) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                      minWidth: constraints.maxWidth,
                    ),
                    child: content,
                  );
                },
              )
            : content,
      ),
    );
  }
}

class FullscreenChartPage extends ConsumerStatefulWidget {
  const FullscreenChartPage({required this.days, required this.byDays, super.key});
  final int days;
  final bool byDays;

  @override
  ConsumerState<FullscreenChartPage> createState() => _FullscreenChartPageState();
}

class _FullscreenChartPageState extends ConsumerState<FullscreenChartPage> {
  late int _days;
  late bool _byDays;

  @override
  void initState() {
    super.initState();
    _days = widget.days;
    _byDays = widget.byDays;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr(ref, 'fullscreen'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                children: [
                  ChoiceChip(label: const Text('7'), selected: _days == 7, onSelected: (_) => setState(() => _days = 7)),
                  const SizedBox(width: 8),
                  ChoiceChip(label: const Text('15'), selected: _days == 15, onSelected: (_) => setState(() => _days = 15)),
                  const SizedBox(width: 8),
                  ChoiceChip(label: const Text('30'), selected: _days == 30, onSelected: (_) => setState(() => _days = 30)),
                  const SizedBox(width: 8),
                  ChoiceChip(label: Text(tr(ref, 'all')), selected: _days == 0, onSelected: (_) => setState(() => _days = 0)),
                  const Spacer(),
                  Tooltip(
                    message: _byDays ? tr(ref, 'days') : tr(ref, 'entries'),
                    child: FilterChip(
                      label: Icon(_byDays ? Icons.calendar_today : Icons.view_list),
                      selected: _byDays,
                      onSelected: (v) => setState(() => _byDays = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TrendChart(
                  days: _days,
                  byDays: _byDays,
                  showMetrics: false,
                  expandChart: true,
                ),
              ),
            ],
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 22),
            ),
          ],
        ),
      ),
    );
  }
}


