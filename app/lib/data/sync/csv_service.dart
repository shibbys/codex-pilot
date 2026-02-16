import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:csv/csv.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';

import '../local/app_database.dart';
import '../../core/services/user_height_service.dart';

class CsvService {
  CsvService(this._db, this._heightService);

  final AppDatabase _db;
  final UserHeightService _heightService;

  /// Export all weight entries to a CSV file with the name pattern:
  ///   `<User_First_name>.peso.<yyyy>.<MM>.<dd>.csv`
  /// Returns the created file.
  /// 
  /// CSV Format:
  /// # height_cm,175
  /// date,weightKg,note
  /// 2024-01-01,75.5,Feeling good
  Future<File> exportEntries({String userFirstName = 'User'}) async {
    if (kIsWeb) {
      throw UnsupportedError('CSV export is not supported on web.');
    }
    final rows = await _db.select(_db.weightEntries).get();
    rows.sort((a, b) => a.entryDate.compareTo(b.entryDate));

    final data = <List<dynamic>>[];
    
    // Add height metadata if available
    final height = await _heightService.getHeight();
    if (height != null) {
      data.add(<dynamic>['# height_cm', height]);
    }
    
    // Add header
    data.add(<String>['date', 'weightKg', 'note']);
    
    // Add entries
    for (final r in rows) {
      final d = r.entryDate;
      final dateStr = '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      data.add(<dynamic>[dateStr, r.weightKg, r.note ?? '']);
    }

    final csv = const ListToCsvConverter().convert(data);

    // Sanitize first name for filename (letters/digits/hyphen/underscore/apostrophe)
    final fn = userFirstName.trim().replaceAll(RegExp(r"[^A-Za-z0-9_\-']"), '_');
    final now = DateTime.now();
    final filename = '${fn.isEmpty ? 'User' : fn}.peso.${now.year.toString().padLeft(4, '0')}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}.csv';

    Directory baseDir;
    if (Platform.isAndroid) {
      // App-specific external storage; no special permission required.
      baseDir = (await getExternalStorageDirectory()) ?? await getApplicationDocumentsDirectory();
    } else if (Platform.isIOS || Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      baseDir = await getApplicationDocumentsDirectory();
    } else {
      baseDir = await getTemporaryDirectory();
    }

    final file = File(p.join(baseDir.path, filename));
    await file.writeAsString(csv, encoding: utf8);
    return file;
  }

  /// Import entries from a CSV file. Accepts a File directly.
  /// Returns number of rows imported/updated.
  /// 
  /// Supports CSV format with optional height metadata:
  /// # height_cm,175
  /// date,weightKg,note
  /// 2024-01-01,75.5,Feeling good
  Future<int> importEntries(File file) async {
    if (kIsWeb) {
      throw UnsupportedError('CSV import is not supported on web.');
    }
    if (!await file.exists()) return 0;
    final raw = await file.readAsString(encoding: utf8);
    final rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false).convert(raw);
    int imported = 0;
    int startIndex = 0;

    // Check for metadata and header
    for (int i = 0; i < rows.length; i++) {
      final r = rows[i];
      if (r.isEmpty) continue;
      
      final firstCol = r[0]?.toString().trim() ?? '';
      
      // Check for height metadata
      if (firstCol == '# height_cm' && r.length > 1) {
        final heightStr = r[1]?.toString().trim();
        final height = double.tryParse(heightStr?.replaceAll(',', '.') ?? '');
        if (height != null && height > 0 && height < 300) {
          await _heightService.setHeight(height);
        }
        continue;
      }
      
      // Check for header row
      if (firstCol.toLowerCase().contains('date')) {
        startIndex = i + 1;
        break;
      }
      
      // If no header found and this looks like a date, start here
      if (_parseDate(firstCol) != null) {
        startIndex = i;
        break;
      }
    }

    await _db.transaction(() async {
      for (int i = startIndex; i < rows.length; i++) {
        final r = rows[i];
        if (r.isEmpty) continue;
        
        final dateStr = r[0]?.toString().trim();
        final weightStr = (r.length > 1 ? r[1] : null)?.toString().trim();
        final noteStr = (r.length > 2 ? r[2] : null)?.toString();
        
        if (dateStr == null || dateStr.isEmpty || weightStr == null || weightStr.isEmpty) continue;
        
        final date = _parseDate(dateStr);
        final weight = double.tryParse(weightStr.replaceAll(',', '.'));
        if (date == null || weight == null) continue;

        final normalized = DateTime(date.year, date.month, date.day);
        
        // Upsert by day
        final existing = await (_db.select(_db.weightEntries)..where((t) => t.entryDate.equals(normalized))).getSingleOrNull();
        if (existing == null) {
          await _db.into(_db.weightEntries).insert(WeightEntriesCompanion.insert(
                entryDate: normalized,
                weightKg: weight,
                note: Value(noteStr?.trim().isEmpty == true ? null : noteStr?.trim()),
              ));
        } else {
          await (_db.update(_db.weightEntries)..where((t) => t.id.equals(existing.id))).write(
            WeightEntriesCompanion(
              weightKg: Value(weight),
              note: Value(noteStr?.trim().isEmpty == true ? null : noteStr?.trim()),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
        imported++;
      }
    });

    return imported;
  }

  /// Opens a file picker to select a CSV and imports it.
  Future<int> pickAndImport() async {
    if (kIsWeb) {
      throw UnsupportedError('CSV import is not supported on web.');
    }
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return 0;
    final path = result.files.single.path;
    if (path == null) return 0;
    final file = File(path);
    return importEntries(file);
  }

  DateTime? _parseDate(String s) {
    final str = s.trim();
    // Prefer ISO-like patterns: yyyy-MM-dd, yyyy/MM/dd, yyyy.MM.dd
    final isoLike = RegExp(r'^(\d{4})[-\/.](\d{2})[-\/.](\d{2})$');
    final mIso = isoLike.firstMatch(str);
    if (mIso != null) {
      final y = int.parse(mIso.group(1)!);
      final mo = int.parse(mIso.group(2)!);
      final d = int.parse(mIso.group(3)!);
      return DateTime(y, mo, d);
    }

    // Handle locale-like: d/M/yyyy or M/d/yyyy with 1-2 digit day/month and 2-4 digit year
    final dm = RegExp(r'^(\d{1,2})[\-\/.](\d{1,2})[\-\/.](\d{2,4})$');
    final mDm = dm.firstMatch(str);
    if (mDm != null) {
      int a = int.parse(mDm.group(1)!);
      int b = int.parse(mDm.group(2)!);
      int y = int.parse(mDm.group(3)!);
      if (y < 100) y += 2000; // assume 20xx for two-digit years
      // Disambiguate: if first > 12, it's day-first; if second > 12, it's month-first; if both <= 12, assume day-first
      int day, month;
      if (a > 12 && b <= 12) {
        day = a;
        month = b;
      } else if (b > 12 && a <= 12) {
        day = b;
        month = a;
      } else {
        day = a;
        month = b; // default to dd/MM
      }
      return DateTime(y, month, day);
    }

    // Fallback
    try {
      return DateTime.parse(str);
    } catch (_) {
      return null;
    }
  }
}

final csvServiceProvider = Provider<CsvService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final heightService = ref.watch(userHeightServiceProvider);
  return CsvService(db, heightService);
});
