import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

const _themeModeKey = 'theme_mode';
const _accentColorKey = 'accent_color';

class ThemeSettings {
  const ThemeSettings({
    this.mode = ThemeMode.system,
    this.seedColor = const Color(0xFF3F51B5),
  });

  final ThemeMode mode;
  final Color seedColor;

  ThemeSettings copyWith({ThemeMode? mode, Color? seedColor}) {
    return ThemeSettings(
      mode: mode ?? this.mode,
      seedColor: seedColor ?? this.seedColor,
    );
  }
}

class ThemeController extends AsyncNotifier<ThemeSettings> {
  ThemeController();

  @override
  Future<ThemeSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(_themeModeKey);
    final accentValue = prefs.getInt(_accentColorKey);

    final mode = _resolveModeFromIndex(modeIndex);
    final seedColor = accentValue != null ? Color(accentValue) : kPresetAccentColors.first;

    return ThemeSettings(mode: mode, seedColor: seedColor);
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    final current = state.value ?? const ThemeSettings();
    state = AsyncValue.data(current.copyWith(mode: mode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  Future<void> updateSeedColor(Color color) async {
    final current = state.value ?? const ThemeSettings();
    state = AsyncValue.data(current.copyWith(seedColor: color));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentColorKey, color.value);
  }

  ThemeMode _resolveModeFromIndex(int? index) {
    if (index == null) {
      return ThemeMode.system;
    }
    if (index < 0 || index >= ThemeMode.values.length) {
      return ThemeMode.system;
    }
    return ThemeMode.values[index];
  }
}

final themeControllerProvider = AsyncNotifierProvider<ThemeController, ThemeSettings>(ThemeController.new);
