import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/helper/db_helper.dart';
import 'package:sixam_mart/local/cache_response.dart';
import 'package:drift/drift.dart' as drift;

class ModuleCacheManager {
  static const String _cacheTimestampPrefix = 'module_cache_timestamp_';
  static const String _cacheKeysPrefix = 'module_cache_keys_';
  static const int _cacheValidityMinutes = 10; // Cache expires after 10 minutes

  /// Generate a module-aware cache key
  static String generateModuleCacheKey(String endpoint, String? moduleId) {
    if (moduleId != null && moduleId.isNotEmpty) {
      return 'module_${moduleId}_$endpoint';
    }
    return endpoint;
  }

  /// Save all API responses for a module
  static Future<void> saveModuleCache(
    String moduleId,
    Map<String, String> apiResponses,
    Map<String, Map<String, String>>? headers,
  ) async {
    try {
      SharedPreferences sharedPreferences = Get.find();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // Save timestamp for cache validation
      await sharedPreferences.setInt(
        '$_cacheTimestampPrefix$moduleId',
        timestamp,
      );

      // Save all cache keys for this module
      final cacheKeys = apiResponses.keys.toList();
      await sharedPreferences.setStringList(
        '$_cacheKeysPrefix$moduleId',
        cacheKeys,
      );

      // Save each API response
      if (GetPlatform.isWeb) {
        // For web, use SharedPreferences
        for (var entry in apiResponses.entries) {
          await sharedPreferences.setString(entry.key, entry.value);
        }
      } else {
        // For mobile, use Drift database
        for (var entry in apiResponses.entries) {
          final header = headers?[entry.key]?.toString() ?? '';
          await DbHelper.insertOrUpdate(
            id: entry.key,
            data: CacheResponseCompanion(
              endPoint: drift.Value(entry.key),
              header: drift.Value(header),
              response: drift.Value(entry.value),
            ),
          );
        }
      }

      if (kDebugMode) {
        print('ModuleCacheManager: Saved cache for module $moduleId with ${apiResponses.length} endpoints');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ModuleCacheManager: Error saving module cache: $e');
      }
    }
  }

  /// Load all cached responses for a module
  static Future<Map<String, String>?> loadModuleCache(String moduleId) async {
    try {
      SharedPreferences sharedPreferences = Get.find();
      
      // Check if cache exists and is valid
      if (!await isModuleCacheValid(moduleId)) {
        if (kDebugMode) {
          print('ModuleCacheManager: Cache for module $moduleId is invalid or expired');
        }
        return null;
      }

      // Get all cache keys for this module
      final cacheKeys = sharedPreferences.getStringList('$_cacheKeysPrefix$moduleId');
      if (cacheKeys == null || cacheKeys.isEmpty) {
        if (kDebugMode) {
          print('ModuleCacheManager: No cache keys found for module $moduleId');
        }
        return null;
      }

      Map<String, String> cachedResponses = {};

      if (GetPlatform.isWeb) {
        // For web, load from SharedPreferences
        for (var key in cacheKeys) {
          final value = sharedPreferences.getString(key);
          if (value != null) {
            cachedResponses[key] = value;
          }
        }
      } else {
        // For mobile, load from Drift database
        for (var key in cacheKeys) {
          final cacheData = await database.getCacheResponseById(key);
          if (cacheData != null && cacheData.response != null) {
            cachedResponses[key] = cacheData.response!;
          }
        }
      }

      if (kDebugMode) {
        print('ModuleCacheManager: Loaded ${cachedResponses.length} cached responses for module $moduleId');
      }

      return cachedResponses.isNotEmpty ? cachedResponses : null;
    } catch (e) {
      if (kDebugMode) {
        print('ModuleCacheManager: Error loading module cache: $e');
      }
      return null;
    }
  }

  /// Check if module cache is valid (exists and not expired)
  static Future<bool> isModuleCacheValid(String moduleId) async {
    try {
      SharedPreferences sharedPreferences = Get.find();
      
      final timestamp = sharedPreferences.getInt('$_cacheTimestampPrefix$moduleId');
      if (timestamp == null) {
        return false;
      }

      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      final cacheAgeMinutes = cacheAge / (1000 * 60);

      return cacheAgeMinutes < _cacheValidityMinutes;
    } catch (e) {
      if (kDebugMode) {
        print('ModuleCacheManager: Error checking cache validity: $e');
      }
      return false;
    }
  }

  /// Clear cache for a specific module
  static Future<void> clearModuleCache(String moduleId) async {
    try {
      SharedPreferences sharedPreferences = Get.find();
      
      // Get all cache keys for this module
      final cacheKeys = sharedPreferences.getStringList('$_cacheKeysPrefix$moduleId');
      
      if (cacheKeys != null && cacheKeys.isNotEmpty) {
        if (GetPlatform.isWeb) {
          // For web, remove from SharedPreferences
          for (var key in cacheKeys) {
            await sharedPreferences.remove(key);
          }
        } else {
          // For mobile, remove from Drift database
          final allCacheResponses = await database.getAllCacheResponses();
          for (var cacheResponse in allCacheResponses) {
            if (cacheKeys.contains(cacheResponse.endPoint)) {
              await database.deleteCacheResponse(cacheResponse.id);
            }
          }
        }
      }

      // Remove metadata
      await sharedPreferences.remove('$_cacheTimestampPrefix$moduleId');
      await sharedPreferences.remove('$_cacheKeysPrefix$moduleId');

      if (kDebugMode) {
        print('ModuleCacheManager: Cleared cache for module $moduleId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ModuleCacheManager: Error clearing module cache: $e');
      }
    }
  }

  /// Get all cache keys for a module
  static Future<List<String>> getModuleCacheKeys(String moduleId) async {
    try {
      SharedPreferences sharedPreferences = Get.find();
      final cacheKeys = sharedPreferences.getStringList('$_cacheKeysPrefix$moduleId');
      return cacheKeys ?? [];
    } catch (e) {
      if (kDebugMode) {
        print('ModuleCacheManager: Error getting module cache keys: $e');
      }
      return [];
    }
  }

  /// Get cache timestamp for a module
  static Future<DateTime?> getModuleCacheTimestamp(String moduleId) async {
    try {
      SharedPreferences sharedPreferences = Get.find();
      final timestamp = sharedPreferences.getInt('$_cacheTimestampPrefix$moduleId');
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('ModuleCacheManager: Error getting cache timestamp: $e');
      }
      return null;
    }
  }
}

