import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'widgets/summary_card.dart';
import 'widgets/goal_progress_card.dart';
import 'widgets/statistics_card.dart';
import 'widgets/bmi_card.dart';
import 'widgets/weight_trend_card.dart';

import '../../history/presentation/history_page.dart';
import '../../settings/presentation/settings_page.dart';
import '../../log_entry/presentation/log_entry_page.dart';
import '../../../data/local/app_database.dart';
import '../../../core/i18n/translations.dart';
import '../domain/chart_controller.dart';

/// Provider para última entrada
final latestEntryProvider = StreamProvider<WeightEntry?>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchLatestEntry();
});

/// Provider para meta atual
final currentGoalProvider = StreamProvider<Goal?>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchCurrentGoal();
});

/// Provider para todas as entries
final _allEntriesStreamProvider = StreamProvider<List<WeightEntry>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchAllEntries();
});

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  static const String routePath = '/dashboard';
  static const String routeName = 'dashboard';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestAsync = ref.watch(latestEntryProvider);
    final goalAsync = ref.watch(currentGoalProvider);
    final chartDataAsync = ref.watch(chartDataProvider);
    final allEntriesAsync = ref.watch(_allEntriesStreamProvider);
    final locale = ref.watch(i18nControllerProvider).valueOrNull ?? const Locale('en');

    // Processar latest weight
    final latestText = latestAsync.when(
      data: (entry) {
        if (entry == null) return '-- kg';
        return '${entry.weightKg.toStringAsFixed(1)} kg';
      },
      loading: () => '--',
      error: (_, __) => '--',
    );

    // Processar goal text
    final goalText = goalAsync.when(
      data: (goal) {
        if (goal == null) return tr(ref, 'goalProgress');
        
        final tgt = goal.targetWeightKg;
        final targetStr = tgt % 1 == 0 ? '${tgt.toInt()}kg' : '${tgt.toStringAsFixed(1)}kg';
        
        if (goal.targetDate != null) {
          final dd = DateFormat('dd', locale.languageCode).format(goal.targetDate!);
          var mon = DateFormat('MMM', locale.languageCode)
              .format(goal.targetDate!)
              .replaceAll('.', '');
          if (mon.isNotEmpty) mon = mon[0].toUpperCase() + mon.substring(1);
          final yy = DateFormat('yy', locale.languageCode).format(goal.targetDate!);
          return '$targetStr ${tr(ref, 'by')} $dd/$mon/$yy';
        } else {
          return targetStr;
        }
      },
      loading: () => '--',
      error: (_, __) => '--',
    );

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
          // Latest weight
          SummaryCard(
            title: tr(ref, 'latestWeight'),
            value: latestText,
          ),
          const SizedBox(height: 8),

          // Goal
          SummaryCard(
            title: tr(ref, 'goal'),
            value: goalText,
          ),
          const SizedBox(height: 8),

          // Goal Progress Card
          chartDataAsync.when(
            data: (chartData) {
              if (chartData.metrics != null && chartData.hasGoal) {
                final latestWeight = latestAsync.value?.weightKg;
                final allEntries = allEntriesAsync.value ?? [];
                
                if (latestWeight != null && allEntries.isNotEmpty) {
                  // Pegar o peso inicial (primeira entrada)
                  final sortedEntries = List<WeightEntry>.from(allEntries)
                    ..sort((a, b) => a.entryDate.compareTo(b.entryDate));
                  final initialWeight = sortedEntries.first.weightKg;
                  
                  return Column(
                    children: [
                      GoalProgressCard(
                        metrics: chartData.metrics!,
                        currentWeight: latestWeight,
                        goalWeight: chartData.goalWeight!,
                        initialWeight: initialWeight,
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                }
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          
          // Weight Trend Card  
          allEntriesAsync.when(
            data: (entries) {
              if (entries.length >= 2) {
                return Column(
                  children: [
                    WeightTrendCard(entries: entries),
                    const SizedBox(height: 8),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Statistics Card
          allEntriesAsync.when(
            data: (entries) {
              if (entries.isNotEmpty) {
                return Column(
                  children: [
                    StatisticsCard(entries: entries),
                    const SizedBox(height: 8),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // BMI Card
          latestAsync.when(
            data: (entry) {
              if (entry != null) {
                return BMICard(currentWeight: entry.weightKg);
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(LogEntryPage.routePath),
        tooltip: tr(ref, 'logWeight'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
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
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: tr(ref, 'home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: tr(ref, 'history'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: tr(ref, 'settings'),
          ),
        ],
      ),
    );
  }
}
