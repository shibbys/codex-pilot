import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/i18n/translations.dart';

class ThemePresetsSection extends ConsumerWidget {
  const ThemePresetsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeControllerProvider).valueOrNull;
    final locale = ref.watch(i18nControllerProvider).valueOrNull ?? const Locale('en');
    final isPt = locale.languageCode == 'pt';
    
    if (themeSettings == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isPt ? 'Temas Prontos' : 'Theme Presets',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: kThemePresets.length,
          itemBuilder: (context, index) {
            final preset = kThemePresets[index];
            final isSelected = themeSettings.seedColor == preset.seedColor;
            
            return GestureDetector(
              onTap: () {
                ref.read(themeControllerProvider.notifier).updateSeedColor(preset.seedColor);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: preset.seedColor,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: preset.seedColor.withValues(alpha: 0.5),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      preset.icon,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPt ? preset.name : preset.nameEn,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 4),
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
