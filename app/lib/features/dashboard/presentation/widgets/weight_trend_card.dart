import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../data/local/app_database.dart';
import '../../../../core/i18n/translations.dart';

// Provider para o período selecionado
final trendPeriodProvider = StateProvider<int>((ref) => 30); // 30, 180, 365, 0 (tudo)

class WeightTrendCard extends ConsumerWidget {
  const WeightTrendCard({
    required this.entries,
    super.key,
  });

  final List<WeightEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (entries.length < 2) return const SizedBox.shrink();

    final locale = ref.watch(i18nControllerProvider).valueOrNull ?? const Locale('en');
    final selectedPeriod = ref.watch(trendPeriodProvider);
    final isPt = locale.languageCode == 'pt';
    final theme = Theme.of(context);

    // Ordenar
    final sorted = List<WeightEntry>.from(entries)
      ..sort((a, b) => a.entryDate.compareTo(b.entryDate));
    
    // Filtrar por período
    List<WeightEntry> filtered;
    if (selectedPeriod == 0) {
      filtered = sorted;
    } else {
      final cutoffDate = DateTime.now().subtract(Duration(days: selectedPeriod));
      filtered = sorted.where((e) => e.entryDate.isAfter(cutoffDate)).toList();
    }

    if (filtered.isEmpty) {
      filtered = sorted;
    }
    
    // Dados do gráfico
    final weights = filtered.map((e) => e.weightKg).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final currentWeight = weights.last;
    final firstWeight = weights.first;
    final change = currentWeight - firstWeight;

    // Calcular intervalo para tickers Y
    final range = maxWeight - minWeight;
    final yInterval = range > 0 ? range / 4 : 1.0;

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.show_chart,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isPt ? 'Tendência' : 'Trend',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (change <= 0 ? Colors.green : Colors.orange).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          change <= 0 ? Icons.trending_down : Icons.trending_up,
                          size: 14,
                          color: change <= 0 ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}kg',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: change <= 0 ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Period Selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _PeriodChip(
                      label: '30d',
                      value: 30,
                      selected: selectedPeriod == 30,
                      onTap: () => ref.read(trendPeriodProvider.notifier).state = 30,
                    ),
                    const SizedBox(width: 8),
                    _PeriodChip(
                      label: '180d',
                      value: 180,
                      selected: selectedPeriod == 180,
                      onTap: () => ref.read(trendPeriodProvider.notifier).state = 180,
                    ),
                    const SizedBox(width: 8),
                    _PeriodChip(
                      label: '1a',
                      value: 365,
                      selected: selectedPeriod == 365,
                      onTap: () => ref.read(trendPeriodProvider.notifier).state = 365,
                    ),
                    const SizedBox(width: 8),
                    _PeriodChip(
                      label: isPt ? 'Tudo' : 'All',
                      value: 0,
                      selected: selectedPeriod == 0,
                      onTap: () => ref.read(trendPeriodProvider.notifier).state = 0,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Chart com tickers melhorados
              SizedBox(
                height: 160,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: yInterval,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 42,
                          interval: yInterval,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Text(
                                value.toStringAsFixed(1),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: theme.colorScheme.outline,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          interval: weights.length > 15 ? (weights.length / 4).ceilToDouble() : (weights.length / 3).ceilToDouble(),
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= filtered.length) return const SizedBox();
                            
                            final date = filtered[index].entryDate;
                            final label = '${date.day}/${date.month}';
                            
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                label,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) => theme.colorScheme.primaryContainer,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final index = spot.x.toInt();
                            if (index < 0 || index >= filtered.length) return null;
                            
                            final entry = filtered[index];
                            final dateStr = '${entry.entryDate.day}/${entry.entryDate.month}';
                            
                            return LineTooltipItem(
                              '$dateStr\n${spot.y.toStringAsFixed(1)} kg',
                              TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    minY: minWeight - (range * 0.1),
                    maxY: maxWeight + (range * 0.1),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          weights.length,
                          (i) => FlSpot(i.toDouble(), weights[i]),
                        ),
                        isCurved: true,
                        curveSmoothness: 0.35,
                        color: theme.colorScheme.primary,
                        barWidth: 3,
                        dotData: FlDotData(
                          show: weights.length <= 15,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 3,
                              color: theme.colorScheme.primary,
                              strokeWidth: 2,
                              strokeColor: theme.colorScheme.surface,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              theme.colorScheme.primary.withValues(alpha: 0.2),
                              theme.colorScheme.primary.withValues(alpha: 0.05),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MiniStat(
                    label: isPt ? 'Atual' : 'Current',
                    value: '${currentWeight.toStringAsFixed(1)}kg',
                    color: theme.colorScheme.primary,
                  ),
                  _MiniStat(
                    label: isPt ? 'Mín' : 'Min',
                    value: '${minWeight.toStringAsFixed(1)}kg',
                    color: Colors.blue,
                  ),
                  _MiniStat(
                    label: isPt ? 'Máx' : 'Max',
                    value: '${maxWeight.toStringAsFixed(1)}kg',
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}
