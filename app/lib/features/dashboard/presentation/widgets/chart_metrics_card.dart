import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/chart_data_model.dart';
import '../../../../core/i18n/translations.dart';

class ChartMetricsCard extends ConsumerWidget {
  const ChartMetricsCard({
    required this.metrics,
    super.key,
  });

  final ChartMetrics metrics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = ref.watch(i18nControllerProvider).valueOrNull ?? const Locale('en');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Distância até a meta
            Row(
              children: [
                Icon(
                  metrics.deltaToGoal >= 0 ? Icons.north_east : Icons.south_east,
                  size: 16,
                  color: theme.colorScheme.onSurface,
                ),
                const SizedBox(width: 8),
                Text(
                  '${metrics.deltaToGoal.abs().toStringAsFixed(1)} kg ${tr(ref, 'toGoal')}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Tendência
            Row(
              children: [
                const Icon(Icons.trending_up, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${tr(ref, 'trend')}: ${metrics.slopePerDay.toStringAsFixed(2)} kg/${tr(ref, 'daysShort')}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 6),

            // ETA
            if (metrics.etaDays != null && metrics.etaDate != null)
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16),
                  const SizedBox(width: 8),
                  Builder(
                    builder: (_) {
                      final dd = DateFormat('dd', locale.languageCode).format(metrics.etaDate!);
                      var mon = DateFormat('MMM', locale.languageCode)
                          .format(metrics.etaDate!)
                          .replaceAll('.', '')
                          .toLowerCase();
                      final yy = DateFormat('yy', locale.languageCode).format(metrics.etaDate!);
                      final etaStr = '$dd/$mon/$yy';
                      return Text(
                        '${tr(ref, 'eta')} ~ ${metrics.etaDays}${tr(ref, 'daysShort')} (${tr(ref, 'byApprox')} $etaStr)',
                        style: theme.textTheme.bodyMedium,
                      );
                    },
                  ),
                ],
              )
            else if (!metrics.isMovingTowardGoal && metrics.slopePerDay != 0)
              Text(tr(ref, 'movingAway'), style: theme.textTheme.bodyMedium)
            else
              const SizedBox.shrink(),

            // Média por dia
            if (metrics.averagePerDay != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.speed, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '${tr(ref, 'average')}: ${metrics.averagePerDay!.toStringAsFixed(2)} kg/${tr(ref, 'daysShort')}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
