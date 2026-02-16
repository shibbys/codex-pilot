import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/local/app_database.dart';
import '../../../../core/i18n/translations.dart';

class StatisticsCard extends ConsumerWidget {
  const StatisticsCard({
    required this.entries,
    super.key,
  });

  final List<WeightEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final locale = ref.watch(i18nControllerProvider).valueOrNull ?? const Locale('en');
    final isPt = locale.languageCode == 'pt';
    final theme = Theme.of(context);

    // Calcular estatísticas
    final sorted = List<WeightEntry>.from(entries)
      ..sort((a, b) => a.entryDate.compareTo(b.entryDate));

    final firstWeight = sorted.first.weightKg;
    final currentWeight = sorted.last.weightKg;
    final totalChange = currentWeight - firstWeight;

    final minWeight = entries.map((e) => e.weightKg).reduce((a, b) => a < b ? a : b);
    final maxWeight = entries.map((e) => e.weightKg).reduce((a, b) => a > b ? a : b);

    // Calcular streak
    final streak = _calculateStreak(sorted);

    // Média dos últimos 7 dias
    final last7Days = sorted.length >= 7 ? sorted.sublist(sorted.length - 7) : sorted;
    final avg7Days = last7Days.map((e) => e.weightKg).reduce((a, b) => a + b) / last7Days.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  isPt ? 'Estatísticas' : 'Statistics',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Grid de estatísticas (2 colunas)
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.trending_down,
                    label: isPt ? 'Variação' : 'Change',
                    value: '${totalChange >= 0 ? '+' : ''}${totalChange.toStringAsFixed(1)} kg',
                    color: totalChange <= 0 ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatItem(
                    icon: Icons.arrow_downward,
                    label: isPt ? 'Mínimo' : 'Min',
                    value: '${minWeight.toStringAsFixed(1)} kg',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.arrow_upward,
                    label: isPt ? 'Máximo' : 'Max',
                    value: '${maxWeight.toStringAsFixed(1)} kg',
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatItem(
                    icon: Icons.local_fire_department,
                    label: isPt ? 'Streak' : 'Streak',
                    value: '$streak ${isPt ? 'd' : 'd'}',
                    color: streak >= 7 ? Colors.orange : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.calculate,
                    label: isPt ? 'Média 7d' : 'Avg 7d',
                    value: '${avg7Days.toStringAsFixed(1)} kg',
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatItem(
                    icon: Icons.format_list_numbered,
                    label: isPt ? 'Total' : 'Total',
                    value: '${entries.length}',
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _calculateStreak(List<WeightEntry> sortedEntries) {
    if (sortedEntries.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastEntry = sortedEntries.last.entryDate;
    final lastEntryDate = DateTime(lastEntry.year, lastEntry.month, lastEntry.day);

    final daysSinceLastEntry = today.difference(lastEntryDate).inDays;
    if (daysSinceLastEntry > 1) return 0;

    int streak = 0;
    DateTime checkDate = today;

    for (int i = sortedEntries.length - 1; i >= 0; i--) {
      final entry = sortedEntries[i];
      final entryDate = DateTime(
        entry.entryDate.year,
        entry.entryDate.month,
        entry.entryDate.day,
      );

      if (entryDate.isAtSameMomentAs(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (entryDate.isBefore(checkDate)) {
        break;
      }
    }

    return streak;
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.trending_up, color: color, size: 10),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
