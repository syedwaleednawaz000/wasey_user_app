import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/coupon/controllers/coupon_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/store/domain/models/cart_suggested_item_model.dart';
import 'package:sixam_mart/features/category/domain/models/category_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/domain/models/recommended_product_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_banner_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/review/domain/models/review_model.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model_new_api.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/home/screens/home_screen.dart';
import 'package:sixam_mart/features/store/domain/services/store_service_interface.dart';
import 'package:sixam_mart/helper/module_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';

class StoreController extends GetxController implements GetxService {
  final StoreServiceInterface storeServiceInterface;

  StoreController({required this.storeServiceInterface});

  StoreModel? _storeModel;

  StoreModel? get storeModel => _storeModel;

  List<Store>? _popularStoreList;

  List<Store>? get popularStoreList => _popularStoreList;

  List<Store>? _latestStoreList;

  List<Store>? get latestStoreList => _latestStoreList;

  List<Store>? _topOfferStoreList;

  List<Store>? get topOfferStoreList => _topOfferStoreList;

  List<Store>? _featuredStoreList;

  List<Store>? get featuredStoreList => _featuredStoreList;

  List<Store>? _visitAgainStoreList;

  List<Store>? get visitAgainStoreList => _visitAgainStoreList;

  Store? _store;

  Store? get store => _store;

  ItemNewApiModel? _storeItemModel;

  ItemNewApiModel? get storeItemModel => _storeItemModel;

  ItemModel? _storeSearchItemModel;

  ItemModel? get storeSearchItemModel => _storeSearchItemModel;

  int _categoryIndex = 0;

  int get categoryIndex => _categoryIndex;

  List<CategoryModel>? _categoryList;

  List<CategoryModel>? get categoryList => _categoryList;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String _filterType = 'all';

  String get filterType => _filterType;

  String _storeType = 'all';

  String get storeType => _storeType;

  List<ReviewModel>? _storeReviewList;

  List<ReviewModel>? get storeReviewList => _storeReviewList;

  String _type = 'all';

  String get type => _type;

  String _searchType = 'all';

  String get searchType => _searchType;

  String _searchText = '';

  String get searchText => _searchText;

  bool _currentState = true;

  bool get currentState => _currentState;

  bool _showFavButton = true;

  bool get showFavButton => _showFavButton;

  List<XFile> _pickedPrescriptions = [];

  List<XFile> get pickedPrescriptions => _pickedPrescriptions;

  RecommendedItemModel? _recommendedItemModel;

  RecommendedItemModel? get recommendedItemModel => _recommendedItemModel;

  CartSuggestItemModel? _cartSuggestItemModel;

  CartSuggestItemModel? get cartSuggestItemModel => _cartSuggestItemModel;

  bool _isSearching = false;

  bool get isSearching => _isSearching;

  List<StoreBannerModel>? _storeBanners;

  List<StoreBannerModel>? get storeBanners => _storeBanners;

  List<Store>? _recommendedStoreList;

  List<Store>? get recommendedStoreList => _recommendedStoreList;

  int _selectedCategoryId = 0;

  int get selectedCategoryId => _selectedCategoryId;

  int _selectedSubCategoryId = 0;

  int get selectedSubCategoryId => _selectedSubCategoryId;

  List<StoreCategories>? _selectedStoreSubCategories = [];

  List<StoreCategories>? get selectedStoreSubCategories =>
      _selectedStoreSubCategories;

  StoreCategories? _selectedSubCategory = StoreCategories();

  StoreCategories? get selectedSubCategory => _selectedSubCategory;

  getSubCatWithItems() async{
    await getSubCategoriesWithItems(store!.categoryIds!.first);
    await getSubCatItems(selectedStoreSubCategories!.first.id);
  }

 getSubCatItems(int? selectedSubCatIdFromParam) {
    if (selectedSubCatIdFromParam == null) {
      log("Error: selectedSubCatIdFromParam is null.");
      _selectedSubCategoryId = 0;
      _selectedSubCategory = null;
      update();
      return;
    }

    _selectedSubCategoryId = selectedSubCatIdFromParam;
    log("_selectedSubCategoryId $_selectedSubCategoryId and selectedSubCatIdFromParam $selectedSubCatIdFromParam");
    _selectedSubCategory = null; // Reset

    if (_selectedStoreSubCategories != null && _selectedStoreSubCategories!.isNotEmpty) {
      for (var category in _selectedStoreSubCategories!) {
        if (category.id == _selectedSubCategoryId) {
          _selectedSubCategory = category;
          break; // Found it, no need to continue looping
        }
      }

      if (_selectedSubCategory != null) {
        log("Selected SubCategory found: ID=${_selectedSubCategory!.id}, Name=${_selectedSubCategory!.name}");
      } else {
        log("No subcategory found in _selectedStoreCategories with ID: $_selectedSubCategoryId");
      }
    } else {
      log("_selectedStoreCategories is null or empty.");
    }
    update();
  }

  getSubCategoriesWithItems(int? selectedCatId) {
    if (selectedCatId == null) {
      log("Error: selectedCatId is null.");
      update();
      return;
    }
    _selectedCategoryId = selectedCatId;
    _selectedStoreSubCategories?.clear();
    // Now always safe to call clear if initialized as []

    log("Cat from controller $_selectedCategoryId and cat From ui $selectedCatId");

    if (storeItemModel != null && storeItemModel!.categories != null) {
      var filteredCategories = storeItemModel!.categories!.where((category) {
        bool matchesSelectedId = (category.parentId == _selectedCategoryId);
        bool isRootOrNullParent =
            (category.parentId == 0 || category.parentId == null);
        return matchesSelectedId || isRootOrNullParent;
      }).toList();
      _selectedStoreSubCategories?.addAll(filteredCategories);
    } else {
      // ... logging for null storeItemModel or categories ...
    }

    print(
        'Selected Store Categories Count: ${_selectedStoreSubCategories?.length.toString()}');
    for (var cat in _selectedStoreSubCategories!) {
      // Safe
      print('  - ID: ${cat.id}, Name: ${cat.name}, ParentID: ${cat.parentId}');
    }
    if(_selectedStoreSubCategories != null && _selectedStoreSubCategories!.isNotEmpty) {
      final catId = _selectedStoreSubCategories!.first.id??0;
      _selectedSubCategoryId = catId;
      getSubCatItems(catId);
    }
    update();
  }

  double getRestaurantDistance(LatLng storeLatLng) {
    double distance = 0;
    distance = Geolocator.distanceBetween(
            storeLatLng.latitude,
            storeLatLng.longitude,
            double.parse(
                AddressHelper.getUserAddressFromSharedPref()!.latitude!),
            double.parse(
                AddressHelper.getUserAddressFromSharedPref()!.longitude!)) /
        1000;
    return distance;
  }

  String filteringUrl(String slug) {
    return storeServiceInterface.filterRestaurantLinkUrl(slug, _store!);
  }

  void pickPrescriptionImage(
      {required bool isRemove, required bool isCamera}) async {
    if (isRemove) {
      _pickedPrescriptions = [];
    } else {
      XFile? xFile = await ImagePicker().pickImage(
          source: isCamera ? ImageSource.camera : ImageSource.gallery,
          imageQuality: 50);
      if (xFile != null) {
        _pickedPrescriptions.add(xFile);
      }
      update();
    }
  }

  void removePrescriptionImage(int index) {
    _pickedPrescriptions.removeAt(index);
    update();
  }

  void changeFavVisibility() {
    _showFavButton = !_showFavButton;
    update();
  }

  void hideAnimation() {
    _currentState = false;
  }

  void showButtonAnimation() {
    Future.delayed(const Duration(seconds: 3), () {
      _currentState = true;
      update();
    });
  }

  Future<void> getRestaurantRecommendedItemList(
      int? storeId, bool reload) async {
    if (reload) {
      _storeModel = null;
      update();
    }
    RecommendedItemModel? recommendedItemModel =
        await storeServiceInterface.getStoreRecommendedItemList(storeId);
    if (recommendedItemModel != null) {
      _recommendedItemModel = recommendedItemModel;
    }
    update();
  }

  Future<void> getCartStoreSuggestedItemList(int? storeId) async {
    CartSuggestItemModel? cartSuggestItemModel =
        await storeServiceInterface.getCartStoreSuggestedItemList(
            storeId,
            Get.find<LocalizationController>().locale.languageCode,
            ModuleHelper.getModule(),
            ModuleHelper.getCacheModule()?.id,
            ModuleHelper.getModule()?.id);
    if (cartSuggestItemModel != null) {
      _cartSuggestItemModel = cartSuggestItemModel;
    }
    update();
  }

  Future<void> getStoreBannerList(int? storeId) async {
    List<StoreBannerModel>? storeBanners =
        await storeServiceInterface.getStoreBannerList(storeId);
    if (storeBanners != null) {
      _storeBanners = [];
      _storeBanners!.addAll(storeBanners);
    }
    update();
  }

  Future<void> getStoreList(int offset, bool reload,
      {DataSourceEnum source = DataSourceEnum.local}) async {
    if (reload) {
      _storeModel = null;
      update();
    }
    StoreModel? storeModel;
    if (source == DataSourceEnum.local && offset == 1) {
      storeModel = await storeServiceInterface.getStoreList(
          offset, _filterType, _storeType,
          source: DataSourceEnum.local);
      _prepareStoreModel(storeModel, offset);
      getStoreList(offset, false, source: DataSourceEnum.client);
    } else {
      storeModel = await storeServiceInterface.getStoreList(
          offset, _filterType, _storeType,
          source: DataSourceEnum.client);
      _prepareStoreModel(storeModel, offset);
    }
  }

  _prepareStoreModel(StoreModel? storeModel, int offset) {
    if (storeModel != null) {
      if (offset == 1) {
        _storeModel = storeModel;
      } else {
        _storeModel!.totalSize = storeModel.totalSize;
        _storeModel!.offset = storeModel.offset;
        _storeModel!.stores!.addAll(storeModel.stores!);
      }
      update();
    }
  }

  void setFilterType(String type) {
    _filterType = type;
    getStoreList(1, true);
  }

  void setStoreType(String type) {
    _storeType = type;
    getStoreList(1, true);
  }

  void resetStoreData() {
    _filterType = 'all';
    _storeType = 'all';
  }

  Future<void> getPopularStoreList(bool reload, String type, bool notify,
      {DataSourceEnum dataSource = DataSourceEnum.local,
      bool fromRecall = false}) async {
    _type = type;
    if (reload) {
      _popularStoreList = null;
    }
    if (notify) {
      update();
    }
    if (_popularStoreList == null || reload || fromRecall) {
      List<Store>? popularStoreList;
      if (dataSource == DataSourceEnum.local) {
        popularStoreList = await storeServiceInterface.getPopularStoreList(type,
            source: DataSourceEnum.local);
        if (popularStoreList != null) {
          _popularStoreList = [];
          _popularStoreList!.addAll(popularStoreList);
        }
        update();
        getPopularStoreList(false, type, notify,
            dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        popularStoreList = await storeServiceInterface.getPopularStoreList(type,
            source: DataSourceEnum.client);
        if (popularStoreList != null) {
          _popularStoreList = [];
          _popularStoreList!.addAll(popularStoreList);
        }
        update();
      }
    }
  }

  Future<void> getLatestStoreList(bool reload, String type, bool notify,
      {DataSourceEnum dataSource = DataSourceEnum.local,
      bool fromRecall = false}) async {
    _type = type;
    if (reload) {
      _latestStoreList = null;
    }
    if (notify) {
      update();
    }
    if (_latestStoreList == null || reload || fromRecall) {
      List<Store>? latestStoreList;
      if (dataSource == DataSourceEnum.local) {
        latestStoreList = await storeServiceInterface.getLatestStoreList(type,
            source: DataSourceEnum.local);
        if (latestStoreList != null) {
          _latestStoreList = [];
          _latestStoreList!.addAll(latestStoreList);
        }
        update();
        getLatestStoreList(false, type, notify,
            fromRecall: true, dataSource: DataSourceEnum.client);
      } else {
        latestStoreList = await storeServiceInterface.getLatestStoreList(type,
            source: DataSourceEnum.client);
        if (latestStoreList != null) {
          _latestStoreList = [];
          _latestStoreList!.addAll(latestStoreList);
        }
        update();
      }
    }
  }

  Future<void> getTopOfferStoreList(bool reload, bool notify,
      {DataSourceEnum dataSource = DataSourceEnum.local,
      bool fromRecall = false}) async {
    if (reload) {
      _topOfferStoreList = null;
    }
    if (notify) {
      update();
    }
    if (_topOfferStoreList == null || reload || fromRecall) {
      List<Store>? latestStoreList;
      if (dataSource == DataSourceEnum.local) {
        latestStoreList = await storeServiceInterface.getTopOfferStoreList(
            source: DataSourceEnum.local);
        if (latestStoreList != null) {
          _topOfferStoreList = [];
          _topOfferStoreList!.addAll(latestStoreList);
        }
        update();
        getTopOfferStoreList(false, notify,
            dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        latestStoreList = await storeServiceInterface.getTopOfferStoreList(
            source: DataSourceEnum.client);
        if (latestStoreList != null) {
          _topOfferStoreList = [];
          _topOfferStoreList!.addAll(latestStoreList);
        }
        update();
      }
    }
  }

  Future<void> getFeaturedStoreList(
      {DataSourceEnum dataSource = DataSourceEnum.local}) async {
    List<Store>? stores;
    if (dataSource == DataSourceEnum.local) {
      stores =
          await storeServiceInterface.getFeaturedStoreList(source: dataSource);
      _prepareFeaturedStore(stores);
      getFeaturedStoreList(dataSource: DataSourceEnum.client);
    } else {
      stores =
          await storeServiceInterface.getFeaturedStoreList(source: dataSource);
      _prepareFeaturedStore(stores);
    }
  }

  _prepareFeaturedStore(List<Store>? stores) {
    if (stores != null) {
      _featuredStoreList = [];
      List<Modules> moduleList = [];
      moduleList.addAll(storeServiceInterface.moduleList());
      for (Store store in stores) {
        for (var module in moduleList) {
          if (module.id == store.moduleId) {
            if (module.pivot!.zoneId == store.zoneId) {
              _featuredStoreList!.add(store);
            }
          }
        }
      }
    }
    update();
  }

  Future<void> getVisitAgainStoreList(
      {bool fromModule = false,
      DataSourceEnum dataSource = DataSourceEnum.local,
      bool fromRecall = false}) async {
    if (fromModule && !fromRecall) {
      _visitAgainStoreList = null;
    }
    List<Store>? stores;
    if (dataSource == DataSourceEnum.local) {
      stores = await storeServiceInterface.getVisitAgainStoreList(
          source: DataSourceEnum.local);
      _prepareVisitAgainStore(stores);
      getVisitAgainStoreList(
          dataSource: DataSourceEnum.client, fromRecall: true);
    } else {
      stores = await storeServiceInterface.getVisitAgainStoreList(
          source: DataSourceEnum.client);
      _prepareVisitAgainStore(stores);
    }
  }

  _prepareVisitAgainStore(List<Store>? stores) {
    if (stores != null) {
      _visitAgainStoreList = [];
      List<Modules> moduleList = [];
      moduleList.addAll(storeServiceInterface.moduleList());
      for (var store in stores) {
        for (var module in moduleList) {
          if (module.id == store.moduleId) {
            if (module.pivot!.zoneId == store.zoneId) {
              _visitAgainStoreList!.add(store);
            }
          }
        }
      }
    }
    update();
  }

  void setCategoryList() {
    if (Get.find<CategoryController>().categoryList != null && _store != null) {
      _categoryList = [];
      // _categoryList!.add(CategoryModel(id: 0, name: 'all'.tr));
      for (var category in Get.find<CategoryController>().categoryList!) {
        if (_store!.categoryIds!.contains(category.id)) {
          _categoryList!.add(category);
        }
      }
    }
  }

  Future<void> initCheckoutData(int? storeId) async {
    Get.find<CouponController>().removeCouponData(false);
    Get.find<CheckoutController>().clearPrevData();
    await Get.find<StoreController>()
        .getStoreDetails(Store(id: storeId), false);
    Get.find<CheckoutController>().initializeTimeSlot(_store!);
  }

  Future<Store?> getStoreDetails(Store store, bool fromModule,
      {bool fromCart = false, String slug = ''}) async {
    _categoryIndex = 0;
    if (store.name != null) {
      _store = store;
    } else {
      _isLoading = true;
      _store = null;
      Store? storeDetails = await storeServiceInterface.getStoreDetails(
          store.id.toString(),
          fromCart,
          slug,
          Get.find<LocalizationController>().locale.languageCode,
          ModuleHelper.getModule(),
          ModuleHelper.getCacheModule()?.id,
          ModuleHelper.getModule()?.id);
      if (storeDetails != null) {
        _store = storeDetails;
        Get.find<CheckoutController>().initializeTimeSlot(_store!);
        if (!fromCart && slug.isEmpty) {
          Get.find<CheckoutController>().getDistanceInKM(
            LatLng(
              double.parse(
                  AddressHelper.getUserAddressFromSharedPref()!.latitude!),
              double.parse(
                  AddressHelper.getUserAddressFromSharedPref()!.longitude!),
            ),
            LatLng(double.parse(_store!.latitude!),
                double.parse(_store!.longitude!)),
          );
        }
        if (slug.isNotEmpty) {
          await Get.find<LocationController>().setStoreAddressToUserAddress(
              LatLng(double.parse(_store!.latitude!),
                  double.parse(_store!.longitude!)));
        }
        if (fromModule) {
          HomeScreen.loadData(true);
        } else {
          Get.find<CheckoutController>().clearPrevData();
        }
      }
      Get.find<CheckoutController>().setOrderType(
        _store != null
            ? _store!.delivery!
                ? 'delivery'
                : 'take_away'
            : 'delivery',
        notify: false,
      );
      _isLoading = false;
      update();
    }
    return _store;
  }

  Future<void> getRecommendedStoreList(
      {DataSourceEnum dataSource = DataSourceEnum.local,
      bool fromRecall = false}) async {
    if (!fromRecall) {
      _recommendedStoreList = null;
    }
    List<Store>? recommendedStoreList;
    if (dataSource == DataSourceEnum.local) {
      recommendedStoreList = await storeServiceInterface
          .getRecommendedStoreList(source: DataSourceEnum.local);
      _prepareRecommendedStores(recommendedStoreList);
      getRecommendedStoreList(
          dataSource: DataSourceEnum.client, fromRecall: true);
    } else {
      recommendedStoreList = await storeServiceInterface
          .getRecommendedStoreList(source: DataSourceEnum.client);
      _prepareRecommendedStores(recommendedStoreList);
    }
  }

  _prepareRecommendedStores(List<Store>? recommendedStoreList) {
    if (recommendedStoreList != null) {
      _recommendedStoreList = [];
      _recommendedStoreList!.addAll(recommendedStoreList);
    }
    update();
  }

  Future<void> getStoreItemList(
      int? storeID, int offset, String type, bool notify) async {
    if (offset == 1 || _storeItemModel == null) {
      _type = type;
      _storeItemModel = null;
      if (notify) {
        update();
      }
    }
    ItemNewApiModel? storeItemModel =
        await storeServiceInterface.getStoreItemListNewAPI(
      storeID,
      offset,
    );
    if (storeItemModel != null) {
      if (offset == 1) {
        _storeItemModel = storeItemModel;
      } else {
        _storeItemModel = storeItemModel;
        _storeItemModel!.totalSize = storeItemModel.totalSize;
        _storeItemModel!.offset = storeItemModel.offset;
      }
    }
    update();
  }

  Future<void> getStoreSearchItemList(
      String searchText, String? storeID, int offset, String type) async {
    if (searchText.isEmpty) {
      showCustomSnackBar('write_item_name'.tr);
    } else {
      _isSearching = true;
      _searchText = searchText;
      _type = type;
      if (offset == 1 || _storeSearchItemModel == null) {
        _searchType = type;
        _storeSearchItemModel = null;
        update();
      }
      ItemModel? storeSearchItemModel =
          await storeServiceInterface.getStoreSearchItemList(
              searchText,
              storeID,
              offset,
              type,
              (_store != null &&
                      _store!.categoryIds!.isNotEmpty &&
                      _categoryIndex != 0)
                  ? _categoryList![_categoryIndex].id
                  : 0);
      if (storeSearchItemModel != null) {
        if (offset == 1) {
          _storeSearchItemModel = storeSearchItemModel;
        } else {
          _storeSearchItemModel!.items!.addAll(storeSearchItemModel.items!);
          _storeSearchItemModel!.totalSize = storeSearchItemModel.totalSize;
          _storeSearchItemModel!.offset = storeSearchItemModel.offset;
        }
      }
      update();
    }
  }

  void changeSearchStatus({bool isUpdate = true}) {
    _isSearching = !_isSearching;
    if (isUpdate) {
      update();
    }
  }

  void initSearchData() {
    _storeSearchItemModel = ItemModel(items: []);
    _searchText = '';
  }

  void setCategoryIndex(int index, {bool itemSearching = false}) {
    _categoryIndex = index;
    if (itemSearching) {
      _storeSearchItemModel = null;
      getStoreSearchItemList(_searchText, _store!.id.toString(), 1, type);
    } else {
      _storeItemModel = null;
      getStoreItemList(_store!.id, 1, Get.find<StoreController>().type, false);
    }
    update();
  }

  bool isStoreClosed(bool today, bool active, List<Schedules>? schedules) {
    if (!active) {
      return true;
    }
    DateTime date = DateTime.now();
    if (!today) {
      date = date.add(const Duration(days: 1));
    }
    int weekday = date.weekday;
    if (weekday == 7) {
      weekday = 0;
    }
    for (int index = 0; index < schedules!.length; index++) {
      if (weekday == schedules[index].day) {
        return false;
      }
    }
    return true;
  }

  bool isStoreOpenNow(bool active, List<Schedules>? schedules) {
    if (isStoreClosed(true, active, schedules)) {
      return false;
    }
    int weekday = DateTime.now().weekday;
    if (weekday == 7) {
      weekday = 0;
    }
    for (int index = 0; index < schedules!.length; index++) {
      if (weekday == schedules[index].day &&
          DateConverter.isAvailable(
              schedules[index].openingTime, schedules[index].closingTime)) {
        return true;
      }
    }
    return false;
  }

  bool isOpenNow(Store store) => store.open == 1 && store.active!;

  double? getDiscount(Store store) =>
      store.discount != null ? store.discount!.discount : 0;

  String? getDiscountType(Store store) =>
      store.discount != null ? store.discount!.discountType : 'percent';

  void shareStore() {
    if (ResponsiveHelper.isDesktop(Get.context)) {
      String shareUrl =
          '${AppConstants.webHostedUrl}${filteringUrl(store!.slug ?? '')}';

      Clipboard.setData(ClipboardData(text: shareUrl));
      showCustomSnackBar('store_url_copied'.tr, isError: false);
    } else {
      String shareUrl =
          '${AppConstants.webHostedUrl}${filteringUrl(store!.slug ?? '')}';
      Share.share(shareUrl);
    }
  }

// +++++++++++++++++++++++++++

// New properties for infinite scrolling
  int _currentCategoryIndex = 0;
  int _currentSubCategoryIndex = 0;
  List<Item> _allItems = [];
  bool _isLoadingMore = false;
  bool _hasMoreItems = true;

  // Getters
  int get currentCategoryIndex => _currentCategoryIndex;
  int get currentSubCategoryIndex => _currentSubCategoryIndex;
  List<Item> get allItems => _allItems;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreItems => _hasMoreItems;

  // Initialize scrolling state
  void initScrollState() {
    _currentCategoryIndex = 0;
    _currentSubCategoryIndex = 0;
    _allItems.clear();
    _isLoadingMore = false;
    _hasMoreItems = true;
  }

  // Load next items when scrolling reaches bottom
  Future<void> loadNextItems() async {
    if (_isLoadingMore || !_hasMoreItems) return;

    _isLoadingMore = true;
    update();

    try {
      // If we have more subcategories in the current category
      if (_currentSubCategoryIndex < _selectedStoreSubCategories!.length - 1) {
        _currentSubCategoryIndex++;
        await _loadNextSubCategory();
      }
      // If we need to move to the next category
      else if (_store != null &&
          _store!.categoryIds != null &&
          _currentCategoryIndex < _store!.categoryIds!.length - 1) {
        _currentCategoryIndex++;
        _currentSubCategoryIndex = 0;
        await _loadNextCategory();
      }
      // No more categories or subcategories
      else {
        _hasMoreItems = false;
      }
    } catch (e) {
      log('Error loading next items: $e');
    } finally {
      _isLoadingMore = false;
      update();
    }
  }

  Future<void> _loadNextSubCategory() async {
    final nextSubCategory = _selectedStoreSubCategories![_currentSubCategoryIndex];
    await getSubCatItems(nextSubCategory.id);

    // Add the new items to our combined list
    if (_selectedSubCategory != null &&
        _selectedSubCategory!.items != null &&
        _selectedSubCategory!.items!.isNotEmpty) {
      _allItems.addAll(_selectedSubCategory!.items!);
    }
  }

  Future<void> _loadNextCategory() async {
    final nextCategoryId = _store!.categoryIds![_currentCategoryIndex];
    await getSubCategoriesWithItems(nextCategoryId);

    // Once subcategories are loaded, get the first subcategory's items
    if (_selectedStoreSubCategories != null && _selectedStoreSubCategories!.isNotEmpty) {
      final firstSubCategory = _selectedStoreSubCategories!.first;
      await getSubCatItems(firstSubCategory.id);

      // Add the new items to our combined list
      if (_selectedSubCategory != null &&
          _selectedSubCategory!.items != null &&
          _selectedSubCategory!.items!.isNotEmpty) {
        _allItems.addAll(_selectedSubCategory!.items!);
      }
    }
  }

  /*// Modified getSubCatItems to update the combined items list
  Future<void> getSubCatItems(int? selectedSubCatIdFromParam) async {
    if (selectedSubCatIdFromParam == null) {
      log("Error: selectedSubCatIdFromParam is null.");
      _selectedSubCategoryId = 0;
      _selectedSubCategory = null;
      update();
      return;
    }

    _selectedSubCategoryId = selectedSubCatIdFromParam;
    _selectedSubCategory = null;

    if (_selectedStoreSubCategories != null && _selectedStoreSubCategories!.isNotEmpty) {
      for (var category in _selectedStoreSubCategories!) {
        if (category.id == _selectedSubCategoryId) {
          _selectedSubCategory = category;
          break;
        }
      }

      // Load items for this subcategory
      if (_selectedSubCategory != null && _selectedSubCategory!.items == null) {
        // You'll need to implement this method to fetch items for a subcategory
        await _fetchItemsForSubCategory(_selectedSubCategory!);
      }

      // Initialize or update the combined items list
      if (_selectedSubCategory != null && _selectedSubCategory!.items != null) {
        if (_currentCategoryIndex == 0 && _currentSubCategoryIndex == 0) {
          // First load, initialize the list
          _allItems = List.from(_selectedSubCategory!.items!);
        } else {
          // Subsequent loads, ensure we don't duplicate items
          final newItems = _selectedSubCategory!.items!
              .where((item) => !_allItems.any((existingItem) => existingItem.id == item.id))
              .toList();
          _allItems.addAll(newItems);
        }
      }
    }
    update();
  }

  // Method to fetch items for a subcategory (you need to implement this based on your API)
  Future<void> _fetchItemsForSubCategory(StoreCategories subCategory) async {
    // Implement your API call here to fetch items for the subcategory
    // This is a placeholder - replace with your actual implementation
    try {
      // Example:
      // final response = await yourApiService.getItemsBySubCategory(subCategory.id);
      // if (response != null && response.isSuccess) {
      //   subCategory.items = response.items;
      // }
    } catch (e) {
      log('Error fetching items for subcategory: $e');
    }
  }

  // Modified getSubCategoriesWithItems
  Future<void> getSubCategoriesWithItems(int? selectedCatId) async {
    if (selectedCatId == null) {
      log("Error: selectedCatId is null.");
      update();
      return;
    }

    _selectedCategoryId = selectedCatId;
    _selectedStoreSubCategories?.clear();

    // Reset the combined items if we're starting a new category
    if (_currentCategoryIndex > 0) {
      _allItems.clear();
    }

    if (storeItemModel != null && storeItemModel!.categories != null) {
      var filteredCategories = storeItemModel!.categories!.where((category) {
        bool matchesSelectedId = (category.parentId == _selectedCategoryId);
        bool isRootOrNullParent = (category.parentId == 0 || category.parentId == null);
        return matchesSelectedId || isRootOrNullParent;
      }).toList();
      _selectedStoreSubCategories?.addAll(filteredCategories);
    }

    update();
  }
*/
  // Helper method to get category name by ID
  String getCategoryNameById(int categoryId) {
    if (_categoryList == null) return '';
    final category = _categoryList!.firstWhereOrNull((cat) => cat.id == categoryId);
    return category?.name ?? '';
  }
}
