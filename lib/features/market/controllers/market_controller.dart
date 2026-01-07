import 'dart:developer';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/banner/controllers/banner_controller.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/notification/controllers/notification_controller.dart';
import 'package:sixam_mart/features/coupon/controllers/coupon_controller.dart';
import 'package:sixam_mart/features/home/controllers/advertisement_controller.dart';
import '../../item/controllers/campaign_controller.dart';
import '../services/module_cache_service.dart';

class MarketController extends GetxController implements GetxService {

  final SplashController splashController = Get.find<SplashController>();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // This method will now be responsible for loading all data for the MarketScreen
  // NOTE: This method handles module setting and cache-aware data loading
  Future<void> loadMarketData(bool reload) async {
    // Always clear category list to ensure correct categories are loaded for this module
    Get.find<CategoryController>().clearCategoryList();
    
    _isLoading = true;
    if(reload) {
      update(); // Show loading indicator immediately on forced reload
    }

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    
    // Verify the current module ID from SharedPreferences
    String? currentModuleId = sharedPreferences.getString("moduleId");
    log("MarketController: Current stored moduleId = $currentModuleId, reload = $reload");
    
    // Ensure module ID is set to "1" for Market
    if (currentModuleId != "1") {
      await sharedPreferences.setString("moduleId", "1");
      log("MarketController: Updated moduleId to 1 for Market");
    }
    
    // Wait for moduleList to be available if not yet loaded
    if (splashController.moduleList == null || splashController.moduleList!.isEmpty) {
      log("MarketController: Waiting for moduleList to be available...");
      await splashController.ensureModulesLoaded();
    }
    
    // Set the module in SplashController if not already Market
    if (splashController.module == null || splashController.module!.id != 1) {
      if (splashController.moduleList != null && splashController.moduleList!.isNotEmpty) {
        for (int i = 0; i < splashController.moduleList!.length; i++) {
          if (splashController.moduleList![i].id == 1) {
            await splashController.setModule(splashController.moduleList![i], skipDataFetch: true);
            log("MarketController: Set SplashController module to Market (ID: 1, index: $i)");
            break;
          }
        }
      }
    }

    // Check if we should load from cache first (only if not forcing reload)
    if (!reload) {
      final isCacheValid = await MarketModuleCacheService.isMarketCacheValid();
      if (isCacheValid) {
        log("MarketController: Loading Market data from cache");
        final cacheLoaded = await MarketModuleCacheService.loadMarketCache();
        if (cacheLoaded) {
          log("MarketController: Successfully loaded Market data from cache - NO API CALLS");
          // When cache is valid, skip all API calls including user-specific ones
          // These will be refreshed when user explicitly pulls to refresh
          _isLoading = false;
          update();
          return; // Exit early if cache loaded successfully
        } else {
          log("MarketController: Cache load failed, fetching from API");
        }
      } else {
        log("MarketController: Cache invalid or expired, fetching from API");
      }
    } else {
      log("MarketController: Force reload requested, clearing cache and fetching from API");
      await MarketModuleCacheService.clearMarketCache();
    }

    // --- Now, load only the data needed for the MARKET module ---
    await Get.find<BannerController>().getBannerList(reload);
    await Get.find<BannerController>().getPromotionalBannerList(reload); // PromotionalBannerView
    await Get.find<CategoryController>().getCategoryList(reload);
    await Get.find<StoreController>().getPopularStoreList(reload, 'all', false);
    await Get.find<StoreController>().getTopOfferStoreList(reload, false); // TopOffersNearMe
    await Get.find<StoreController>().getLatestStoreList(reload, 'all', false);
    await Get.find<StoreController>().getStoreList(1, reload);
    await Get.find<CampaignController>().getBasicCampaignList(reload); // MiddleSectionBannerView
    await Get.find<CampaignController>().getItemCampaignList(reload); // JustForYouView
    await Get.find<ItemController>().getPopularItemList(reload, 'all', false);
    await Get.find<ItemController>().getDiscountedItemList(reload, false, 'all'); // Special Offers
    await Get.find<AdvertisementController>().getAdvertisementList(); // HighlightWidget

    if (AuthHelper.isLoggedIn()) {
      await Get.find<ProfileController>().getUserInfo();
      await Get.find<NotificationController>().getNotificationList(reload);
      await Get.find<CouponController>().getCouponList(); // PromoCodeBannerView
      // Get.find<StoreController>().getVisitAgainStoreList(fromModule: true); // Commented - not needed for Market
    }

    // Mark Market cache as complete after all API calls
    await MarketModuleCacheService.cacheMarketData();
    log("MarketController: Marked Market cache as complete");

    _isLoading = false;
    update();
    log("MarketController: Data loading complete.");
  }
}
