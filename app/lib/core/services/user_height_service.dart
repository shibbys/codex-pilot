import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserHeightService {
  static const _heightKey = 'user_height_cm';

  Future<double?> getHeight() async {
    final prefs = await SharedPreferences.getInstance();
    final height = prefs.getDouble(_heightKey);
    return height;
  }

  Future<void> setHeight(double heightCm) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_heightKey, heightCm);
  }

  Future<void> clearHeight() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_heightKey);
  }

  /// Calcula IMC (kg/m²)
  static double calculateBMI(double weightKg, double heightCm) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Retorna categoria do IMC
  static String getBMICategory(double bmi, {bool isPt = false}) {
    if (bmi < 18.5) {
      return isPt ? 'Abaixo do peso' : 'Underweight';
    } else if (bmi < 25) {
      return isPt ? 'Peso normal' : 'Normal weight';
    } else if (bmi < 30) {
      return isPt ? 'Sobrepeso' : 'Overweight';
    } else {
      return isPt ? 'Obesidade' : 'Obesity';
    }
  }
}

final userHeightServiceProvider = Provider<UserHeightService>((ref) {
  return UserHeightService();
});

/// Provider para altura do usuário (stream simulado via Future)
final userHeightProvider = FutureProvider<double?>((ref) async {
  final service = ref.watch(userHeightServiceProvider);
  return await service.getHeight();
});
