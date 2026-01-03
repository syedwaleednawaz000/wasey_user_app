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
  Future<void> loadHomeData(bool reload, {bool fromModule = false}) async {
    await setModuleRestaurant(); // Set module to Supermarket first
    // Now copy all the Get.find calls from HomeScreen.loadData here
    // For example:
    Get.find<SplashController>().getStoredModule();
    Get.find<LocationController>().syncZoneData();
    Get.find<FlashSaleController>().setEmptyFlashSale(fromModule: fromModule);
    // print('------------call from home');
    // await Get.find<CartController>().getCartDataOnline();
    if (AuthHelper.isLoggedIn()) {
      Get.find<StoreController>()
          .getVisitAgainStoreList(fromModule: fromModule);
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
        Get.find<FlashSaleController>().getFlashSale(reload, false);
      }
      if (Get.find<SplashController>().module!.moduleType.toString() ==
          AppConstants.ecommerce) {
        Get.find<ItemController>().getFeaturedCategoriesItemList(false, false);
        Get.find<FlashSaleController>().getFlashSale(reload, false);
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
      Get.find<ItemController>().getRecommendedItemList(reload, 'all', false);
      Get.find<StoreController>().getStoreList(1, reload);
      Get.find<AdvertisementController>().getAdvertisementList();
    }
    if (AuthHelper.isLoggedIn()) {
      // Get.find<StoreController>().getVisitAgainStoreList(fromModule: fromModule);
      await Get.find<ProfileController>().getUserInfo();
      Get.find<NotificationController>().getNotificationList(reload);
      Get.find<CouponController>().getCouponList();
    }
    await Get.find<SplashController>().getModules();
    // await Get.find<SplashController>().getStoredModule();

    if (Get.find<SplashController>().module == null &&
        Get.find<SplashController>().configModel!.module == null) {
      Get.find<BannerController>().getFeaturedBanner();
      Get.find<StoreController>().getFeaturedStoreList();
      if (AuthHelper.isLoggedIn()) {
        Get.find<AddressController>().getAddressList();
      }
    }
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
    if (Get.find<StoreController>().categoryWithStoreList == null &&
        Get.find<StoreController>().categoryWithStoreList!.isEmpty) {
      log("categoryWithStoreList == null calling again...");
      // ======================= CORRECTED SECTION START =======================

      // Call the function to fetch the FIRST page of categories.
      // The `reload` parameter will tell the function whether to clear old data or not.
      await Get.find<StoreController>().getCategoriesWithStoreList(1, reload: reload);

      // (The old call from here has been removed as it's now handled above)

      // ======================== CORRECTED SECTION END ========================
    }
    // ---------------------------------------------
  }

  Future<void> setModuleRestaurant() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("moduleId", "2");
    splashController.switchModule(1, true);
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
