import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/chart_controller.dart';
import 'widgets/chart_controls.dart';
import 'widgets/trend_chart_widget.dart';
import '../../../core/i18n/translations.dart';

class FullscreenChartPage extends ConsumerStatefulWidget {
  const FullscreenChartPage({super.key});

  @override
  ConsumerState<FullscreenChartPage> createState() => _FullscreenChartPageState();
}

class _FullscreenChartPageState extends ConsumerState<FullscreenChartPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chartDataAsync = ref.watch(chartDataProvider);

    return Scaffold(
      appBar: AppBar(title: Text(tr(ref, 'fullscreen'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              const ChartControls(),
              const SizedBox(height: 8),
              Expanded(
                child: chartDataAsync.when(
                  data: (chartData) {
                    if (chartData.isEmpty) {
                      return const Center(child: Text('-'));
                    }

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                                minWidth: constraints.maxWidth,
                              ),
                              child: TrendChartWidget(
                                chartData: chartData,
                                expandChart: true,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
