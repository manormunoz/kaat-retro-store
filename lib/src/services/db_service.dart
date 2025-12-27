import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yaml/yaml.dart';

class DbService {
  static final DbService _instance = DbService._internal();
  factory DbService() => _instance;
  static Database? _db;
  static bool _ffiInitialized = false;
  late final DatabaseFactory _databaseFactory;
  bool _isReady = false;
  bool get isReady => _isReady;

  DbService._internal() {
    _databaseFactory = _resolveDatabaseFactory();
  }

  DatabaseFactory _resolveDatabaseFactory() {
    if (_shouldUseFfi()) {
      if (!_ffiInitialized) {
        sqfliteFfiInit();
        _ffiInitialized = true;
      }
      return databaseFactoryFfi;
    }
    return databaseFactory;
  }

  bool _shouldUseFfi() {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.windows;
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    try {
      // Use application support directory for better cross-platform support
      String dbPath;
      if (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux) {
        final appSupportDir = await getApplicationSupportDirectory();
        dbPath = appSupportDir.path;
        debugPrint('📁 Database path (desktop): $dbPath');

        // Ensure directory exists
        final directory = Directory(dbPath);
        if (!await directory.exists()) {
          await directory.create(recursive: true);
          debugPrint('✅ Created database directory');
        }
      } else {
        dbPath = await _databaseFactory.getDatabasesPath();
        debugPrint('📁 Database path (mobile): $dbPath');
      }

      final path = join(dbPath, 'kaat_db.db');
      debugPrint('📄 Full database path: $path');

      final db = await _databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(version: 1, onCreate: _onCreate),
      );

      debugPrint('✅ Database opened successfully');
      // await dropTables(db);
      // await _onCreate(db, 1);
      // debugListTables(db);
      _isReady = true;
      return db;
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing database: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  List<Map<String, dynamic>> _decodeRoms(String jsonString) {
    final list = json.decode(jsonString) as List;
    return List<Map<String, dynamic>>.from(
        list.map((e) => Map<String, dynamic>.from(e as Map)));
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
    try {
      debugPrint('📥 Loading platforms from YAML...');
      final countResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM platforms',
      );
      final count = Sqflite.firstIntValue(countResult) ?? 0;
      debugPrint('📊 Current platforms count: $count');

      debugPrint('📄 Loading assets/config/platforms.yaml...');
      final yamlString = await rootBundle.loadString(
        'assets/config/platforms.yaml',
      );
      debugPrint('✅ YAML file loaded, size: ${yamlString.length} bytes');

      final yamlMap = loadYaml(yamlString);
      final yamlJson = json.decode(json.encode(yamlMap));
      final yamlList = Map<String, dynamic>.from(yamlJson);
      debugPrint('📋 Platforms in YAML: ${yamlList.length}');

      if (count == yamlList.length) {
        debugPrint("ℹ️ Platforms has data, not initialized");
        return;
      } else {
        await db.execute('DELETE FROM platforms');
        debugPrint('🗑️ Cleared existing platforms');
      }

      for (final item in yamlList.entries) {
        final platform = item.value as Map<String, dynamic>;
        await db.insert(
            'platforms',
            {
              'name': platform['platform_name'],
              'abbr': platform['platform_abbr'],
              'logo': platform['platform_logo'],
              'url': platform['url'],
              'boxarts': platform['roms_boxarts'],
              'romsLogos': platform['roms_logos'],
              'ssSystemId': platform['ssSystemId'],
            },
            conflictAlgorithm: ConflictAlgorithm.replace);
      }

      debugPrint("✅ Platforms initialized (${yamlList.length} items)");
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading platforms: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> loadMameRomsFromJson(Database db) async {
    try {
      debugPrint('📥 Loading MAME ROMs from JSON...');
      final mamePlarform = await db.rawQuery(
        'SELECT * FROM platforms WHERE abbr=?',
        ['mame'],
      );

      if (mamePlarform.isEmpty) {
        debugPrint('❌ MAME platform not found in database');
        return;
      }

      final platformId = mamePlarform.first['id'] as int;
      debugPrint('🎮 MAME platform ID: $platformId');

      final countResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM roms WHERE platformId=?',
        [platformId],
      );
      final count = Sqflite.firstIntValue(countResult) ?? 0;
      debugPrint('📊 Current MAME ROMs count: $count');

      if (count > 0) {
        debugPrint("ℹ️ Roms has data, not initialized");
        return;
      }

      debugPrint('📄 Loading assets/data/mame.json...');
      final jsonString = await rootBundle.loadString('assets/data/mame.json');
      debugPrint('✅ JSON file loaded, size: ${jsonString.length} bytes');

      // final List<dynamic> romsList = json.decode(jsonString);
      final romsList = await compute(_decodeRoms, jsonString);
      debugPrint('📋 MAME ROMs in JSON: ${romsList.length}');

      const chunk = 500;
      int i = 0;
      while (i < romsList.length) {
        final end = (i + chunk).clamp(0, romsList.length);
        final slice = romsList.sublist(i, end);
        debugPrint("✅ MAME roms initialized i: $i end: $end}");

        await db.transaction((txn) async {
          final batch = txn.batch();
          for (final rom in slice) {
            final romName = rom['rom']?.toString().trim();
            final title = rom['name']?.toString().trim();
            if (romName == null ||
                romName.isEmpty ||
                title == null ||
                title.isEmpty) {
              continue;
            }
            batch.insert(
                'roms',
                {
                  'rom': romName,
                  'title': title,
                  'year': rom['year'],
                  'publisher': rom['manufacturer'],
                  'platformId': platformId,
                },
                conflictAlgorithm: ConflictAlgorithm.ignore);
          }
          await batch.commit(noResult: true);
        });
        i = end;
        // cede el control al event loop para que iOS no sienta "freeze"
        await Future.delayed(const Duration(milliseconds: 1));
      }

      debugPrint("✅ MAME All roms initialized");
      final countAfterResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM roms WHERE platformId=?',
        [platformId],
      );
      final countAfter = Sqflite.firstIntValue(countAfterResult) ?? 0;
      debugPrint("${countAfter.toString()} MAME data roms inserted");
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading MAME ROMs: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
    // for (final rom in romsList) {
    //   final romName = rom['rom']?.toString().trim();
    //   final title = rom['name']?.toString().trim();

    //   if (romName == null ||
    //       romName.isEmpty ||
    //       title == null ||
    //       title.isEmpty) {
    //     continue;
    //   }

    //   // final exists = Sqflite.firstIntValue(
    //   //   await db.rawQuery(
    //   //     'SELECT COUNT(*) FROM roms WHERE rom = ? AND platformId = ?',
    //   //     [romName, platformId],
    //   //   ),
    //   // );

    //   // if (exists != null && exists > 0) {
    //   //   continue;
    //   // }

    //   await db.insert('roms', {
    //     'rom': romName,
    //     'title': title,
    //     // 'synopsis': rom['synopsis'],
    //     // 'date': rom['date'],
    //     'year': rom['year'],
    //     'publisher': rom['manufacturer'],
    //     // 'developer': rom['developer'],
    //     // 'rating': rom['rating'],
    //     'platformId': platformId,
    //   });
    //   debugPrint("✅ MAME rom initialized");
    // }
    // debugPrint("✅ MAME All roms initialized");
    // return;
  }

  Future<Map<String, dynamic>?> getPlatformByAbbr({
    required String abbr,
  }) async {
    final db = await database;
    final platformDb = await db.rawQuery(
      'SELECT * FROM platforms WHERE abbr=?',
      [abbr],
    );
    if (platformDb.isNotEmpty) {
      return platformDb.first as Map<String, dynamic>;
    }
    return platformDb.isNotEmpty
        ? platformDb.first as Map<String, dynamic>
        : null;
  }

  Future<Map<String, dynamic>?> getRom({
    required int platformId,
    required String rom,
  }) async {
    final db = await database;
    final romDb = await db.rawQuery(
      'SELECT * FROM roms WHERE platformId=? AND rom=?',
      [platformId, rom],
    );
    if (romDb.isNotEmpty) {
      return romDb.first as Map<String, dynamic>;
    }
    return romDb.isNotEmpty ? romDb.first as Map<String, dynamic> : null;
  }
}
