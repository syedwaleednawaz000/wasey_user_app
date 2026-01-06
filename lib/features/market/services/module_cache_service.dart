import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/api/module_cache_manager.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/features/banner/controllers/banner_controller.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/controllers/campaign_controller.dart';

class MarketModuleCacheService {
  static const String moduleId = AppConstants.superMarketModuleId; // Module ID: 1

  /// Check if Market cache is valid
  static Future<bool> isMarketCacheValid() async {
    return await ModuleCacheManager.isModuleCacheValid(moduleId);
  }

  /// Load cached Market data from local storage into controllers
  /// Uses DataSourceEnum.local to load from cache without making API calls
  static Future<bool> loadMarketCache() async {
    try {
      final cacheKeys = await ModuleCacheManager.getModuleCacheKeys(moduleId);
      
      if (cacheKeys.isEmpty) {
        if (kDebugMode) {
          print('MarketModuleCacheService: No cached data found');
        }
        return false;
      }

      if (kDebugMode) {
        print('MarketModuleCacheService: Loading ${cacheKeys.length} cached items from local storage');
      }

      // Load data from local cache into controllers
      // Using DataSourceEnum.local with localOnly=true ensures no API calls are made
      try {
        // Banner - has dataSource parameter, use local only with localOnly=true to prevent API call
        await Get.find<BannerController>().getBannerList(false, dataSource: DataSourceEnum.local, localOnly: true);
      } catch (e) {
        if (kDebugMode) print('MarketModuleCacheService: Banner load error: $e');
      }
      
      try {
        // Category - use localOnly=true to prevent API call, pass explicit moduleId
        await Get.find<CategoryController>().getCategoryList(false, allCategory: false, localOnly: true, moduleId: moduleId);
      } catch (e) {
        if (kDebugMode) print('MarketModuleCacheService: Category load error: $e');
      }
      
      try {
        // Popular stores - use localOnly=true to prevent API call
        await Get.find<StoreController>().getPopularStoreList(false, 'all', false, localOnly: true);
      } catch (e) {
        if (kDebugMode) print('MarketModuleCacheService: Popular stores load error: $e');
      }
      
      try {
        // Latest stores - use localOnly=true to prevent API call
        await Get.find<StoreController>().getLatestStoreList(false, 'all', false, localOnly: true);
      } catch (e) {
        if (kDebugMode) print('MarketModuleCacheService: Latest stores load error: $e');
      }
      
      try {
        // Store list - use localOnly=true to prevent API call
        await Get.find<StoreController>().getStoreList(1, false, localOnly: true);
      } catch (e) {
        if (kDebugMode) print('MarketModuleCacheService: Store list load error: $e');
      }
      
      try {
        // Popular items - use localOnly=true to prevent API call
        await Get.find<ItemController>().getPopularItemList(false, 'all', false, localOnly: true);
      } catch (e) {
        if (kDebugMode) print('MarketModuleCacheService: Popular items load error: $e');
      }
      
      try {
        // Campaign - use localOnly=true to prevent API call
        await Get.find<CampaignController>().getItemCampaignList(false, localOnly: true);
      } catch (e) {
        if (kDebugMode) print('MarketModuleCacheService: Campaign load error: $e');
      }

      if (kDebugMode) {
        print('MarketModuleCacheService: Successfully loaded Market data from cache');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('MarketModuleCacheService: Error loading Market cache: $e');
      }
      return false;
    }
  }

  /// Cache all Market screen API responses
  /// This should be called after all API calls are completed
  static Future<void> cacheMarketData() async {
    try {
      // The actual caching is done by individual repositories using LocalClient.organize()
      // This method just marks the cache as complete by updating the timestamp
      // Individual API responses are already cached with module-aware keys
      
      // Get all cache keys that match the module pattern
      final moduleId = AppConstants.superMarketModuleId;
      final cacheKeys = await ModuleCacheManager.getModuleCacheKeys(moduleId);
      
      if (cacheKeys.isNotEmpty) {
        // Update cache timestamp to mark it as fresh
        final SharedPreferences sharedPreferences = Get.find();
        await sharedPreferences.setInt(
          'module_cache_timestamp_$moduleId',
          DateTime.now().millisecondsSinceEpoch,
        );
        
        if (kDebugMode) {
          print('MarketModuleCacheService: Marked Market cache as complete with ${cacheKeys.length} endpoints');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('MarketModuleCacheService: Error caching Market data: $e');
      }
    }
  }

  /// Clear Market cache
  static Future<void> clearMarketCache() async {
    await ModuleCacheManager.clearModuleCache(moduleId);
  }
}

