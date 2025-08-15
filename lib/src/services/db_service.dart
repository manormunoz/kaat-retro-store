import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

class DbService {
  static final DbService _instance = DbService._internal();
  factory DbService() => _instance;
  static Database? _db;

  DbService._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'kaat_db.db');
    final db = await openDatabase(path, version: 1, onCreate: _onCreate);
    // await dropTables(db);
    // await _onCreate(db, 1);
    // debugListTables(db);
    return db;
  }

  Future<void> debugListTables(Database db) async {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    debugPrint('📋 Tablas: $tables');
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS platforms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        abbr TEXT,
        logo TEXT,
        url TEXT,
        boxarts TEXT,
        romsLogos TEXT,
        ssSystemId INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE  IF NOT EXISTS roms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        rom TEXT NOT NULL,
        title TEXT NOT NULL,
        synopsis TEXT,
        date TEXT,
        year INTEGER,
        publisher TEXT,
        developer TEXT,
        rating REAL,
        platformId INTEGER NOT NULL,
        FOREIGN KEY (platformId) REFERENCES platforms (id) ON DELETE CASCADE
      )
    ''');

    await loadPlatformsFromYaml(db);
    await loadMameRomsFromJson(db);
  }

  Future<void> dropTables(Database db) async {
    await db.execute('DROP TABLE IF EXISTS platforms');
    await db.execute('DROP TABLE IF EXISTS roms');
    debugPrint("🗑 Db tables deleted");
  }

  Future<void> loadPlatformsFromYaml(Database db) async {
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM platforms',
    );
    final count = Sqflite.firstIntValue(countResult) ?? 0;

    if (count > 0) {
      debugPrint("ℹ️ Platforms has data, not initilezed");
      return;
    }

    final yamlString = await rootBundle.loadString(
      'assets/config/platforms.yaml',
    );

    final yamlMap = loadYaml(yamlString);
    final yamlJson = json.decode(json.encode(yamlMap));
    final yamlList = Map<String, dynamic>.from(yamlJson);
    for (final item in yamlList.entries) {
      final platform = item.value as Map<String, dynamic>;
      await db.insert('platforms', {
        'name': platform['platform_name'],
        'abbr': platform['platform_abbr'],
        'logo': platform['platform_logo'],
        'url': platform['url'],
        'boxarts': platform['roms_boxarts'],
        'romsLogos': platform['roms_logos'],
        'ssSystemId': platform['ssSystemId'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    debugPrint("✅ Platforms initialized");
  }

  Future<void> loadMameRomsFromJson(Database db) async {
    final mamePlarform = await db.rawQuery(
      'SELECT * FROM platforms WHERE abbr=?',
      ['mame'],
    );
    final platformId = mamePlarform.first['id'] as int;
    debugPrint(platformId.toString());
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM roms WHERE platformId=?',
      [platformId],
    );
    final count = Sqflite.firstIntValue(countResult) ?? 0;
    if (count > 0) {
      debugPrint("ℹ️ Roms has data, not initilized");
      return;
    }

    final jsonString = await rootBundle.loadString('assets/data/mame.json');
    final List<dynamic> romsList = json.decode(jsonString);

    for (final rom in romsList) {
      final romName = rom['rom']?.toString().trim();
      final title = rom['name']?.toString().trim();

      if (romName == null ||
          romName.isEmpty ||
          title == null ||
          title.isEmpty) {
        continue;
      }

      final exists = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM roms WHERE rom = ? AND platformId = ?',
          [romName, platformId],
        ),
      );

      if (exists != null && exists > 0) {
        continue;
      }

      await db.insert('roms', {
        'rom': romName,
        'title': title,
        // 'synopsis': rom['synopsis'],
        // 'date': rom['date'],
        'year': rom['year'],
        'publisher': rom['manufacturer'],
        // 'developer': rom['developer'],
        // 'rating': rom['rating'],
        'platformId': platformId,
      });
      debugPrint("✅ MAME roms initialized");
    }
  }
}
