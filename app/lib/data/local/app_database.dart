import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart' as drift_native;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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

  // Weight entries API
  Future<int> addWeightEntry({
    required DateTime date,
    required double weightKg,
    String? note,
  }) {
    return into(weightEntries).insert(
      WeightEntriesCompanion.insert(
        entryDate: date,
        weightKg: weightKg,
        note: Value(note),
      ),
    );
  }

  Stream<dynamic> watchLatestEntry() {
    final query = (select(weightEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.entryDate)])
          ..limit(1))
        .watchSingleOrNull();
    return query;
  }

  Stream<List<dynamic>> watchAllEntries() {
    return (select(weightEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.entryDate)]))
        .watch();
  }

  // Goals API
  Future<int> addGoal({
    required double targetWeightKg,
    DateTime? targetDate,
    String? note,
  }) {
    return into(goals).insert(
      GoalsCompanion.insert(
        targetWeightKg: targetWeightKg,
        targetDate: Value(targetDate),
        note: Value(note),
      ),
    );
  }

  Stream<dynamic> watchCurrentGoal() {
    return (select(goals)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .watchSingleOrNull();
  }

  Stream<List<dynamic>> watchAllGoals() {
    return (select(goals)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String dbPath = p.join(dir.path, 'daily_weight_tracker.db');
    final executor = drift_native.NativeDatabase(File(dbPath));
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
