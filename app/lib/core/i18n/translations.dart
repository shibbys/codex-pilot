import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _translations = <String, Map<String, String>>{
  'en': {
    'appTitle': 'Pesandínho',
    'dashboardTitle': 'Pesandínho',
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
    'shareCsv': 'Share CSV',
    'shareCsvSubtitle': 'Export and share the CSV file.',
    'importCsv': 'Import CSV',
    'importCsvSubtitle': 'Pick a CSV file and import entries.',
    'clearAllLogs': 'Clear All Logs',
    'clearAllLogsSubtitle': 'Permanently delete all weight entries.',
    'googleDriveSync': 'Google Drive Sync',
    'googleDriveSyncSubtitle': 'Connect your Drive account to sync entries.',
    'scheduledAt': 'Scheduled daily reminder at',
    'by': 'by',
    'days': 'Days',
    'entries': 'Entries',
    'all': 'All',
    'toGoal': 'to goal',
    'eta': 'ETA',
    'byApprox': 'by',
    'daysShort': 'd',
    'entriesShort': 'entries',
    'average': 'Average',
    'movingAway': 'moving away',
    'noDeadline': 'no deadline',
    'fullscreen': 'Full screen',
    'customColor': 'Custom Color',
    'reset': 'Reset',
    'done': 'Done',
  },
  'pt': {
    'appTitle': 'Pesandínho',
    'dashboardTitle': 'Pesandínho',
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
    'shareCsv': 'Compartilhar CSV',
    'shareCsvSubtitle': 'Exporta e compartilha o arquivo CSV.',
    'importCsv': 'Importar CSV',
    'importCsvSubtitle': 'Escolha um arquivo CSV para importar registros',
    'clearAllLogs': 'Limpar todos os registros',
    'clearAllLogsSubtitle': 'Apaga permanentemente todos os registros',
    'scheduledAt': 'Lembrete diário agendado às',
    'by': 'até',
    'days': 'Dias',
    'entries': 'Entradas',
    'all': 'Tudo',
    'toGoal': 'para a meta',
    'eta': 'Prev.',
    'byApprox': 'por volta de',
    'daysShort': 'd',
    'entriesShort': 'entradas',
    'average': 'Média',
    'movingAway': 'afastando da meta',
    'noDeadline': 'sem prazo',
    'fullscreen': 'Tela cheia',
    'customColor': 'Personalizado',
    'reset': 'Resetar',
    'done': 'Feito',
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



