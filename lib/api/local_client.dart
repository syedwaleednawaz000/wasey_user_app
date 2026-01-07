
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:drift/drift.dart' as drift;
import 'package:sixam_mart/helper/db_helper.dart';
import 'package:sixam_mart/local/cache_response.dart';
import 'package:sixam_mart/api/module_cache_manager.dart';

class LocalClient {

  /// Generate a module-aware cache key
  /// Format: module_{moduleId}_{endpoint}
  static String generateModuleCacheKey(String endpoint, String? moduleId) {
    return ModuleCacheManager.generateModuleCacheKey(endpoint, moduleId);
  }

  static Future<String?> organize(DataSourceEnum source, String cacheId, String? responseBody, Map<String, String>? header) async {
    SharedPreferences sharedPreferences = Get.find();
    switch(source) {
      case DataSourceEnum.client:
        try{
          if (kDebugMode) {
            print('==========cache data : endpoint banner=$cacheId, \n'
              'header= ${header.toString()}, \n'
              'response= $responseBody');
          }

          if(GetPlatform.isWeb) {
            await sharedPreferences.setString(cacheId, responseBody??'');
          } else {
            DbHelper.insertOrUpdate(
              id: cacheId,
              data: CacheResponseCompanion(
                endPoint: drift.Value(cacheId),
                header: drift.Value(header.toString()),
                response: drift.Value(responseBody??''),
              ),
            );
          }
          
          // Track module cache keys if this is a module-aware cache key
          if (cacheId.startsWith('module_')) {
            final parts = cacheId.split('_');
            if (parts.length >= 2) {
              final moduleId = parts[1]; // Extract module ID from "module_{moduleId}_{endpoint}"
              final existingKeys = sharedPreferences.getStringList('module_cache_keys_$moduleId') ?? [];
              if (!existingKeys.contains(cacheId)) {
                existingKeys.add(cacheId);
                await sharedPreferences.setStringList('module_cache_keys_$moduleId', existingKeys);
              }
            }
          }
        } catch(e) {
          if (kDebugMode) {
            print('=====error occur in repo api banner add: $e');
          }
        }
      case DataSourceEnum.local:
        try {
          if(GetPlatform.isWeb) {
            String? cacheData = sharedPreferences.getString(cacheId);
            return cacheData;
          } else {
            final CacheResponseData? cacheResponseData = await database.getCacheResponseById(cacheId);
            return cacheResponseData?.response;
          }

        } catch (e) {
          if (kDebugMode) {
            print('=====error occur in repo local banner: $e');
          }
        }
    }
    return null;
  }
}