import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/chart_controller.dart';
import '../../../../core/i18n/translations.dart';

class ChartControls extends ConsumerWidget {
  const ChartControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(chartConfigProvider);

    return Row(
      children: [
        ChoiceChip(
          label: const Text('7'),
          selected: config.days == 7,
          onSelected: (_) => ref.setChartDays(7),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('15'),
          selected: config.days == 15,
          onSelected: (_) => ref.setChartDays(15),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('30'),
          selected: config.days == 30,
          onSelected: (_) => ref.setChartDays(30),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: Text(tr(ref, 'all')),
          selected: config.days == 0,
          onSelected: (_) => ref.setChartDays(0),
        ),
        const Spacer(),
        Tooltip(
          message: config.byDays ? tr(ref, 'days') : tr(ref, 'entries'),
          child: FilterChip(
            label: Icon(config.byDays ? Icons.calendar_today : Icons.view_list),
            selected: config.byDays,
            onSelected: (_) => ref.toggleChartMode(),
            showCheckmark: false,
          ),
        ),
      ],
    );
  }
}
