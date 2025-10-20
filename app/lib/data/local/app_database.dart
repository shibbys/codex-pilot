import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tables/goals_table.dart';
import 'tables/reminder_configs_table.dart';
import 'tables/theme_prefs_table.dart';
import 'tables/weight_entries_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [WeightEntries, Goals, ReminderConfigs, ThemePrefs],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final executor = await DriftFlutter.openConnection(name: 'daily_weight_tracker.db');
    return executor;
  });
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});
