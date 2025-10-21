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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await customStatement(
              'CREATE UNIQUE INDEX IF NOT EXISTS idx_weight_entries_single_day ON weight_entries(entry_date)');
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // Deduplicate any rows sharing the same entry_date, keep smallest id
            await customStatement(
                'DELETE FROM weight_entries WHERE id NOT IN (SELECT MIN(id) FROM weight_entries GROUP BY entry_date)');
            await customStatement(
                'CREATE UNIQUE INDEX IF NOT EXISTS idx_weight_entries_single_day ON weight_entries(entry_date)');
          }
        },
      );

  // Weight entries API
  Future<int> addWeightEntry({
    required DateTime date,
    required double weightKg,
    String? note,
  }) {
    // Normalize date to midnight to enforce single entry per day
    final normalized = DateTime(date.year, date.month, date.day);
    return into(weightEntries).insert(
      WeightEntriesCompanion.insert(
        entryDate: normalized,
        weightKg: weightKg,
        note: Value(note),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> updateWeightEntry({
    required int id,
    required DateTime date,
    required double weightKg,
    String? note,
  }) async {
    final normalized = DateTime(date.year, date.month, date.day);
    // If another row exists for the same day, remove it (keep the edited one)
    final conflict = await (select(weightEntries)
          ..where((t) => t.entryDate.equals(normalized) & t.id.isNotIn([id])))
        .getSingleOrNull();
    if (conflict != null) {
      await (delete(weightEntries)..where((t) => t.id.equals(conflict.id))).go();
    }
    await (update(weightEntries)..where((t) => t.id.equals(id))).write(
      WeightEntriesCompanion(
        entryDate: Value(normalized),
        weightKg: Value(weightKg),
        note: Value(note),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteWeightEntry(int id) async {
    await (delete(weightEntries)..where((t) => t.id.equals(id))).go();
  }

  Future<int> clearAllEntries() async {
    final deleted = await (delete(weightEntries)).go();
    await (delete(goals)).go();
    return deleted;
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
