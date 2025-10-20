import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/app_database.dart';

class CsvService {
  CsvService(this._db);

  // ignore: unused_field
  final AppDatabase _db;

  Future<File> exportEntries() async {
    throw UnimplementedError('CSV export will be implemented once database queries are ready.');
  }

  Future<void> importEntries(File file) async {
    throw UnimplementedError('CSV import will be implemented once database queries are ready.');
  }
}

final csvServiceProvider = Provider<CsvService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CsvService(db);
});
