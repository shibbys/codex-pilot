import 'package:drift/drift.dart';
import 'package:drift/native.dart' as drift_native;
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
    // In-memory database for analyzer/builds without platform paths.
    // Replace with a file-based NativeDatabase if persistence is required.
    final executor = drift_native.NativeDatabase.memory();
    return executor;
  });
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() {
    // Ensure the async close() is invoked explicitly.
    database.close();
  });
  return database;
});
