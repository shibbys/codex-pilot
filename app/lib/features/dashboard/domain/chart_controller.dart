import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chart_data_model.dart';
import 'chart_calculator.dart';
import '../../../data/local/app_database.dart';
import '../../../core/i18n/translations.dart';

/// Provider de configuração do gráfico (mutable)
final chartConfigProvider = StateProvider<ChartConfig>((ref) {
  return const ChartConfig(days: 7, byDays: false);
});

/// Provider que observa todas as entradas do banco
final _allEntriesProvider = StreamProvider<List<WeightEntry>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchAllEntries();
});

/// Provider que observa a meta atual
final _currentGoalProvider = StreamProvider<Goal?>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchCurrentGoal();
});

/// Provider principal: combina entries + goal + config para gerar ChartDataModel
final chartDataProvider = Provider<AsyncValue<ChartDataModel>>((ref) {
  final entriesAsync = ref.watch(_allEntriesProvider);
  final goalAsync = ref.watch(_currentGoalProvider);
  final config = ref.watch(chartConfigProvider);
  final locale = ref.watch(i18nControllerProvider).valueOrNull ?? const Locale('en');

  // Se qualquer um estiver loading, retorna loading
  if (entriesAsync.isLoading || goalAsync.isLoading) {
    return const AsyncValue.loading();
  }

  // Se houver erro, retorna erro
  if (entriesAsync.hasError) {
    return AsyncValue.error(entriesAsync.error!, entriesAsync.stackTrace!);
  }
  if (goalAsync.hasError) {
    return AsyncValue.error(goalAsync.error!, goalAsync.stackTrace!);
  }

  // Extrair dados
  final entries = entriesAsync.value ?? [];
  final goal = goalAsync.value;

  // Calcular model
  final chartData = ChartCalculator.calculate(
    entries: entries,
    config: config,
    localeCode: locale.languageCode,
    goalWeight: goal?.targetWeightKg,
  );

  return AsyncValue.data(chartData);
});

/// Helpers para modificar configuração
extension ChartConfigHelper on WidgetRef {
  void setChartDays(int days) {
    final current = read(chartConfigProvider);
    read(chartConfigProvider.notifier).state = current.copyWith(days: days);
  }

  void setChartByDays(bool byDays) {
    final current = read(chartConfigProvider);
    read(chartConfigProvider.notifier).state = current.copyWith(byDays: byDays);
  }

  void toggleChartMode() {
    final current = read(chartConfigProvider);
    read(chartConfigProvider.notifier).state = current.copyWith(byDays: !current.byDays);
  }
}
