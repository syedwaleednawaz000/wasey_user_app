import 'dart:async';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/features/home/domain/models/cashback_model.dart';
import 'package:sixam_mart/features/home/domain/services/home_service_interface.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';

import '../../../helper/auth_helper.dart';
import '../../../util/app_constants.dart';
import '../../address/controllers/address_controller.dart';
import '../../banner/controllers/banner_controller.dart';
import '../../brands/controllers/brands_controller.dart';
import '../../category/controllers/category_controller.dart';
import '../../coupon/controllers/coupon_controller.dart';
import '../../flash_sale/controllers/flash_sale_controller.dart';
import '../../item/controllers/campaign_controller.dart';
import '../../item/controllers/item_controller.dart';
import '../../location/controllers/location_controller.dart';
import '../../notification/controllers/notification_controller.dart';
import '../../parcel/controllers/parcel_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../store/controllers/store_controller.dart';
import 'advertisement_controller.dart';
import '../services/module_cache_service.dart';

class HomeController extends GetxController implements GetxService {
  final HomeServiceInterface homeServiceInterface;

  HomeController({required this.homeServiceInterface});

  List<CashBackModel>? _cashBackOfferList;

  List<CashBackModel>? get cashBackOfferList => _cashBackOfferList;

  CashBackModel? _cashBackData;

  CashBackModel? get cashBackData => _cashBackData;

  bool _showFavButton = true;

  bool get showFavButton => _showFavButton;
  SplashController splashController = Get.find();

  // (In HomeController)
// Add a new method to handle all home screen data loading
// NOTE: When fromModule=true, this method is called from SplashController.switchModule()
// which already set the module. When fromModule=false (initial load), we need to set it.
  Future<void> loadHomeData(bool reload, {bool fromModule = false}) async {
    // Always clear category list to ensure correct categories are loaded for this module
    Get.find<CategoryController>().clearCategoryList();
    
    // Verify the current module ID from SharedPreferences
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? currentModuleId = sharedPreferences.getString("moduleId");
    log("HomeController: Current stored moduleId = $currentModuleId, fromModule = $fromModule");
    
    // Ensure module ID is set to "2" for Restaurant
    if (currentModuleId != "2") {
      await sharedPreferences.setString("moduleId", "2");
      log("HomeController: Updated moduleId to 2 for Restaurant");
    }
    
    // Wait for moduleList to be available if not yet loaded
    if (splashController.moduleList == null || splashController.moduleList!.isEmpty) {
      log("HomeController: Waiting for moduleList to be available...");
      await splashController.ensureModulesLoaded();
    }
    
    // Set the module in SplashController if not already Restaurant
    if (splashController.module == null || splashController.module!.id != 2) {
      if (splashController.moduleList != null && splashController.moduleList!.isNotEmpty) {
        // Find and set Restaurant module (ID: 2)
        for (int i = 0; i < splashController.moduleList!.length; i++) {
          if (splashController.moduleList![i].id == 2) {
            await splashController.setModule(splashController.moduleList![i], skipDataFetch: true);
            log("HomeController: Set SplashController module to Restaurant (index $i)");
            break;
          }
        }
      }
    }
    
    // Check if we should load from cache first (only if not forcing reload)
    if (!reload) {
      final isCacheValid = await RestaurantModuleCacheService.isRestaurantCacheValid();
      if (isCacheValid) {
        log("HomeController: Loading Restaurant data from cache");
        final cacheLoaded = await RestaurantModuleCacheService.loadRestaurantCache();
        if (cacheLoaded) {
          log("HomeController: Successfully loaded Restaurant data from cache - NO API CALLS");
          // When cache is valid, skip all API calls including user-specific ones
          // These will be refreshed when user explicitly pulls to refresh
          return; // Exit early if cache loaded successfully
        } else {
          log("HomeController: Cache load failed, fetching from API");
        }
      } else {
        log("HomeController: Cache invalid or expired, fetching from API");
      }
    } else {
      log("HomeController: Force reload requested, clearing cache and fetching from API");
      await RestaurantModuleCacheService.clearRestaurantCache();
    }

    // Fetch fresh data from API
    Get.find<SplashController>().getStoredModule();
    // Get.find<LocationController>().syncZoneData(); // Zone data is synced on app start, not on every module load
    Get.find<FlashSaleController>().setEmptyFlashSale(fromModule: fromModule);
    
    if (AuthHelper.isLoggedIn()) {
      // Get.find<StoreController>().getVisitAgainStoreList(fromModule: fromModule); // Commented - not needed on module switch
    }
    if (Get.find<SplashController>().module != null &&
        !Get.find<SplashController>()
            .configModel!
            .moduleConfig!
            .module!
            .isParcel!) {
      // ======================= CORRECTED SECTION START =======================

      // Call the function to fetch the FIRST page of categories.
      // The `reload` parameter will tell the function whether to clear old data or not.
      log("Calling getCategoriesWithStoreList from HomeController for the first page.");
      await Get.find<StoreController>().getCategoriesWithStoreList(1, reload: reload);

      // (The old call from here has been removed as it's now handled above)

      // ======================== CORRECTED SECTION END ========================
      Get.find<StoreController>().getRecommendedStoreList();
      if (Get.find<SplashController>().module!.moduleType.toString() ==
          AppConstants.grocery) {
        // Get.find<FlashSaleController>().getFlashSale(reload, false); // Commented - flash sale API
      }
      if (Get.find<SplashController>().module!.moduleType.toString() ==
          AppConstants.ecommerce) {
        Get.find<ItemController>().getFeaturedCategoriesItemList(false, false);
        // Get.find<FlashSaleController>().getFlashSale(reload, false); // Commented - flash sale API
        Get.find<BrandsController>().getBrandList();
      }
      Get.find<BannerController>().getPromotionalBannerList(reload);
      Get.find<ItemController>().getDiscountedItemList(reload, false, 'all');
      Get.find<CategoryController>().getCategoryList(reload);
      Get.find<StoreController>().getPopularStoreList(reload, 'all', false);
      Get.find<CampaignController>().getBasicCampaignList(reload);
      Get.find<CampaignController>().getItemCampaignList(reload);
      Get.find<ItemController>().getPopularItemList(reload, 'all', false);
      Get.find<StoreController>().getLatestStoreList(reload, 'all', false);
      Get.find<StoreController>().getTopOfferStoreList(reload, false);
      Get.find<ItemController>().getReviewedItemList(reload, 'all', false);
      // Get.find<ItemController>().getRecommendedItemList(reload, 'all', false); // Commented - Item that you love API
      Get.find<StoreController>().getStoreList(1, reload);
      Get.find<AdvertisementController>().getAdvertisementList();
    }
    if (AuthHelper.isLoggedIn()) {
      // Get.find<StoreController>().getVisitAgainStoreList(fromModule: fromModule);
      await Get.find<ProfileController>().getUserInfo();
      Get.find<NotificationController>().getNotificationList(reload);
      Get.find<CouponController>().getCouponList();
    }
    // await Get.find<SplashController>().getModules(); // Module list is loaded on app start, not on every module load
    // await Get.find<SplashController>().getStoredModule();

    // Commented out - Restaurant tab should always have module set, no need for default featured data
    // if (Get.find<SplashController>().module == null &&
    //     Get.find<SplashController>().configModel!.module == null) {
    //   Get.find<BannerController>().getFeaturedBanner();
    //   Get.find<StoreController>().getFeaturedStoreList();
    //   if (AuthHelper.isLoggedIn()) {
    //     Get.find<AddressController>().getAddressList();
    //   }
    // }
    if (Get.find<SplashController>().module != null &&
        Get.find<SplashController>()
            .configModel!
            .moduleConfig!
            .module!
            .isParcel!) {
      Get.find<ParcelController>().getParcelCategoryList();
    }
    if (Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() ==
            AppConstants.pharmacy) {
      Get.find<ItemController>().getBasicMedicine(reload, false);
      Get.find<StoreController>().getFeaturedStoreList();
      await Get.find<ItemController>().getCommonConditions(false);
      if (Get.find<ItemController>().commonConditions!.isNotEmpty) {
        Get.find<ItemController>().getConditionsWiseItem(
            Get.find<ItemController>().commonConditions![0].id!, false);
      }
    }
    // --- ADD THIS CALL TO THE END OF THE METHOD ---
    // log("getCategoriesWithStoreList called inside homeController ");
    if (Get.find<StoreController>().categoryWithStoreList == null ||
        (Get.find<StoreController>().categoryWithStoreList != null &&
            Get.find<StoreController>().categoryWithStoreList!.isEmpty)) {
      log("categoryWithStoreList == null or empty, calling again...");
      // ======================= CORRECTED SECTION START =======================

      // Call the function to fetch the FIRST page of categories.
      // The `reload` parameter will tell the function whether to clear old data or not.
      await Get.find<StoreController>().getCategoriesWithStoreList(1, reload: reload);

      // (The old call from here has been removed as it's now handled above)

      // ======================== CORRECTED SECTION END ========================
    }
    
    // Mark Restaurant cache as complete after all API calls
    await RestaurantModuleCacheService.cacheRestaurantData();
    log("HomeController: Marked Restaurant cache as complete");
    // ---------------------------------------------
  }

  /// Sets the module to Restaurant (ID: 2) directly without triggering switchModule
  /// This is used internally - for external module switching use SplashController.switchModule()
  Future<void> setModuleRestaurant() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString("moduleId", "2");
    
    // Set the module in SplashController directly with skipDataFetch to avoid API calls
    if (splashController.moduleList != null && splashController.moduleList!.isNotEmpty) {
      for (int i = 0; i < splashController.moduleList!.length; i++) {
        if (splashController.moduleList![i].id == 2) {
          await splashController.setModule(splashController.moduleList![i], skipDataFetch: true);
          log("setModuleRestaurant: Set module to Restaurant (ID: 2, index: $i)");
          break;
        }
      }
    }
    
    log("ModuleID is Set to: ${sharedPreferences.getString("moduleId")}");
    update();
  }

  // Future<void> setModuleSuperMarket()async{
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   sharedPreferences.setString("moduleId", "1");
  //   splashController.switchModule(0, true);
  //   update();
  // }

  // bool _canShoeReferrerBottomSheet = false;
  // bool get canShoeReferrerBottomSheet => _canShoeReferrerBottomSheet;

  // void toggleReferrerBottomSheet({bool? status}) {
  //   if(Get.find<ProfileController>().userInfoModel!.isValidForDiscount! && status == null) {
  //     _canShoeReferrerBottomSheet = true;
  //   } else {
  //     _canShoeReferrerBottomSheet = status ?? false;
  //   }
  // }

  Future<void> getCashBackOfferList() async {
    _cashBackOfferList = null;
    _cashBackOfferList = await homeServiceInterface.getCashBackOfferList();
    update();
  }

  void forcefullyNullCashBackOffers() {
    _cashBackOfferList = null;
    update();
  }

/*  Future<double> getCashBackAmount(double amount) async {
    _cashBackAmount = await homeServiceInterface.getCashBackAmount(amount);
    return _cashBackAmount;
  }*/

  Future<void> getCashBackData(double amount) async {
    CashBackModel? cashBackModel =
        await homeServiceInterface.getCashBackData(amount);
    if (cashBackModel != null) {
      _cashBackData = cashBackModel;
    }
    update();
  }

  void changeFavVisibility() {
    _showFavButton = !_showFavButton;
    update();
  }

  Future<bool> saveRegistrationSuccessfulSharedPref(bool status) async {
    return await homeServiceInterface.saveRegistrationSuccessful(status);
  }

  Future<bool> saveIsStoreRegistrationSharedPref(bool status) async {
    return await homeServiceInterface.saveIsRestaurantRegistration(status);
  }

  bool getRegistrationSuccessfulSharedPref() {
    return homeServiceInterface.getRegistrationSuccessful();
  }

  bool getIsStoreRegistrationSharedPref() {
    return homeServiceInterface.getIsRestaurantRegistration();
  }
}
