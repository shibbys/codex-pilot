import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/chart_data_model.dart';
import '../../../../core/i18n/translations.dart';

class GoalProgressCard extends ConsumerWidget {
  const GoalProgressCard({
    required this.metrics,
    required this.currentWeight,
    required this.goalWeight,
    required this.initialWeight,
    super.key,
  });

  final ChartMetrics metrics;
  final double currentWeight;
  final double goalWeight;
  final double initialWeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(i18nControllerProvider).valueOrNull ?? const Locale('en');
    final theme = Theme.of(context);
    final isPt = locale.languageCode == 'pt';

    // Calcular progresso corretamente
    final totalToLose = (initialWeight - goalWeight).abs();
    final alreadyLost = (initialWeight - currentWeight).abs();
    final progress = totalToLose > 0 ? (alreadyLost / totalToLose).clamp(0.0, 1.0) : 0.0;

    // Cores baseadas no progresso
    final progressColor = progress > 0.75
        ? Colors.green
        : progress > 0.5
            ? Colors.orange
            : theme.colorScheme.primary;

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              theme.colorScheme.secondaryContainer.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Row(
                children: [
                  Icon(
                    Icons.flag_rounded,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isPt ? 'Progresso da Meta' : 'Goal Progress',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Porcentagem
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: progressColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: progressColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Barra de progresso
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  tween: Tween(begin: 0.0, end: progress),
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      minHeight: 12,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(progressColor),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Informações
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Atual
                  _InfoColumn(
                    icon: Icons.person,
                    label: isPt ? 'Atual' : 'Current',
                    value: '${currentWeight.toStringAsFixed(1)} kg',
                    color: theme.colorScheme.onSurface,
                  ),
                  // Restante
                  _InfoColumn(
                    icon: Icons.trending_down,
                    label: isPt ? 'Restante' : 'Remaining',
                    value: '${metrics.deltaToGoal.abs().toStringAsFixed(1)} kg',
                    color: Colors.orange,
                  ),
                  // Meta
                  _InfoColumn(
                    icon: Icons.emoji_events,
                    label: isPt ? 'Meta' : 'Goal',
                    value: '${goalWeight.toStringAsFixed(1)} kg',
                    color: Colors.green,
                  ),
                ],
              ),

              // ETA se disponível
              if (metrics.etaDays != null && metrics.etaDate != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPt ? 'Previsão de Chegada' : 'Estimated Arrival',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatETA(metrics.etaDays!, metrics.etaDate!, locale),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else if (!metrics.isMovingTowardGoal && metrics.slopePerDay != 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.amber[700], size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isPt
                              ? 'Tendência se afastando da meta'
                              : 'Trend moving away from goal',
                          style: TextStyle(
                            color: Colors.amber[900],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatETA(int days, DateTime date, Locale locale) {
    final isPt = locale.languageCode == 'pt';
    final dd = DateFormat('dd', locale.languageCode).format(date);
    var mon = DateFormat('MMM', locale.languageCode).format(date).replaceAll('.', '');
    if (mon.isNotEmpty) mon = mon[0].toUpperCase() + mon.substring(1);
    final yy = DateFormat('yy', locale.languageCode).format(date);

    if (isPt) {
      return '~$days dias ($dd/$mon/$yy)';
    } else {
      return '~$days days ($dd/$mon/$yy)';
    }
  }
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({
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
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
    );
  }
}
