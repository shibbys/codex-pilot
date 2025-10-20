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

const List<Color> kPresetAccentColors = <Color>[
  Color(0xFF3F51B5),
  Color(0xFF009688),
  Color(0xFFFF7043),
  Color(0xFF26C6DA),
  Color(0xFF8E24AA),
];
