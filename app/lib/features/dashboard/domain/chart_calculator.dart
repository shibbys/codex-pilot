import 'package:fl_chart/fl_chart.dart';
import 'chart_data_model.dart';
import '../../../data/local/app_database.dart';

/// Pure functions para cálculos do gráfico
class ChartCalculator {
  /// Converte entries em dados do gráfico baseado na configuração
  static ChartDataModel calculate({
    required List<WeightEntry> entries,
    required ChartConfig config,
    required String localeCode,
    double? goalWeight,
  }) {
    if (entries.isEmpty) {
      return ChartDataModel(
        dataPoints: const [],
        trendLine: const [],
        xAxisDates: const [],
        xAxisLabels: const [],
        visibleLabelIndices: const {},
        minY: 0,
        maxY: 100,
        yStep: 20,
        yTicks: const [],
      );
    }

    final processedData = config.byDays
        ? _processByDays(entries, config.days)
        : _processByEntries(entries, config.days);

    final dataPoints = processedData.spots;
    final xAxisDates = processedData.dates;

    if (dataPoints.isEmpty) {
      return ChartDataModel(
        dataPoints: const [],
        trendLine: const [],
        xAxisDates: const [],
        xAxisLabels: const [],
        visibleLabelIndices: const {},
        minY: 0,
        maxY: 100,
        yStep: 20,
        yTicks: const [],
      );
    }

    final trendLine = _calculateTrendLine(dataPoints);
    final xAxisLabels = _generateXAxisLabels(xAxisDates, localeCode);
    final visibleLabelIndices = _selectVisibleLabels(xAxisLabels.length);
    final yAxisData = _calculateYAxis(dataPoints, goalWeight);
    final metrics = _calculateMetrics(
      dataPoints: dataPoints,
      xAxisDates: xAxisDates,
      goalWeight: goalWeight,
      byDays: config.byDays,
    );

    return ChartDataModel(
      dataPoints: dataPoints,
      trendLine: trendLine,
      xAxisDates: xAxisDates,
      xAxisLabels: xAxisLabels,
      visibleLabelIndices: visibleLabelIndices,
      minY: yAxisData.minY,
      maxY: yAxisData.maxY,
      yStep: yAxisData.yStep,
      yTicks: yAxisData.yTicks,
      goalWeight: goalWeight,
      metrics: metrics,
    );
  }

  static _ProcessedData _processByEntries(List<WeightEntry> entries, int days) {
    final sorted = List<WeightEntry>.from(entries)
      ..sort((a, b) => a.entryDate.compareTo(b.entryDate));

    final takeAll = days == 0;
    final recent = takeAll ? sorted : sorted.take(days).toList();

    final spots = <FlSpot>[];
    final dates = <DateTime>[];

    for (int i = 0; i < recent.length; i++) {
      spots.add(FlSpot(i.toDouble(), recent[i].weightKg));
      dates.add(recent[i].entryDate);
    }

    return _ProcessedData(spots: spots, dates: dates);
  }

  static _ProcessedData _processByDays(List<WeightEntry> entries, int days) {
    final takeAll = days == 0;

    DateTime start;
    DateTime end;

    if (takeAll) {
      DateTime earliest = DateTime.now();
      DateTime latest = DateTime(1900);
      for (final e in entries) {
        if (e.entryDate.isBefore(earliest)) earliest = e.entryDate;
        if (e.entryDate.isAfter(latest)) latest = e.entryDate;
      }
      start = DateTime(earliest.year, earliest.month, earliest.day);
      end = DateTime.now();
    } else {
      DateTime latest = DateTime.now();
      for (final e in entries) {
        if (e.entryDate.isAfter(latest)) latest = e.entryDate;
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

    final sorted = List<WeightEntry>.from(entries)
      ..sort((a, b) => a.entryDate.compareTo(b.entryDate));

    for (final e in sorted) {
      final key = DateTime(e.entryDate.year, e.entryDate.month, e.entryDate.day);
      if (map.containsKey(key)) {
        map[key] = e.weightKg;
      }
    }

    final spots = <FlSpot>[];
    final dates = <DateTime>[];
    int idx = 0;
    double? last;

    for (final v in map.values) {
      if (v != null) last = v;
      if (last != null) {
        spots.add(FlSpot(idx.toDouble(), last));
      }
      dates.add(DateTime(start.year, start.month, start.day).add(Duration(days: idx)));
      idx++;
    }

    return _ProcessedData(spots: spots, dates: dates);
  }

  static List<FlSpot> _calculateTrendLine(List<FlSpot> dataPoints) {
    if (dataPoints.length < 2) return [];

    final n = dataPoints.length;
    final sumX = dataPoints.fold<double>(0, (s, p) => s + p.x);
    final sumY = dataPoints.fold<double>(0, (s, p) => s + p.y);
    final sumXX = dataPoints.fold<double>(0, (s, p) => s + p.x * p.x);
    final sumXY = dataPoints.fold<double>(0, (s, p) => s + p.x * p.y);

    final denom = (n * sumXX - sumX * sumX);
    if (denom == 0) return [];

    final b = (n * sumXY - sumX * sumY) / denom;
    final a = (sumY - b * sumX) / n;

    return [
      FlSpot(dataPoints.first.x, a + b * dataPoints.first.x),
      FlSpot(dataPoints.last.x, a + b * dataPoints.last.x),
    ];
  }

  static List<String> _generateXAxisLabels(List<DateTime> dates, String localeCode) {
    return dates.map((d) {
      final dd = d.day.toString().padLeft(2, '0');
      final mm = d.month.toString().padLeft(2, '0');
      return '$dd/$mm';
    }).toList();
  }

  static Set<int> _selectVisibleLabels(int totalLabels) {
    const int desiredLabelCount = 7;
    final Set<int> labelIndices = <int>{};

    if (totalLabels <= desiredLabelCount) {
      for (int i = 0; i < totalLabels; i++) {
        labelIndices.add(i);
      }
    } else {
      for (int k = 0; k < desiredLabelCount; k++) {
        final double pos = k * (totalLabels - 1) / (desiredLabelCount - 1);
        labelIndices.add(pos.round());
      }
    }

    return labelIndices;
  }

  static _YAxisData _calculateYAxis(List<FlSpot> dataPoints, double? goalWeight) {
    double minYRaw = dataPoints.first.y;
    double maxYRaw = dataPoints.first.y;

    for (final s in dataPoints) {
      if (s.y < minYRaw) minYRaw = s.y;
      if (s.y > maxYRaw) maxYRaw = s.y;
    }

    if (goalWeight != null) {
      if (goalWeight < minYRaw) minYRaw = goalWeight;
      if (goalWeight > maxYRaw) maxYRaw = goalWeight;
    }

    double minY = (minYRaw / 5).floor() * 5;
    double maxY = (maxYRaw / 5).ceil() * 5;

    if (minY == maxY) {
      minY -= 5;
      maxY += 5;
    }

    const int yTickCount = 5;
    final double yStep = (maxY - minY) / (yTickCount - 1);
    final List<double> yTicks = List<double>.generate(yTickCount, (i) => (minY + i * yStep));

    return _YAxisData(
      minY: minY,
      maxY: maxY,
      yStep: yStep,
      yTicks: yTicks,
    );
  }

  static ChartMetrics? _calculateMetrics({
    required List<FlSpot> dataPoints,
    required List<DateTime> xAxisDates,
    required double? goalWeight,
    required bool byDays,
  }) {
    if (goalWeight == null || dataPoints.isEmpty) return null;

    final lastWeight = dataPoints.last.y;
    final deltaToGoal = goalWeight - lastWeight;

    // Calcular slope
    final n = dataPoints.length;
    final sumX = dataPoints.fold<double>(0, (s, p) => s + p.x);
    final sumY = dataPoints.fold<double>(0, (s, p) => s + p.y);
    final sumXX = dataPoints.fold<double>(0, (s, p) => s + p.x * p.x);
    final sumXY = dataPoints.fold<double>(0, (s, p) => s + p.x * p.y);

    final denom = (n * sumXX - sumX * sumX);
    double? slope;
    if (denom != 0) {
      slope = (n * sumXY - sumX * sumY) / denom;
    }

    double? slopePerDay;
    if (slope != null) {
      double stepDays = 1;
      if (!byDays && xAxisDates.length >= 2) {
        final totalDays = (xAxisDates.last.difference(xAxisDates.first).inDays).abs();
        if (totalDays > 0) {
          stepDays = totalDays / (xAxisDates.length - 1);
        }
      }
      slopePerDay = slope * (1 / stepDays);
    } else {
      slopePerDay = 0;
    }

    // Calcular ETA
    int? etaDays;
    DateTime? etaDate;
    bool isMovingTowardGoal = false;

    if (slope != null && slope != 0) {
      if (deltaToGoal * slope > 0) {
        isMovingTowardGoal = true;
        double stepDays = 1;
        if (!byDays && xAxisDates.length >= 2) {
          final totalDays = (xAxisDates.last.difference(xAxisDates.first).inDays).abs();
          if (totalDays > 0) {
            stepDays = totalDays / (xAxisDates.length - 1);
          }
        }
        final estSteps = deltaToGoal / slope;
        final estDays = estSteps * stepDays;
        if (estDays >= 0 && estDays.isFinite) {
          etaDays = estDays.round();
          final now = DateTime.now();
          etaDate = DateTime(now.year, now.month, now.day).add(Duration(days: etaDays));
        }
      }
    }

    // Calcular média por dia
    double? averagePerDay;
    if (xAxisDates.isNotEmpty) {
      final spanDays = (xAxisDates.last.difference(xAxisDates.first).inDays).abs();
      if (spanDays > 0) {
        averagePerDay = (dataPoints.last.y - dataPoints.first.y) / spanDays;
      } else {
        averagePerDay = 0;
      }
    }

    return ChartMetrics(
      deltaToGoal: deltaToGoal,
      slopePerDay: slopePerDay,
      etaDays: etaDays,
      etaDate: etaDate,
      averagePerDay: averagePerDay,
      isMovingTowardGoal: isMovingTowardGoal,
    );
  }
}

class _ProcessedData {
  final List<FlSpot> spots;
  final List<DateTime> dates;

  _ProcessedData({required this.spots, required this.dates});
}

class _YAxisData {
  final double minY;
  final double maxY;
  final double yStep;
  final List<double> yTicks;

  _YAxisData({
    required this.minY,
    required this.maxY,
    required this.yStep,
    required this.yTicks,
  });
}
