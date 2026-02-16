import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/chart_data_model.dart';

class TrendChartWidget extends StatelessWidget {
  const TrendChartWidget({
    required this.chartData,
    this.expandChart = false,
    super.key,
  });

  final ChartDataModel chartData;
  final bool expandChart;

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return const Center(child: Text('-'));
    }

    final chart = LineChart(
      LineChartData(
        minX: 0,
        maxX: chartData.dataPoints.last.x,
        minY: chartData.minY,
        maxY: chartData.maxY,
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: chartData.yStep,
              getTitlesWidget: (value, meta) {
                const double eps = 0.01;
                final match = chartData.yTicks.any((t) => (value - t).abs() < eps);
                if (!match) return const SizedBox.shrink();
                return Text(
                  value.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.bodySmall,
                );
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
                if (i < 0 || i >= chartData.xAxisLabels.length) {
                  return const SizedBox.shrink();
                }
                if (!chartData.visibleLabelIndices.contains(i)) {
                  return const SizedBox.shrink();
                }
                final label = Text(
                  chartData.xAxisLabels[i],
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
        borderData: FlBorderData(
          show: true,
          border: const Border.fromBorderSide(BorderSide(color: Colors.grey)),
        ),
        lineBarsData: [
          // Linha principal de dados
          LineChartBarData(
            spots: chartData.dataPoints,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.20),
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.00),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 2,
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 1.0,
                strokeColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
              ),
            ),
          ),
          // Linha de tendência
          if (chartData.trendLine.isNotEmpty)
            LineChartBarData(
              spots: chartData.trendLine,
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
            getTooltipColor: (_) =>
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
            tooltipRoundedRadius: 8,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (touchedSpots) {
              final seen = <int>{};
              return touchedSpots.map((t) {
                final i = t.x.round().clamp(0, chartData.xAxisLabels.length - 1);
                if (seen.contains(i)) {
                  return null;
                }
                seen.add(i);
                final dateLabel = chartData.xAxisLabels[i];
                final txtStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ) ??
                    const TextStyle(color: Colors.black);
                return LineTooltipItem(
                  '${t.y.toStringAsFixed(1)} kg\n$dateLabel',
                  txtStyle,
                );
              }).toList();
            },
          ),
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            if (chartData.hasGoal)
              HorizontalLine(
                y: chartData.goalWeight!,
                color: Colors.redAccent,
                strokeWidth: 1.5,
                dashArray: [6, 4],
              ),
          ],
        ),
      ),
    );

    if (expandChart) {
      return SizedBox.expand(child: chart);
    } else {
      return SizedBox(height: 160, child: chart);
    }
  }
}
