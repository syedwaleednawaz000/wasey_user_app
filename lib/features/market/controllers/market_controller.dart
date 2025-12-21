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
import '../../item/controllers/campaign_controller.dart';

class MarketController extends GetxController implements GetxService {

  final SplashController splashController = Get.find<SplashController>();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // This method will now be responsible for loading all data for the MarketScreen
  Future<void> loadMarketData(bool reload) async {
    _isLoading = true;
    if(reload) {
      update(); // Show loading indicator immediately on forced reload
    }

    // --- Key Action: Set the Module to Market/Supermarket ---
    // Set module ID to 1 for market in SharedPreferences
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString("moduleId", "1");
    // Switch to module index 0 (market/supermarket)
    splashController.switchModule(0, true);
    log("MarketController: Set moduleId=1 and switched to index 0 (Market)");

    // --- Now, load only the data needed for the MARKET module ---
    await Get.find<BannerController>().getBannerList(reload);
    await Get.find<CategoryController>().getCategoryList(reload);
    await Get.find<StoreController>().getPopularStoreList(reload, 'all', false);
    await Get.find<CampaignController>().getItemCampaignList(reload);
    await Get.find<ItemController>().getPopularItemList(reload, 'all', false);
    await Get.find<StoreController>().getLatestStoreList(reload, 'all', false);
    await Get.find<StoreController>().getStoreList(1, reload);

    if (AuthHelper.isLoggedIn()) {
      await Get.find<ProfileController>().getUserInfo();
      await Get.find<NotificationController>().getNotificationList(reload);
      Get.find<StoreController>().getVisitAgainStoreList(fromModule: true);
    }

    _isLoading = false;
    update();
    log("MarketController: Data loading complete.");
  }
}
