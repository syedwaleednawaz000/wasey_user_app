import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/banner/controllers/banner_controller.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/flash_sale/controllers/flash_sale_controller.dart';
import 'package:sixam_mart/features/home/controllers/home_controller.dart';
import 'package:sixam_mart/features/item/controllers/campaign_controller.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/splash/domain/models/landing_model.dart';
import 'package:sixam_mart/common/models/config_model.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/home/screens/home_screen.dart';
import 'package:sixam_mart/features/splash/domain/services/splash_service_interface.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/splash_route_helper.dart';
import 'package:universal_html/html.dart' as html;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/features/market/controllers/market_controller.dart';

class SplashController extends GetxController implements GetxService {
  final SplashServiceInterface splashServiceInterface;
  SplashController({required this.splashServiceInterface});

  ConfigModel? _configModel;
  ConfigModel? get configModel => _configModel;

  bool _firstTimeConnectionCheck = true;
  bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;

  bool _hasConnection = true;
  bool get hasConnection => _hasConnection;

  ModuleModel? _module;
  ModuleModel? get module => _module;

  ModuleModel? _cacheModule;
  ModuleModel? get cacheModule => _cacheModule;

  List<ModuleModel>? _moduleList;
  List<ModuleModel>? get moduleList => _moduleList;

  int _moduleIndex = 0;
  int get moduleIndex => _moduleIndex;

  Map<String, dynamic>? _data = {};

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _selectedModuleIndex = 0;
  int get selectedModuleIndex => _selectedModuleIndex;

  LandingModel? _landingModel;
  LandingModel? get landingModel => _landingModel;

  bool _savedCookiesData = false;
  bool get savedCookiesData => _savedCookiesData;

  bool _webSuggestedLocation = false;
  bool get webSuggestedLocation => _webSuggestedLocation;

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  bool _showReferBottomSheet = false;
  bool get showReferBottomSheet => _showReferBottomSheet;

  DateTime get currentTime => DateTime.now();

  void selectModuleIndex(int index) {
    _selectedModuleIndex = index;
    update();
  }

  @override
  void onInit() {
    // print("MarketController: onInit called."); // ADD THIS LINE
    super.onInit();
    loadData();
  }

  void loadData() async {
    await ensureModulesLoaded();
    await getStoredModule();
  }

  /// Ensures module list is available.
  /// Important: `getModules()` in local mode triggers remote fetch without awaiting it,
  /// which can leave `_moduleList` null on first launch. This method awaits remote
  /// only when local is empty.
  Future<void> ensureModulesLoaded({Map<String, String>? headers}) async {
    if (_moduleList != null && _moduleList!.isNotEmpty) {
      return;
    }

    // Try local only first
    await getModules(headers: headers, dataSource: DataSourceEnum.local, alsoFetchRemote: false);

    // If local is empty, fetch remote and await
    if (_moduleList == null || _moduleList!.isEmpty) {
      await getModules(headers: headers, dataSource: DataSourceEnum.client, alsoFetchRemote: false);
    }
  }

  Future<void> getConfigData(
      {NotificationBodyModel? notificationBody,
      bool loadModuleData = false,
      bool loadLandingData = false,
      DataSourceEnum source = DataSourceEnum.local,
      bool fromMainFunction = false,
      bool fromDemoReset = false}) async {
    _hasConnection = true;
    _moduleIndex = 0;
    Response response;
    if (source == DataSourceEnum.local && !fromDemoReset) {
      response = await splashServiceInterface.getConfigData(
          source: DataSourceEnum.local);
      _handleConfigResponse(response, loadModuleData, loadLandingData,
          fromMainFunction, fromDemoReset, notificationBody);
      getConfigData(
          loadModuleData: loadModuleData,
          loadLandingData: loadLandingData,
          source: DataSourceEnum.client);
    } else {
      response = await splashServiceInterface.getConfigData(
          source: DataSourceEnum.client);
      _handleConfigResponse(response, loadModuleData, loadLandingData,
          fromMainFunction, fromDemoReset, notificationBody);
    }
  }

  Future<void> getStoredModule() async {
    SplashController splashController = Get.find();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? _storedModuleId = sharedPreferences.getString("moduleId");
    
    // If no module is stored, set default to 2 (restaurant - first tab)
    if (_storedModuleId == null || _storedModuleId.isEmpty) {
      _storedModuleId = '2';
      await sharedPreferences.setString("moduleId", "2");
      debugPrint('getStoredModule: No module stored, setting default to 2 (restaurant)');
    }

    // Ensure modules are loaded before switching
    await ensureModulesLoaded();

    final int desiredId = int.tryParse(_storedModuleId) ?? 2;
    final int idx = _moduleList?.indexWhere((m) => m.id == desiredId) ?? -1;

    if (idx >= 0) {
      splashController.switchModule(idx, true);
      debugPrint('getStoredModule: Switched to moduleId=$desiredId (index=$idx)');
    } else if (_moduleList != null && _moduleList!.isNotEmpty) {
      // Fallback: if desired module not found, use first available module
      splashController.switchModule(0, true);
      debugPrint('getStoredModule: Desired moduleId=$desiredId not found, switched to index=0');
    } else {
      debugPrint('getStoredModule: Module list is still empty; cannot switch module yet');
    }
  }

  Future<void> _handleConfigResponse(
      Response response,
      bool loadModuleData,
      bool loadLandingData,
      bool fromMainFunction,
      bool fromDemoReset,
      NotificationBodyModel? notificationBody) async {
    if (response.statusCode == 200) {
      _data = response.body;
      _configModel = ConfigModel.fromJson(response.body);
      // log("config boyd response ${jsonDecode(response.body)}");
      if (_configModel != null && _configModel!.module != null) {
        setModule(_configModel!.module);
      } else if (GetPlatform.isWeb || (loadModuleData && _module != null)) {
        setModule(
            GetPlatform.isWeb ? splashServiceInterface.getModule() : _module);
      }
      if (loadLandingData) {
        await getLandingPageData();
      }
      if (fromMainFunction) {
        _mainConfigRouting();
      } else if (fromDemoReset) {
        Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: true));
      } else {
        route(body: notificationBody);
      }
      _onRemoveLoader();
    } else {
      if (response.statusText == ApiClient.noInternetMessage) {
        _hasConnection = false;
      }
    }
    update();
  }

  _mainConfigRouting() async {
    if (Get.find<AuthController>().isLoggedIn()) {
      Get.find<AuthController>().updateToken();
      if (Get.find<SplashController>().module != null) {
        await Get.find<FavouriteController>().getFavouriteList();
      }
    }
  }

  void _onRemoveLoader() {
    final preloader = html.document.querySelector('.preloader');
    if (preloader != null) {
      preloader.remove();
    }
  }

  Future<void> getLandingPageData(
      {DataSourceEnum source = DataSourceEnum.local}) async {
    LandingModel? landingModel;
    if (source == DataSourceEnum.local) {
      landingModel = await splashServiceInterface.getLandingPageData(
          source: DataSourceEnum.local);
      _prepareLandingModel(landingModel);
      getLandingPageData(source: DataSourceEnum.client);
    } else {
      landingModel = await splashServiceInterface.getLandingPageData(
          source: DataSourceEnum.client);
      _prepareLandingModel(landingModel);
    }
  }

  _prepareLandingModel(LandingModel? landingModel) {
    if (landingModel != null) {
      _landingModel = landingModel;
      hoverStates = List<bool>.generate(
          _landingModel!.availableZoneList!.length, (index) => false);
    }
    update();
  }

  Future<void> initSharedData() async {
    if (!GetPlatform.isWeb) {
      _module = null;
      splashServiceInterface.initSharedData();
    } else {
      log("initSharedData");
      _module = await splashServiceInterface.initSharedData();
      log(_module.toString());
    }
    _cacheModule = splashServiceInterface.getCacheModule();
    setModule(_module, notify: false);
  }

  void setCacheConfigModule(ModuleModel? cacheModule) {
    if (_configModel != null && 
        _configModel!.moduleConfig != null && 
        _data != null && 
        cacheModule != null &&
        _data!['module_config'] != null &&
        _data!['module_config'][cacheModule.moduleType] != null) {
      _configModel!.moduleConfig!.module =
          Module.fromJson(_data!['module_config'][cacheModule.moduleType]);
    }
  }

  bool? showIntro() {
    return splashServiceInterface.showIntro();
  }

  void disableIntro() {
    splashServiceInterface.disableIntro();
  }

  void setFirstTimeConnectionCheck(bool isChecked) {
    _firstTimeConnectionCheck = isChecked;
  }

  /// Sets the current module.
  /// [skipDataFetch] - If true, skips fetching cart, wishlist, and cashback data.
  /// Use skipDataFetch=true when loading from cache to avoid unnecessary API calls.
  Future<void> setModule(ModuleModel? module, {bool notify = true, bool skipDataFetch = false}) async {
    _module = module;
    splashServiceInterface.setModule(module);
    if (module != null) {
      if (_configModel != null && 
          _configModel!.moduleConfig != null && 
          _data != null &&
          _data!['module_config'] != null &&
          _data!['module_config'][module.moduleType] != null) {
        _configModel!.moduleConfig!.module =
            Module.fromJson(_data!['module_config'][module.moduleType]);
      }
      await splashServiceInterface.setCacheModule(module);
      
      // Only fetch cart data if not skipping data fetch
      if (!skipDataFetch && (AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) &&
          Get.find<SplashController>().cacheModule != null) {
        Get.find<CartController>().getCartDataOnline();
      }
    }
    
    // Only fetch user-specific data if not skipping data fetch
    if (!skipDataFetch && AuthHelper.isLoggedIn()) {
      if (Get.find<SplashController>().module != null) {
        Get.find<HomeController>().getCashBackOfferList();
        Get.find<FavouriteController>().getFavouriteList();
      }
    }
    if (notify) {
      update();
    }
  }

  Module getModuleConfig(String? moduleType) {
    if (_data == null || 
        _data!['module_config'] == null || 
        moduleType == null ||
        _data!['module_config'][moduleType] == null) {
      throw Exception('Module configuration not found for type: $moduleType');
    }
    
    Module module = Module.fromJson(_data!['module_config'][moduleType]);
    moduleType == 'food'
        ? module.newVariation = true
        : module.newVariation = false;
    return module;
  }

  Future<void> getModules(
      {Map<String, String>? headers,
      DataSourceEnum dataSource = DataSourceEnum.local,
      bool alsoFetchRemote = true}) async {
    _moduleIndex = 0;
    List<ModuleModel>? moduleList;
    if (dataSource == DataSourceEnum.local) {
      moduleList = await splashServiceInterface.getModules(
          headers: headers, source: DataSourceEnum.local);
      _prepareModuleList(moduleList);
      if (alsoFetchRemote) {
        getModules(headers: headers, dataSource: DataSourceEnum.client, alsoFetchRemote: alsoFetchRemote);
      }
    } else {
      moduleList = await splashServiceInterface.getModules(
          headers: headers, source: DataSourceEnum.client);
      _prepareModuleList(moduleList);
    }
  }

  _prepareModuleList(List<ModuleModel>? moduleList) {
    if (moduleList != null) {
      _moduleList = [];
      _moduleList!.addAll(moduleList);
    }
    update();
  }

  Future<void> _showInterestPage() async {
    final profileController = Get.find<ProfileController>();
    final splashController = Get.find<SplashController>();
    
    if (profileController.userInfoModel != null &&
        profileController.userInfoModel!.selectedModuleForInterest != null &&
        splashController.module != null &&
        !profileController.userInfoModel!
            .selectedModuleForInterest!
            .contains(splashController.module!.id) &&
        (splashController.module!.moduleType == 'food' ||
            splashController.module!.moduleType == 'grocery' ||
            splashController.module!.moduleType == 'ecommerce')) {
      await Get.toNamed(RouteHelper.getInterestRoute());
    }
  }

  void switchModule(int index, bool fromPhone, {bool forceReload = false}) async {
    log("inside SplashController switchModule method");
    
    if (_moduleList == null || index < 0 || index >= _moduleList!.length) {
      log("Error: Module list is null or index is out of bounds");
      return;
    }
    
    final targetModuleId = _moduleList![index].id;
    log("Switching to module: $targetModuleId (index: $index)");

    // Check if we're actually switching to a different module
    final bool isSameModule = _module != null && _module!.id == targetModuleId;
    
    if (!isSameModule || forceReload) {
      log("Module switch required: current=${_module?.id}, target=$targetModuleId");
      
      // Save the target module ID to SharedPreferences FIRST
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.setString("moduleId", targetModuleId.toString());
      log("SplashController: Saved moduleId=$targetModuleId to SharedPreferences");
      
      // Set module with skipDataFetch=true because controllers will handle data loading with cache
      await Get.find<SplashController>().setModule(_moduleList![index], skipDataFetch: true);
      
      // NOTE: Don't clear controller data here - it allows cache to work properly
      // The controller data persists in memory and will be used when cache is valid
      // Data will be refreshed when user pulls to refresh or cache expires
      Get.find<FlashSaleController>().setEmptyFlashSale(fromModule: true);
      
      // Use cache-aware loading based on target module
      // Module ID 1 = Market/Supermarket, Module ID 2 = Restaurant
      // The controllers will handle all API calls including user-specific data with cache support
      if (targetModuleId == 1) {
        // Load Market data with cache support
        log("SplashController: Loading Market module data (cache-aware, forceReload=$forceReload)");
        await Get.find<MarketController>().loadMarketData(forceReload);
      } else if (targetModuleId == 2) {
        // Load Restaurant data with cache support
        log("SplashController: Loading Restaurant module data (cache-aware, forceReload=$forceReload)");
        await Get.find<HomeController>().loadHomeData(forceReload, fromModule: true);
      } else {
        // For other modules, use the old approach (no cache support yet)
        log("SplashController: Loading other module data (ID: $targetModuleId)");
        HomeScreen.loadData(forceReload, fromModule: true);
      }
      
      // Show interest page after data is loaded (if applicable)
      if (AuthHelper.isLoggedIn()) {
        await _showInterestPage();
      }
    } else {
      log("Already on the same module ($targetModuleId), skipping switch");
    }
  }

  int getCacheModule() {
    return splashServiceInterface.getCacheModule()?.id ?? 0;
  }

  void setModuleIndex(int index) {
    _moduleIndex = index;
    update();
  }

  void removeModule() {
    setModule(null);
    Get.find<BannerController>().getFeaturedBanner();
    getModules();
    Get.find<HomeController>().forcefullyNullCashBackOffers();
    if (AuthHelper.isLoggedIn()) {
      Get.find<AddressController>().getAddressList();
    }
    Get.find<StoreController>().getFeaturedStoreList();
    Get.find<CampaignController>().itemAndBasicCampaignNull();
  }

  void removeCacheModule() {
    splashServiceInterface.setCacheModule(null);
  }

  Future<bool> subscribeMail(String email) async {
    _isLoading = true;
    update();
    ResponseModel responseModel =
        await splashServiceInterface.subscribeEmail(email);
    if (responseModel.isSuccess) {
      showCustomSnackBar(responseModel.message, isError: false);
    } else {
      showCustomSnackBar(responseModel.message, isError: true);
    }
    _isLoading = false;
    update();
    return responseModel.isSuccess;
  }

  void saveCookiesData(bool data) {
    splashServiceInterface.saveCookiesData(data);
    _savedCookiesData = true;
    update();
  }

  getCookiesData() {
    _savedCookiesData = splashServiceInterface.getSavedCookiesData();
    update();
  }

  void cookiesStatusChange(String? data) {
    splashServiceInterface.cookiesStatusChange(data);
  }

  bool getAcceptCookiesStatus(String data) =>
      splashServiceInterface.getAcceptCookiesStatus(data);

  void saveWebSuggestedLocationStatus(bool data) {
    splashServiceInterface.saveSuggestedLocationStatus(data);
    _webSuggestedLocation = true;
    update();
  }

  void getWebSuggestedLocationStatus() {
    _webSuggestedLocation = splashServiceInterface.getSuggestedLocationStatus();
  }

  void setRefreshing(bool status) {
    _isRefreshing = status;
    update();
  }

  void saveReferBottomSheetStatus(bool data) {
    splashServiceInterface.saveReferBottomSheetStatus(data);
    _showReferBottomSheet = data;
    update();
  }

  void getReferBottomSheetStatus() {
    _showReferBottomSheet = splashServiceInterface.getReferBottomSheetStatus();
  }

  var hoverStates = <bool>[];

  void setHover(int index, bool state) {
    hoverStates[index] = state;
    update();
  }
}
