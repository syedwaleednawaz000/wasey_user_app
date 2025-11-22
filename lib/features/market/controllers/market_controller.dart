import 'dart:developer';
import 'package:get/get.dart';
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

    // --- Key Action: Set the Module to Food/Restaurant ---
    // This is the most important part. We ensure we are in the correct module.
    // The '1' is the index in your module list. Adjust if 'Restaurant' is at a different index.
    splashController.switchModule(0, true);
    log("MarketController: Switched module to Restaurant/Food.");

    // --- Now, load only the data needed for the FOOD module ---
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
