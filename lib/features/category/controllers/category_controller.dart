import 'dart:developer';

import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/category/domain/models/category_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/category/domain/services/category_service_interface.dart';

import '../../../helper/module_helper.dart';
import '../../../util/app_constants.dart';
import '../../splash/controllers/splash_controller.dart';

class CategoryController extends GetxController implements GetxService {
  final CategoryServiceInterface categoryServiceInterface;

  CategoryController({required this.categoryServiceInterface});

  List<CategoryModel>? _categoryList;

  List<CategoryModel>? get categoryList => _categoryList;

  List<CategoryModel>? _subCategoryList;

  List<CategoryModel>? get subCategoryList => _subCategoryList;

  List<Item>? _categoryItemList;

  List<Item>? get categoryItemList => _categoryItemList;

  List<Store>? _categoryStoreList;

  List<Store>? get categoryStoreList => _categoryStoreList;

  List<Item>? _searchItemList = [];

  List<Item>? get searchItemList => _searchItemList;

  List<Store>? _searchStoreList = [];

  List<Store>? get searchStoreList => _searchStoreList;

  List<bool>? _interestSelectedList;

  List<bool>? get interestSelectedList => _interestSelectedList;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  int? _pageSize;

  int? get pageSize => _pageSize;

  int? _restPageSize;

  int? get restPageSize => _restPageSize;

  bool _isSearching = false;

  bool get isSearching => _isSearching;

  int _subCategoryIndex = 0;

  int get subCategoryIndex => _subCategoryIndex;

  String _type = 'all';

  String get type => _type;

  bool _isStore = false;

  bool get isStore => _isStore;

  String? _searchText = '';

  String? get searchText => _searchText;

  int _offset = 1;

  int get offset => _offset;

  String _selectedCatId = "";

  String get selectedCatId => _selectedCatId;

  void setSelectedCatId(String catId) {
    _selectedCatId = catId;
    update();
  }

  List<Store>? _selectCatStoreList = [];

  List<Store>? get selectCatStoreList => _selectCatStoreList;
  var isLoadingSelectedStores = true.obs; // Initially true
  var selectedStoresErrorMessage = Rx<String?>(null); // Initially no error

  void setSelectedCategoryStores({required String selectedCatId}) {
    log("Selected catId for filtering stores: $selectedCatId");
    _selectedCatId =
        selectedCatId; // Assuming _selectedCatId is a member of CategoryController

    final StoreController storeController = Get.find<StoreController>();
    List<Store> newFilteredStores = [];
    try {
      isLoadingSelectedStores.value = true;
      if ((ModuleHelper.getModule()!.id!.toString() ==
              AppConstants.restaurantModuleId) &&
          storeController.categoryWithStoreList != null) {
        newFilteredStores = storeController.categoryWithStoreList!
            .where((category) {
              return category.cId.toString() == selectedCatId;
            })
            .first
            .stores!;
        selectCatStoreList?.clear();
        selectCatStoreList?.addAll(newFilteredStores);
        // If using RxList, .assignAll() is often better for reactivity:
        // selectCatStoreList.assignAll(newFilteredStores);

        // Option B: Add to existing (if that's the desired behavior, handle duplicates if needed)
        // this.selectCatStoreList?.addAll(newFilteredStores); // Ensure this.selectCatStoreList is initialized

        log('Filtered with new Stores Count: ${selectCatStoreList?.length}'); // Log the final list
        log('Filtered with new Stores Names: ${selectCatStoreList?.map((s) => s.name ?? "N/A").toList()}');
      } else if (storeController.storeModel != null &&
          storeController.storeModel!.stores != null &&
          storeController.storeModel!.stores!.isNotEmpty) {
        newFilteredStores = storeController.storeModel!.stores!.where((store) {
          return store.categoryIds != null &&
              store.categoryIds!.contains(int.parse(selectedCatId));
        }).toList();

        // Decide how to update selectCatStoreList:
        // Option A: Replace the entire list (common for filtering)
        selectCatStoreList?.clear();
        selectCatStoreList?.addAll(newFilteredStores);
        // If using RxList, .assignAll() is often better for reactivity:
        // selectCatStoreList.assignAll(newFilteredStores);

        // Option B: Add to existing (if that's the desired behavior, handle duplicates if needed)
        // this.selectCatStoreList?.addAll(newFilteredStores); // Ensure this.selectCatStoreList is initialized

        log('Filtered Stores Count: ${selectCatStoreList?.length}'); // Log the final list
        log('Filtered Stores Names: ${selectCatStoreList?.map((s) => s.name ?? "N/A").toList()}');
      } else {
        log('Source store model or stores list is null/empty. Clearing filtered stores.');
        selectCatStoreList?.clear(); // Clear if source is invalid
        // If using RxList:
        // selectCatStoreList.clear();
      }
    } catch (e) {
      log("Error updating selected stores: $e");
      selectedStoresErrorMessage.value =
          "error_loading_stores".tr; // Set generic error message
      selectCatStoreList?.clear(); // Clea
    } finally {
      isLoadingSelectedStores.value = false;
    }

    // Call update() AFTER all state modifications are complete and outside the direct build phase
    // if this function itself is not called from within a build method (like initState).
    // The fix above (addPostFrameCallback) addresses when this function is called.
    update(); // This tells GetBuilder to refresh
    log("CategoryController updated after setting selected category stores.");
  }

  void clearCategoryList() {
    _categoryList = null;
  }

  /// Get category list
  /// [localOnly] - If true, only loads from local cache without making API call
  /// [moduleId] - Optional explicit module ID for cache key (used when loading from cache service)
  Future<void> getCategoryList(bool reload,
      {bool allCategory = false,
      DataSourceEnum dataSource = DataSourceEnum.local,
      bool fromRecall = false,
      bool localOnly = false,
      String? moduleId}) async {
    if (_categoryList == null || reload || fromRecall) {
      if (reload) {
        _categoryList = null;
      }
      List<CategoryModel>? categoryList;
      if (dataSource == DataSourceEnum.local) {
        categoryList = await categoryServiceInterface
            .getCategoryList(allCategory, source: DataSourceEnum.local, moduleId: moduleId);
        _prepareCategoryList(categoryList);
        // Only fetch from API if not localOnly
        if (!localOnly) {
          getCategoryList(false,
              fromRecall: true,
              allCategory: allCategory,
              dataSource: DataSourceEnum.client);
        }
      } else {
        categoryList = await categoryServiceInterface
            .getCategoryList(allCategory, source: DataSourceEnum.client);
        _prepareCategoryList(categoryList);
      }
    }
  }

  _prepareCategoryList(List<CategoryModel>? categoryList) {
    if (categoryList != null) {
      _categoryList = [];
      _interestSelectedList = [];
      _categoryList!.addAll(categoryList);
      for (int i = 0; i < _categoryList!.length; i++) {
        _interestSelectedList!.add(false);
      }
    }
    update();
  }

  void getSubCategoryList(String? categoryID) async {
    _subCategoryIndex = 0;
    _subCategoryList = null;
    _categoryItemList = null;

    List<CategoryModel>? subCategoryList =
        await categoryServiceInterface.getSubCategoryList(categoryID);

    _subCategoryList = [];

    if (subCategoryList != null && subCategoryList.isNotEmpty) {
      _subCategoryList!
          .add(CategoryModel(id: int.parse(categoryID!), name: 'all'.tr));
      _subCategoryList!.addAll(subCategoryList);
    } else {
      // في حال لم توجد فئات فرعية نستخدم الفئة الأساسية كفئة وحيدة
      CategoryModel? mainCategory = _categoryList?.firstWhere(
        (cat) => cat.id.toString() == categoryID,
        orElse: () => CategoryModel(id: int.parse(categoryID!), name: 'all'.tr),
      );
      if (mainCategory != null) {
        _subCategoryList!.add(mainCategory);
      }
    }

    getCategoryItemList(categoryID, 1, 'all', false);
    update();
  }

  void setSubCategoryIndex(int index, String? categoryID) {
    _subCategoryIndex = index;
    if (_isStore) {
      getCategoryStoreList(
          _subCategoryIndex == 0
              ? categoryID
              : _subCategoryList![index].id.toString(),
          1,
          _type,
          true);
    } else {
      getCategoryItemList(
          _subCategoryIndex == 0
              ? categoryID
              : _subCategoryList![index].id.toString(),
          1,
          _type,
          true);
    }
  }

  void getCategoryItemList(
      String? categoryID, int offset, String type, bool notify) async {
    _offset = offset;
    if (offset == 1) {
      if (_type == type) {
        _isSearching = false;
      }
      _type = type;
      if (notify) {
        update();
      }
      _categoryItemList = null;
    }
    ItemModel? categoryItem = await categoryServiceInterface
        .getCategoryItemList(categoryID, offset, type);
    if (categoryItem != null) {
      if (offset == 1) {
        _categoryItemList = [];
      }
      _categoryItemList!.addAll(categoryItem.items!);
      _pageSize = categoryItem.totalSize;
      _isLoading = false;
    }
    update();
  }

  void getCategoryStoreList(
      String? categoryID, int offset, String type, bool notify) async {
    _isLoading = true;
    _offset = offset;
    if (offset == 1) {
      if (_type == type) {
        _isSearching = false;
      }
      _type = type;
      _categoryStoreList = null;
      if (notify) {
        update(); // Trigger UI update to show shimmer
      }
    }
    StoreModel? categoryStore = await categoryServiceInterface
        .getCategoryStoreList(categoryID, offset, type);
    if (categoryStore != null) {
      if (offset == 1) {
        _categoryStoreList = [];
      }
      _categoryStoreList!.addAll(categoryStore.stores!);
      _restPageSize = categoryStore.totalSize;
      _isLoading = false;
    }
    update();
  }

  void searchData(String? query, String? categoryID, String type) async {
    if ((_isStore && query!.isNotEmpty) ||
        (!_isStore && query!.isNotEmpty /*&& query != _itemResultText*/)) {
      _searchText = query;
      _type = type;
      _isStore ? _searchStoreList = null : _searchItemList = null;
      _isSearching = true;
      update();

      Response response = await categoryServiceInterface.getSearchData(
          query, categoryID, _isStore, type);
      if (response.statusCode == 200) {
        if (query.isEmpty) {
          _isStore ? _searchStoreList = [] : _searchItemList = [];
        } else {
          if (_isStore) {
            _searchStoreList = [];
            _searchStoreList!
                .addAll(StoreModel.fromJson(response.body).stores!);
            update();
          } else {
            _searchItemList = [];
            _searchItemList!.addAll(ItemModel.fromJson(response.body).items!);
          }
        }
      }
      update();
    }
  }

  void toggleSearch() {
    _isSearching = !_isSearching;
    _searchItemList = [];
    if (_categoryItemList != null) {
      _searchItemList!.addAll(_categoryItemList!);
    }
    update();
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  Future<bool> saveInterest(List<int?> interests) async {
    _isLoading = true;
    update();
    bool isSuccess =
        await categoryServiceInterface.saveUserInterests(interests);
    _isLoading = false;
    update();
    return isSuccess;
  }

  void addInterestSelection(int index) {
    _interestSelectedList![index] = !_interestSelectedList![index];
    update();
  }

  void setRestaurant(bool isRestaurant) {
    _isStore = isRestaurant;
    update();
  }
}
