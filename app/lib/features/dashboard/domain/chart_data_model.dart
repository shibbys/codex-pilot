import 'package:fl_chart/fl_chart.dart';

/// Modelo imutável contendo todos os dados necessários para renderizar o gráfico
class ChartDataModel {
  final List<FlSpot> dataPoints;
  final List<FlSpot> trendLine;
  final List<DateTime> xAxisDates;
  final List<String> xAxisLabels;
  final Set<int> visibleLabelIndices;
  final double minY;
  final double maxY;
  final double yStep;
  final List<double> yTicks;
  final double? goalWeight;
  final ChartMetrics? metrics;

  const ChartDataModel({
    required this.dataPoints,
    required this.trendLine,
    required this.xAxisDates,
    required this.xAxisLabels,
    required this.visibleLabelIndices,
    required this.minY,
    required this.maxY,
    required this.yStep,
    required this.yTicks,
    this.goalWeight,
    this.metrics,
  });

  bool get isEmpty => dataPoints.isEmpty;
  bool get hasGoal => goalWeight != null;
}

/// Métricas calculadas sobre os dados
class ChartMetrics {
  final double deltaToGoal; // Positivo = precisa ganhar, Negativo = precisa perder
  final double slopePerDay; // kg/dia
  final int? etaDays; // Dias até atingir meta (null se não calculável)
  final DateTime? etaDate;
  final double? averagePerDay; // Média kg/dia no período
  final bool isMovingTowardGoal;

  const ChartMetrics({
    required this.deltaToGoal,
    required this.slopePerDay,
    this.etaDays,
    this.etaDate,
    this.averagePerDay,
    required this.isMovingTowardGoal,
  });
}

/// Configuração de visualização do gráfico
class ChartConfig {
  final int days; // 0 = all
  final bool byDays; // false = entries, true = days

  const ChartConfig({
    required this.days,
    required this.byDays,
  });

  ChartConfig copyWith({int? days, bool? byDays}) {
    return ChartConfig(
      days: days ?? this.days,
      byDays: byDays ?? this.byDays,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartConfig &&
          runtimeType == other.runtimeType &&
          days == other.days &&
          byDays == other.byDays;

  @override
  int get hashCode => days.hashCode ^ byDays.hashCode;
}
