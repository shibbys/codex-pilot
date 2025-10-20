import 'package:drift/drift.dart';

class WeightEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get entryDate => dateTime()();
  RealColumn get weightKg => real()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
