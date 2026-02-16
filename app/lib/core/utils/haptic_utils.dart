import 'package:flutter/services.dart';

/// Utility class for haptic feedback
class HapticUtils {
  /// Light impact - for selections, toggles
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium impact - for button presses
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact - for important actions (save, delete)
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection click - for switching between options
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// Vibrate - for errors or warnings
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }
}
