import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/user_height_service.dart';
import '../../../../core/i18n/translations.dart';

class BMICard extends ConsumerWidget {
  const BMICard({
    required this.currentWeight,
    super.key,
  });

  final double currentWeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heightAsync = ref.watch(userHeightProvider);
    final locale = ref.watch(i18nControllerProvider).valueOrNull ?? const Locale('en');
    final isPt = locale.languageCode == 'pt';
    final theme = Theme.of(context);

    return heightAsync.when(
      data: (height) {
        if (height == null) {
          // Sem altura configurada
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.straighten,
                    size: 40,
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isPt
                        ? 'Configure sua altura em Settings para ver o IMC'
                        : 'Set your height in Settings to see BMI',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Calcular IMC
        final bmi = UserHeightService.calculateBMI(currentWeight, height);
        final category = UserHeightService.getBMICategory(bmi, isPt: isPt);

        // Cor baseada na categoria
        Color bmiColor;
        if (bmi < 18.5) {
          bmiColor = Colors.blue;
        } else if (bmi < 25) {
          bmiColor = Colors.green;
        } else if (bmi < 30) {
          bmiColor = Colors.orange;
        } else {
          bmiColor = Colors.red;
        }

        // Posição no indicador (18.5 a 35)
        final minBMI = 15.0;
        final maxBMI = 35.0;
        final normalizedBMI = ((bmi - minBMI) / (maxBMI - minBMI)).clamp(0.0, 1.0);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.monitor_weight, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'IMC / BMI',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: bmiColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        bmi.toStringAsFixed(1),
                        style: TextStyle(
                          color: bmiColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: bmiColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // Indicador visual
                Stack(
                  children: [
                    // Barra de fundo com gradiente
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue,
                            Colors.green,
                            Colors.orange,
                            Colors.red,
                          ],
                          stops: const [0.0, 0.35, 0.60, 1.0],
                        ),
                      ),
                    ),
                    // Indicador de posição
                    Positioned(
                      left: (MediaQuery.of(context).size.width - 64) * normalizedBMI - 6,
                      top: -4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: bmiColor,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '< 18.5',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      '18.5-25',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      '25-30',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      '> 30',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
