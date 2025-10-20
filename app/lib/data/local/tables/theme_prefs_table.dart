import 'package:drift/drift.dart';

class ThemePrefs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get themeMode => integer().withDefault(const Constant(0))();
  IntColumn get seedColorValue => integer().withDefault(const Constant(0xFF3F51B5))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
