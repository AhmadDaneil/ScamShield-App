// lib/services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/scan_result.dart';

class DatabaseService {
  static Database? _db;
  static const String _tableName = 'scan_history';

  Future<void> init() async {
    if (_db != null) return;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'scamshield.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            text TEXT NOT NULL,
            isFake INTEGER NOT NULL,
            confidence REAL NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> insertScan(ScanResult result) async {
    await _db?.insert(
      _tableName,
      result.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ScanResult>> getAllScans() async {
    final maps = await _db?.query(
      _tableName,
      orderBy: 'timestamp DESC',
    );

    if (maps == null || maps.isEmpty) return [];

    return maps.map((m) => ScanResult.fromMap(m)).toList();
  }

  Future<void> deleteScan(String id) async {
    await _db?.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllScans() async {
    await _db?.delete(_tableName);
  }
}