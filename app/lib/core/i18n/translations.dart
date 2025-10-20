import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _translations = <String, Map<String, String>>{
  'en': {
    'appTitle': 'Pesândinho',
    'dashboardTitle': 'Pesândinho',
    'historyTitle': 'History',
    'settingsTitle': 'Settings',
    'appearance': 'Appearance',
    'logWeight': 'Log Weight',
    'latestWeight': 'Latest Weight',
    'trend': 'Trend',
    'goalProgress': 'Goal Progress',
    'goal': 'Goal',
    'targetWeight': 'Target weight (kg)',
    'targetDate': 'Target date',
    'setNewGoal': 'Set New Goal',
    'note': 'Note',
    'language': 'Language',
    'remindersTitle': 'Reminders',
    'dailyReminderTime': 'Daily reminder time',
    'schedule': 'Schedule',
    'cancel': 'Cancel',
    'light': 'Light',
    'dark': 'Dark',
    'system': 'System',
    'home': 'Home',
    'history': 'History',
    'settings': 'Settings',
    'logWeightTitle': 'Log Weight',
    'weightKg': 'Weight (kg)',
    'date': 'Date',
    'pick': 'Pick',
    'noteOptional': 'Note (optional)',
    'save': 'Save',
    'weightSaved': 'Weight saved',
    'enterValidWeight': 'Enter a valid weight (e.g., 72.5)',
    'dataManagement': 'Data Management',
    'exportCsv': 'Export CSV',
    'exportCsvSubtitle': 'Exports all weight entries to a CSV file.',
    'googleDriveSync': 'Google Drive Sync',
    'googleDriveSyncSubtitle': 'Connect your Drive account to sync entries.',
    'scheduledAt': 'Scheduled daily reminder at',
    'by': 'by',
    'days': 'Days',
    'entries': 'Entries',
    'toGoal': 'to goal',
    'eta': 'ETA',
    'daysShort': 'd',
    'entriesShort': 'entries',
    'neededPerDay': 'needed/day',
    'movingAway': 'moving away',
    'noDeadline': 'no deadline',
    'fullscreen': 'Full screen',
  },
  'pt': {
    'appTitle': 'Pesândinho',
    'dashboardTitle': 'Pesândinho',
    'historyTitle': 'Histórico',
    'settingsTitle': 'Configurações',
    'appearance': 'Aparência',
    'logWeight': 'Registrar Peso',
    'latestWeight': 'Último Peso',
    'trend': 'Tendência',
    'goalProgress': 'Progresso da Meta',
    'goal': 'Meta',
    'targetWeight': 'Peso alvo (kg)',
    'targetDate': 'Data alvo',
    'setNewGoal': 'Definir nova meta',
    'note': 'Observação',
    'language': 'Idioma',
    'remindersTitle': 'Lembretes',
    'dailyReminderTime': 'Horário do lembrete diário',
    'schedule': 'Agendar',
    'cancel': 'Cancelar',
    'light': 'Claro',
    'dark': 'Escuro',
    'system': 'Sistema',
    'home': 'Início',
    'history': 'Histórico',
    'settings': 'Configurações',
    'logWeightTitle': 'Registrar Peso',
    'weightKg': 'Peso (kg)',
    'date': 'Data',
    'pick': 'Escolher',
    'noteOptional': 'Observação (opcional)',
    'save': 'Salvar',
    'weightSaved': 'Peso salvo',
    'enterValidWeight': 'Digite um peso válido (ex.: 72,5)',
    'dataManagement': 'Gerenciamento de Dados',
    'exportCsv': 'Exportar CSV',
    'exportCsvSubtitle': 'Exporta todas as entradas de peso para um arquivo CSV.',
    'googleDriveSync': 'Sincronizar com Google Drive',
    'googleDriveSyncSubtitle': 'Conecte sua conta do Drive para sincronizar entradas.',
    'scheduledAt': 'Lembrete diário agendado às',
    'by': 'até',
    'days': 'Dias',
    'entries': 'Entradas',
    'toGoal': 'para a meta',
    'eta': 'Prev.',
    'daysShort': 'd',
    'entriesShort': 'entradas',
    'neededPerDay': 'necessário/dia',
    'movingAway': 'afastando da meta',
    'noDeadline': 'sem prazo',
    'fullscreen': 'Tela cheia',
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
