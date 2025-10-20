import 'package:drift/drift.dart';

class ReminderConfigs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get hour => integer()();
  IntColumn get minute => integer()();
  TextColumn get activeDays => text()(); // JSON encoded list of weekday indexes
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastTriggeredAt => dateTime().nullable()();
}
