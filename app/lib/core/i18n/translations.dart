import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _translations = <String, Map<String, String>>{
  'en': {
    'appTitle': 'Pesândinho',
    'dashboardTitle': 'Pesândinho',
    'historyTitle': 'History',
    'settingsTitle': 'Settings',
    'logWeight': 'Log Weight',
    'latestWeight': 'Latest Weight',
    'trend': 'Trend',
    'goalProgress': 'Goal Progress',
    'dailyReminderTime': 'Daily reminder time',
    'schedule': 'Schedule',
    'cancel': 'Cancel',
    'logWeightTitle': 'Log Weight',
    'weightKg': 'Weight (kg)',
    'date': 'Date',
    'pick': 'Pick',
    'noteOptional': 'Note (optional)',
    'save': 'Save',
    'weightSaved': 'Weight saved',
    'enterValidWeight': 'Enter a valid weight (e.g., 72.5)',
  },
  'pt': {
    'appTitle': 'Pesândinho',
    'dashboardTitle': 'Pesândinho',
    'historyTitle': 'Histórico',
    'settingsTitle': 'Configurações',
    'logWeight': 'Registrar Peso',
    'latestWeight': 'Último Peso',
    'trend': 'Tendência',
    'goalProgress': 'Progresso da Meta',
    'dailyReminderTime': 'Horário do lembrete diário',
    'schedule': 'Agendar',
    'cancel': 'Cancelar',
    'logWeightTitle': 'Registrar Peso',
    'weightKg': 'Peso (kg)',
    'date': 'Data',
    'pick': 'Escolher',
    'noteOptional': 'Observação (opcional)',
    'save': 'Salvar',
    'weightSaved': 'Peso salvo',
    'enterValidWeight': 'Digite um peso válido (ex.: 72,5)',
  },
};

class I18nController extends AsyncNotifier<Locale> {
  static const _key = 'locale_code';

  @override
  Future<Locale> build() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'en';
    return Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    state = AsyncValue.data(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }
}

final i18nControllerProvider = AsyncNotifierProvider<I18nController, Locale>(I18nController.new);

String tr(WidgetRef ref, String key) {
  final locale = ref.watch(i18nControllerProvider).value ?? const Locale('en');
  return _translations[locale.languageCode]?[key] ?? key;
}

