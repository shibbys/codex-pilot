import 'package:flutter/material.dart';

ThemeData buildLightTheme(Color seedColor) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.light),
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

ThemeData buildDarkTheme(Color seedColor) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.dark),
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

// Cores preset individuais (legacy - mantido para compatibilidade)
const List<Color> kPresetAccentColors = <Color>[
  Color(0xFF3F51B5),
  Color(0xFF009688),
  Color(0xFFFF7043),
  Color(0xFF26C6DA),
  Color(0xFF8E24AA),
];

// Temas Preset Completos
class ThemePreset {
  final String name;
  final String nameEn;
  final Color seedColor;
  final IconData icon;
  final String description;
  final String descriptionEn;

  const ThemePreset({
    required this.name,
    required this.nameEn,
    required this.seedColor,
    required this.icon,
    required this.description,
    required this.descriptionEn,
  });
}

const List<ThemePreset> kThemePresets = [
  ThemePreset(
    name: 'Oceano',
    nameEn: 'Ocean',
    seedColor: Color(0xFF0EA5E9),
    icon: Icons.water,
    description: 'Azul calmo e refrescante',
    descriptionEn: 'Calm and refreshing blue',
  ),
  ThemePreset(
    name: 'Floresta',
    nameEn: 'Forest',
    seedColor: Color(0xFF10B981),
    icon: Icons.forest,
    description: 'Verde natural e revigorante',
    descriptionEn: 'Natural and invigorating green',
  ),
  ThemePreset(
    name: 'Pôr do Sol',
    nameEn: 'Sunset',
    seedColor: Color(0xFFF59E0B),
    icon: Icons.wb_sunny,
    description: 'Laranja quente e energético',
    descriptionEn: 'Warm and energetic orange',
  ),
  ThemePreset(
    name: 'Lavanda',
    nameEn: 'Lavender',
    seedColor: Color(0xFF8B5CF6),
    icon: Icons.spa,
    description: 'Roxo suave e relaxante',
    descriptionEn: 'Soft and relaxing purple',
  ),
  ThemePreset(
    name: 'Rosa',
    nameEn: 'Rose',
    seedColor: Color(0xFFEC4899),
    icon: Icons.favorite,
    description: 'Rosa vibrante e motivador',
    descriptionEn: 'Vibrant and motivating pink',
  ),
  ThemePreset(
    name: 'Índigo',
    nameEn: 'Indigo',
    seedColor: Color(0xFF3F51B5),
    icon: Icons.nightlight,
    description: 'Azul profundo e focado',
    descriptionEn: 'Deep and focused blue',
  ),
  ThemePreset(
    name: 'Menta',
    nameEn: 'Mint',
    seedColor: Color(0xFF14B8A6),
    icon: Icons.ac_unit,
    description: 'Verde-água fresco',
    descriptionEn: 'Fresh aqua green',
  ),
  ThemePreset(
    name: 'Vermelho',
    nameEn: 'Red',
    seedColor: Color(0xFFEF4444),
    icon: Icons.local_fire_department,
    description: 'Vermelho intenso e poderoso',
    descriptionEn: 'Intense and powerful red',
  ),
];
