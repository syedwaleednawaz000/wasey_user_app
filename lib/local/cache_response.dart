import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
part 'cache_response.g.dart';

class CacheResponse extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get endPoint => text().unique()();
  TextColumn get header => text()();
  TextColumn get response => text()();
  TextColumn get moduleId => text().nullable()(); // Optional module ID for module-wise caching
}

@DriftDatabase(tables: [CacheResponse])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4; // Updated to support moduleId column

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Migration from version 3 to 4: Add moduleId column
      if (from < 4) {
        try {
          // Use raw SQL to add the column
          await customStatement('ALTER TABLE cache_response ADD COLUMN module_id TEXT');
        } catch (e) {
          // If adding column fails (e.g., column already exists), recreate the table
          try {
            await m.deleteTable('cache_response');
            await m.createTable(cacheResponse);
          } catch (_) {
            // Ignore errors if table recreation fails
          }
        }
      }
    },
    beforeOpen: (details) async {
      // Enable foreign keys if needed
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'cache_response_new_db');
  }

  Future<int> insertCacheResponse(CacheResponseCompanion entry) async {
    return await into(cacheResponse).insert(entry);
  }

  Future<List<CacheResponseData>> getAllCacheResponses() async {
    return await select(cacheResponse).get();
  }

  Future<CacheResponseData?> getCacheResponseById(String endPoint) async {
    return await (select(cacheResponse)..where((tbl) => tbl.endPoint.equals(endPoint)))
        .getSingleOrNull();
  }

  Future<List<CacheResponseData>> getCacheResponsesByModuleId(String moduleId) async {
    return await (select(cacheResponse)..where((tbl) => tbl.moduleId.equals(moduleId)))
        .get();
  }

  Future<int> updateCacheResponse(String endPoint, CacheResponseCompanion entry) async {
    return await (update(cacheResponse)..where((tbl) => tbl.endPoint.equals(endPoint)))
        .write(entry);
  }

  Future<int> deleteCacheResponse(int id) async {
    return await (delete(cacheResponse)..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  Future<int> clearCacheResponses() async {
    return await delete(cacheResponse).go();
  }
}