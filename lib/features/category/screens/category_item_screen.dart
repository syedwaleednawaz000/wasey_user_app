import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/home/widgets/category_pop_up.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/module_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/cart_widget.dart';
import 'package:sixam_mart/common/widgets/item_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/veg_filter_widget.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/models/module_model.dart';
import '../../../util/app_constants.dart';
import '../../home/widgets/category_view.dart';
import '../../language/controllers/language_controller.dart';
import '../../store/controllers/store_controller.dart';
import '../../store/screens/store_screen.dart';
import '../domain/models/category_model.dart';

class CategoryItemScreen extends StatefulWidget {
  final String? categoryID;
  final String categoryName;

  const CategoryItemScreen(
      {super.key, required this.categoryID, required this.categoryName});

  @override
  CategoryItemScreenState createState() => CategoryItemScreenState();
}

class CategoryItemScreenState extends State<CategoryItemScreen>
    with TickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  final ScrollController storeScrollController = ScrollController();
  TabController? _tabController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool? showRestaurantText = ModuleHelper.getModule()!.id!.toString() ==
      AppConstants.restaurantModuleId;

  @override
  void initState() {
    super.initState();
    showRestaurantText = ModuleHelper.getModule()!.id!.toString() ==
        AppConstants.restaurantModuleId;
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    // Get.find<CategoryController>().getSubCategoryList(widget.categoryID);

    Get.find<CategoryController>().getCategoryStoreList(
      widget.categoryID,
      1,
      Get.find<CategoryController>().type,
      false,
    );

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          Get.find<CategoryController>().categoryItemList != null &&
          !Get.find<CategoryController>().isLoading) {
        int pageSize = (Get.find<CategoryController>().pageSize! / 10).ceil();
        if (Get.find<CategoryController>().offset < pageSize) {
          if (kDebugMode) {
            print('end of the page');
          }
          Get.find<CategoryController>().showBottomLoader();
          Get.find<CategoryController>().getCategoryItemList(
            Get.find<CategoryController>().subCategoryIndex == 0
                ? widget.categoryID
                : Get.find<CategoryController>()
                    .subCategoryList![
                        Get.find<CategoryController>().subCategoryIndex]
                    .id
                    .toString(),
            Get.find<CategoryController>().offset + 1,
            Get.find<CategoryController>().type,
            false,
          );
        }
      }
    });
    storeScrollController.addListener(() {
      if (storeScrollController.position.pixels ==
              storeScrollController.position.maxScrollExtent &&
          Get.find<CategoryController>().categoryStoreList != null &&
          !Get.find<CategoryController>().isLoading) {
        int pageSize =
            (Get.find<CategoryController>().restPageSize! / 10).ceil();
        if (Get.find<CategoryController>().offset < pageSize) {
          if (kDebugMode) {
            print('end of the page');
          }
          Get.find<CategoryController>().showBottomLoader();
          Get.find<CategoryController>().getCategoryStoreList(
            Get.find<CategoryController>().subCategoryIndex == 0
                ? widget.categoryID
                : Get.find<CategoryController>()
                    .subCategoryList![
                        Get.find<CategoryController>().subCategoryIndex]
                    .id
                    .toString(),
            Get.find<CategoryController>().offset + 1,
            Get.find<CategoryController>().type,
            false,
          );
        }
      }
    });
    // In CategoryItemScreenState (category_item_screen.dart)
    final CategoryController catController = Get.find<CategoryController>();

    // Use addPostFrameCallback to run code after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Now it's safe to call methods that might trigger UI updates
      if (mounted) {
        // Good practice to check if the widget is still in the tree
        catController.setSelectedCategoryStores(
            selectedCatId: widget.categoryID
                .toString()); // Assuming widget.categoryID is available
      }
    });

    // Other initState logic that doesn't call update() can remain here

    // if(widget.categoryID != null && widget.categoryID!.isNotEmpty) {
    //   Get.find<CategoryController>().setSelectedCategoryStores(selectedCatId: widget.categoryID!);
    // }
  }

  @override
  Widget build(BuildContext context) {
    int selectedCat = 0;
    return GetBuilder<CategoryController>(builder: (catController) {
      List<Item>? item;
      List<Store>? stores;

      if (catController.isSearching
          ? catController.searchItemList != null
          : catController.categoryItemList != null) {
        item = [];
        if (catController.isSearching) {
          item.addAll(catController.searchItemList!);
        } else {
          item.addAll(catController.categoryItemList!);
        }
      }
      if (catController.isSearching
          ? catController.searchStoreList != null
          : catController.categoryStoreList != null) {
        stores = [];
        if (catController.isSearching) {
          stores.addAll(catController.searchStoreList!);
        } else {
          stores.addAll(catController.categoryStoreList!);
        }
      }

      changeSelectedCategory({required String categoryId}) {
        // log("/////////////////////");
        // log("category Id is : $categoryId");

        print('Selected Stores Count:');
        print('Selected Cat ID:$categoryId');

        // (String? categoryID, int offset, String type, bool notify)
        Get.find<CategoryController>().getCategoryStoreList(
          categoryId,
          Get.find<CategoryController>().offset + 1,
          Get.find<CategoryController>().type,
          true,
        );

        // If selectedCategoryStores is RxList, use .assignAll() for better reactivity:
        // selectedCategoryStores.assignAll(matchingStores);

        print('Selected Stores Count: ${stores?.length}');
        print(
            'Selected Stores Names: ${stores?.map((s) => s.name ?? "N/A").toList()}');

        // update(); // Notify GetX to rebuild widgets observing this controller
      }

      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) async {
          if (catController.isSearching) {
            catController.toggleSearch();
          } else {
            return;
          }
        },
        child: Scaffold(
            appBar: (ResponsiveHelper.isDesktop(context)
                ? const WebMenuBar()
                : AppBar(
                    backgroundColor: Theme.of(context).cardColor,
                    surfaceTintColor: Theme.of(context).cardColor,
                    shadowColor: Theme.of(context)
                        .disabledColor
                        .withAlpha((0.5 * 255).toInt()),
                    elevation: 2,
                    title: catController.isSearching
                        ? SizedBox(
                            height: 45,
                            child: TextField(
                                autofocus: true,
                                textInputAction: TextInputAction.search,
                                decoration: InputDecoration(
                                  hintText: 'Search...',
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusDefault),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).disabledColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusDefault),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).disabledColor),
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () =>
                                        catController.toggleSearch(),
                                    icon: Icon(
                                      catController.isSearching
                                          ? Icons.close_sharp
                                          : Icons.search,
                                      color: Theme.of(context).disabledColor,
                                    ),
                                  ),
                                ),
                                style: STCRegular.copyWith(
                                    fontSize: Dimensions.fontSizeLarge),
                                onSubmitted: (String query) {
                                  catController.searchData(
                                    query,
                                    catController.subCategoryIndex == 0
                                        ? widget.categoryID
                                        : catController
                                            .subCategoryList![
                                                catController.subCategoryIndex]
                                            .id
                                            .toString(),
                                    catController.type,
                                  );
                                }),
                          )
                        : Text("categories".tr,
                            // widget.categoryName,
                            style: STCBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color,
                            )),
                    centerTitle: true,
                    leading: IconButton(
                      style: IconButton.styleFrom(iconSize: 20),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                      onPressed: () {
                        if (catController.isSearching) {
                          catController.toggleSearch();
                        } else {
                          Get.back();
                        }
                      },
                    ),
                    actions: [
                      // !catController.isSearching
                      //     ? IconButton(
                      //         onPressed: () => catController.toggleSearch(),
                      //         icon: Icon(
                      //           catController.isSearching
                      //               ? Icons.close_sharp
                      //               : Icons.search,
                      //           color:
                      //               Theme.of(context).textTheme.bodyLarge!.color,
                      //         ),
                      //       )
                      //     : const SizedBox(),
                      // IconButton(
                      //   onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
                      //   icon: CartWidget(
                      //       color: Theme.of(context).textTheme.bodyLarge!.color,
                      //       size: 25),
                      // ),
                      // VegFilterWidget(
                      //     type: catController.type,
                      //     fromAppBar: true,
                      //     onSelected: (String type) {
                      //       if (catController.isSearching) {
                      //         catController.searchData(
                      //           catController.subCategoryIndex == 0
                      //               ? widget.categoryID
                      //               : catController
                      //                   .subCategoryList![
                      //                       catController.subCategoryIndex]
                      //                   .id
                      //                   .toString(),
                      //           '1',
                      //           type,
                      //         );
                      //       } else {
                      //         if (catController.isStore) {
                      //           catController.getCategoryStoreList(
                      //             catController.subCategoryIndex == 0
                      //                 ? widget.categoryID
                      //                 : catController
                      //                     .subCategoryList![
                      //                         catController.subCategoryIndex]
                      //                     .id
                      //                     .toString(),
                      //             1,
                      //             type,
                      //             true,
                      //           );
                      //         } else {
                      //           catController.getCategoryItemList(
                      //             catController.subCategoryIndex == 0
                      //                 ? widget.categoryID
                      //                 : catController
                      //                     .subCategoryList![
                      //                         catController.subCategoryIndex]
                      //                     .id
                      //                     .toString(),
                      //             1,
                      //             type,
                      //             true,
                      //           );
                      //         }
                      //       }
                      //     }),
                      // const SizedBox(width: Dimensions.paddingSizeSmall),
                    ],
                  )),
            // endDrawer: const MenuDrawer(),
            // endDrawerEnableOpenDragGesture: false,
            body: ResponsiveHelper.isDesktop(context)
                ? SingleChildScrollView(
                    child: FooterView(
                      child: Center(
                          child: SizedBox(
                        width: Dimensions.webMaxWidth,
                        child: Column(children: [
                          (catController.subCategoryList != null &&
                                  !catController.isSearching)
                              ? Center(
                                  child: Container(
                                  height: 40,
                                  width: Dimensions.webMaxWidth,
                                  color: Theme.of(context).cardColor,
                                  padding: const EdgeInsets.symmetric(
                                      vertical:
                                          Dimensions.paddingSizeExtraSmall),
                                  child: ListView.builder(
                                    key: scaffoldKey,
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        catController.subCategoryList!.length,
                                    padding: const EdgeInsets.only(
                                        left: Dimensions.paddingSizeSmall),
                                    physics: const BouncingScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () =>
                                            catController.setSubCategoryIndex(
                                                index, widget.categoryID),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  Dimensions.paddingSizeSmall,
                                              vertical: Dimensions
                                                  .paddingSizeExtraSmall),
                                          margin: const EdgeInsets.only(
                                              right:
                                                  Dimensions.paddingSizeSmall),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.radiusSmall),
                                            color: index ==
                                                    catController
                                                        .subCategoryIndex
                                                ? Theme.of(context)
                                                    .primaryColor
                                                    .withAlpha(
                                                        (0.1 * 255).toInt())
                                                : Colors.transparent,
                                          ),
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  catController
                                                      .subCategoryList![index]
                                                      .name!,
                                                  style: index ==
                                                          catController
                                                              .subCategoryIndex
                                                      ? STCMedium.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeSmall,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor)
                                                      : STCRegular.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeSmall),
                                                ),
                                              ]),
                                        ),
                                      );
                                    },
                                  ),
                                ))
                              : const SizedBox(),
                          Center(
                              child: Container(
                            width: Dimensions.webMaxWidth,
                            color: Theme.of(context).cardColor,
                            child: TabBar(
                              controller: _tabController,
                              indicatorColor: Theme.of(context).primaryColor,
                              indicatorWeight: 3,
                              labelColor: Theme.of(context).primaryColor,
                              unselectedLabelColor:
                                  Theme.of(context).disabledColor,
                              unselectedLabelStyle: STCBold.copyWith(
                                color: Theme.of(context).disabledColor,
                                fontSize: 20,
                              ),
                              labelStyle: STCBold.copyWith(
                                fontSize: 20,
                                color: Theme.of(context).primaryColor,
                              ),
                              tabs: [
                                // ← اجعل "المطاعم / المتاجر" أول تبويب
                                Tab(
                                  text: showRestaurantText!
                                      ? 'restaurants'.tr
                                      : 'stores'.tr,
                                ),
                                // ← ثم الوجبات
                                Tab(text: 'item'.tr),
                              ],
                            ),
                          )),
                          SizedBox(
                            height: 600,
                            child: NotificationListener(
                              onNotification: (dynamic scrollNotification) {
                                if (scrollNotification
                                    is ScrollEndNotification) {
                                  if ((_tabController!.index == 1 &&
                                          !catController.isStore) ||
                                      _tabController!.index == 0 &&
                                          catController.isStore) {
                                    catController.setRestaurant(
                                        _tabController!.index == 1);
                                    if (catController.isSearching) {
                                      catController.searchData(
                                        catController.searchText,
                                        catController.subCategoryIndex == 0
                                            ? widget.categoryID
                                            : catController
                                                .subCategoryList![catController
                                                    .subCategoryIndex]
                                                .id
                                                .toString(),
                                        catController.type,
                                      );
                                    } else {
                                      if (_tabController!.index == 1) {
                                        catController.getCategoryStoreList(
                                          catController.subCategoryIndex == 0
                                              ? widget.categoryID
                                              : catController
                                                  .subCategoryList![
                                                      catController
                                                          .subCategoryIndex]
                                                  .id
                                                  .toString(),
                                          1,
                                          catController.type,
                                          false,
                                        );
                                      } else {
                                        catController.getCategoryItemList(
                                          catController.subCategoryIndex == 0
                                              ? widget.categoryID
                                              : catController
                                                  .subCategoryList![
                                                      catController
                                                          .subCategoryIndex]
                                                  .id
                                                  .toString(),
                                          1,
                                          catController.type,
                                          false,
                                        );
                                      }
                                    }
                                  }
                                }
                                return false;
                              },
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  SingleChildScrollView(
                                    controller: storeScrollController,
                                    child: ItemsView(
                                      isStore: true,
                                      items: null,
                                      stores: stores,
                                      noDataText: showRestaurantText!
                                          ? 'no_category_restaurant_found'.tr
                                          : 'no_category_store_found'.tr,
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    controller: scrollController,
                                    child: ItemsView(
                                      isStore: false,
                                      items: item,
                                      stores: null,
                                      noDataText: 'no_category_item_found'.tr,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          catController.isLoading
                              ? Center(
                                  child: Padding(
                                  padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeSmall),
                                  child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Theme.of(context).primaryColor)),
                                ))
                              : const SizedBox(),
                        ]),
                      )),
                    ),
                  )
                // : SizedBox(
                //     width: double.infinity,
                //     child: Column(children: [
                //       const SizedBox(height: 10),
                //       (catController.subCategoryList != null &&
                //               !catController.isSearching)
                //           ? Center(
                //               child: Container(
                //               height: 150,
                //               width: Dimensions.webMaxWidth,
                //               color: Theme.of(context).cardColor,
                //               padding: const EdgeInsets.symmetric(
                //                   vertical: Dimensions.paddingSizeExtraSmall),
                //               child: ListView.builder(
                //                 key: scaffoldKey,
                //                 scrollDirection: Axis.horizontal,
                //                 itemCount: catController.subCategoryList!.length,
                //                 padding: const EdgeInsets.only(
                //                     left: Dimensions.paddingSizeSmall),
                //                 physics: const BouncingScrollPhysics(),
                //                 itemBuilder: (context, index) {
                //                   return InkWell(
                //                     onTap: () =>
                //                         catController.setSubCategoryIndex(
                //                       index,
                //                       widget.categoryID,
                //                     ),
                //                     child: Container(
                //                       padding: const EdgeInsets.symmetric(
                //                         horizontal: Dimensions.paddingSizeSmall,
                //                         vertical:
                //                             Dimensions.paddingSizeExtraSmall,
                //                       ),
                //                       margin: const EdgeInsets.only(
                //                         right: Dimensions.paddingSizeSmall,
                //                       ),
                //                       decoration: BoxDecoration(
                //                         borderRadius: BorderRadius.circular(
                //                           Dimensions.radiusSmall,
                //                         ),
                //                         color: index ==
                //                                 catController.subCategoryIndex
                //                             ? Theme.of(context)
                //                                 .primaryColor
                //                                 .withAlpha((0.1 * 255).toInt())
                //                             : Colors.transparent,
                //                       ),
                //                       child: Column(
                //                           mainAxisAlignment:
                //                               MainAxisAlignment.center,
                //                           children: [
                //                             catController
                //                                 .subCategoryList![index]
                //                                 .imageFullUrl != null?
                //                             CustomImage(
                //                               image: catController
                //                                   .subCategoryList![index]
                //                                   .imageFullUrl!,
                //                               width: 78,
                //                               height: 78,
                //                             ): const SizedBox(  width: 78,
                //                               height: 78,),
                //                             Text(
                //                               catController
                //                                   .subCategoryList![index].name!,
                //                               style: index ==
                //                                       catController
                //                                           .subCategoryIndex
                //                                   ? STCMedium.copyWith(
                //                                       fontSize: Dimensions
                //                                           .fontSizeSmall,
                //                                       color: Theme.of(context)
                //                                           .primaryColor)
                //                                   : STCRegular.copyWith(
                //                                       fontSize: Dimensions
                //                                           .fontSizeSmall),
                //                             ),
                //                           ]),
                //                     ),
                //                   );
                //                 },
                //               ),
                //             ))
                //           : const SizedBox(),
                //       Center(
                //           child: Container(
                //         width: Dimensions.webMaxWidth,
                //         color: Theme.of(context).cardColor,
                //         child: TabBar(
                //           controller: _tabController,
                //           indicatorColor: Theme.of(context).primaryColor,
                //           indicatorWeight: 3,
                //           labelColor: Theme.of(context).primaryColor,
                //           unselectedLabelColor: Theme.of(context).disabledColor,
                //           unselectedLabelStyle: STCRegular.copyWith(
                //               color: Theme.of(context).disabledColor,
                //               fontSize: 18),
                //           labelStyle: STCBold.copyWith(
                //               fontSize: 18,
                //               color: Theme.of(context).primaryColor),
                //           tabs: [
                //             Tab(
                //                 text: Get.find<SplashController>()
                //                         .configModel!
                //                         .moduleConfig!
                //                         .module!
                //                         .showRestaurantText!
                //                     ? 'restaurants'.tr
                //                     : 'stores'.tr),
                //             Tab(text: 'item'.tr),
                //           ],
                //         ),
                //       )),
                //       Expanded(
                //           child: NotificationListener(
                //         onNotification: (dynamic scrollNotification) {
                //           if (scrollNotification is ScrollEndNotification) {
                //             if ((_tabController!.index == 1 &&
                //                     !catController.isStore) ||
                //                 _tabController!.index == 0 &&
                //                     catController.isStore) {
                //               catController
                //                   .setRestaurant(_tabController!.index == 1);
                //               if (catController.isSearching) {
                //                 catController.searchData(
                //                   catController.searchText,
                //                   catController.subCategoryIndex == 0
                //                       ? widget.categoryID
                //                       : catController
                //                           .subCategoryList![
                //                               catController.subCategoryIndex]
                //                           .id
                //                           .toString(),
                //                   catController.type,
                //                 );
                //               } else {
                //                 if (_tabController!.index == 1) {
                //                   catController.getCategoryStoreList(
                //                     catController.subCategoryIndex == 0
                //                         ? widget.categoryID
                //                         : catController
                //                             .subCategoryList![
                //                                 catController.subCategoryIndex]
                //                             .id
                //                             .toString(),
                //                     1,
                //                     catController.type,
                //                     false,
                //                   );
                //                 } else {
                //                   catController.getCategoryItemList(
                //                     catController.subCategoryIndex == 0
                //                         ? widget.categoryID
                //                         : catController
                //                             .subCategoryList![
                //                                 catController.subCategoryIndex]
                //                             .id
                //                             .toString(),
                //                     1,
                //                     catController.type,
                //                     false,
                //                   );
                //                 }
                //               }
                //             }
                //           }
                //           return false;
                //         },
                //         child: TabBarView(
                //           controller: _tabController,
                //           children: [
                //             SingleChildScrollView(
                //               controller: storeScrollController,
                //               child: ItemsView(
                //                 isStore: true,
                //                 items: null,
                //                 stores: stores,
                //                 noDataText: Get.find<SplashController>()
                //                         .configModel!
                //                         .moduleConfig!
                //                         .module!
                //                         .showRestaurantText!
                //                     ? 'no_category_restaurant_found'.tr
                //                     : 'no_category_store_found'.tr,
                //               ),
                //             ),
                //             SingleChildScrollView(
                //               controller: scrollController,
                //               child: ItemsView(
                //                 isStore: false,
                //                 items: item,
                //                 stores: null,
                //                 noDataText: 'no_category_item_found'.tr,
                //               ),
                //             ),
                //           ],
                //         ),
                //       )),
                //       catController.isLoading
                //           ? Center(
                //               child: Padding(
                //               padding: const EdgeInsets.all(
                //                   Dimensions.paddingSizeSmall),
                //               child: CircularProgressIndicator(
                //                   valueColor: AlwaysStoppedAnimation<Color>(
                //                       Theme.of(context).primaryColor)),
                //             ))
                //           : const SizedBox(),
                //     ]),
                //   ),
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                  // color: Colors.red,
                                  height: 158,
                                  child: catController.categoryList != null
                                      ? ListView.builder(
                                          controller: scrollController,
                                          itemCount: catController
                                              .categoryList!.length,
                                          padding: const EdgeInsets.only(
                                            left: Dimensions.paddingSizeSmall,
                                            top: Dimensions.paddingSizeDefault,
                                          ),
                                          physics:
                                              const BouncingScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, index) {
                                            final String catId = catController
                                                .categoryList![index].id
                                                .toString();

                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: Dimensions
                                                      .paddingSizeDefault,
                                                  right: Dimensions
                                                      .paddingSizeSmall,
                                                  top: Dimensions
                                                      .paddingSizeDefault),
                                              child: InkWell(
                                                onTap: () async {
                                                  catController
                                                      .setSelectedCategoryStores(
                                                    selectedCatId:
                                                        catId.toString(),
                                                  );
                                                  SharedPreferences
                                                      sharedPreferences =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  final moduleID =
                                                      sharedPreferences
                                                              .getString(
                                                                  "moduleId") ??
                                                          '2';
                                                  // log("current module id is: $moduleID");
                                                  log(showRestaurantText!
                                                      ? "true"
                                                      : "false");
                                                  log(ModuleHelper.getModule()!
                                                          .id!
                                                          .toString() +
                                                      AppConstants
                                                          .restaurantModuleId);

                                                  // changeSelectedCategory(
                                                  //   categoryId:
                                                  //       catId.toString(),
                                                  // );
                                                  // setState(() {
                                                  //   selectedCat = index;
                                                  // });
                                                  // log("Selected Cat...");
                                                  // log(selectedCat.toString());
                                                },
                                                // () {

                                                // Get.toNamed(RouteHelper
                                                //     .getCategoryItemRoute(
                                                //   catController
                                                //       .categoryList![index]
                                                //       .id,
                                                //   catController
                                                //       .categoryList![index]
                                                //       .name!,
                                                // ));
                                                // },
                                                child: Container(
                                                  // color: Colors.green,
                                                  width: 80,
                                                  child: Column(children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        border: catId ==
                                                                catController
                                                                    .selectedCatId
                                                            ? Border.all(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                width: 2,
                                                              )
                                                            : null,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          Dimensions
                                                              .radiusDefault,
                                                        ),
                                                      ),
                                                      child: Container(
                                                        height: 75,
                                                        width: 75,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            100,
                                                          ),
                                                        ),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                    100,
                                                                  ),
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                        .grey,
                                                                    strokeAlign:
                                                                        1,
                                                                    width: 1,
                                                                  )),
                                                          child: Center(
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                100,
                                                              ),
                                                              child:
                                                                  CustomImage(
                                                                image:
                                                                    '${catController.categoryList![index].imageFullUrl}',
                                                                height: 75,
                                                                width: 75,
                                                                fit:
                                                                    BoxFit.fill,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                        right: index == 0
                                                            ? Dimensions
                                                                .paddingSizeExtraSmall
                                                            : 0,
                                                      ),
                                                      child: Text(
                                                        catController
                                                            .categoryList![
                                                                index]
                                                            .name!,
                                                        style: STCBold.copyWith(
                                                          fontWeight: (index ==
                                                                  selectedCat)
                                                              ? FontWeight.bold
                                                              : null,
                                                          // fontSize: 11,
                                                          color: catId ==
                                                                  catController
                                                                      .selectedCatId
                                                              ? Theme.of(
                                                                      context)
                                                                  .primaryColor
                                                              : null,
                                                        ),
                                                        maxLines: 1,
                                                        // Get.find<
                                                        //             LocalizationController>()
                                                        //         .isLtr
                                                        //     ? 1
                                                        //     : 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : SizedBox()
                                  // : CategoryShimmer(
                                  // categoryController:
                                  // catController),
                                  ),
                            ),
                            ResponsiveHelper.isMobile(context)
                                ? const SizedBox()
                                : catController.categoryList != null
                                    ? Column(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (con) => Dialog(
                                                      child: SizedBox(
                                                          height: 550,
                                                          width: 600,
                                                          child: CategoryPopUp(
                                                            categoryController:
                                                                catController,
                                                          ))));
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: Dimensions
                                                      .paddingSizeSmall),
                                              child: CircleAvatar(
                                                radius: 35,
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .primaryColor,
                                                child: Text('view_all'.tr,
                                                    style: TextStyle(
                                                        fontSize: Dimensions
                                                            .paddingSizeDefault,
                                                        color: Theme.of(context)
                                                            .cardColor)),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          )
                                        ],
                                      )
                                    : SizedBox()

                            // : CategoryShimmer(
                            // categoryController:
                            // categoryController),
                          ],
                        ),
                        // Assume selectedCategoryStores is declared somewhere above, e.g.:
// List<Store>? selectedCategoryStores = getMyStores(); // It could be null

// Assuming your catController, Dimensions, CustomImage, and Store model are defined.

// Inside your build method, where catController is accessible:

// You'll need some state in your CategoryController to manage loading/error for selectCatStoreList
// Example properties in CategoryController:
// var isLoadingSelectedStores = true.obs; // Or just a bool and manage with update()
// var selectedStoresErrorMessage = Rx<String?>(null);

// Main conditional rendering block
                        (catController.categoryStoreList !=
                                    null && // Check if the base category has any stores concept
                                catController.categoryStoreList!.isNotEmpty)
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // Align "Stores" title to the left
                                children: [
                                  const Divider(),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                    child: Text(
                                      showRestaurantText!
                                          ? 'restaurants'.tr
                                          : 'stores_title'.tr,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: STCBold.copyWith(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  // Conditional UI based on the state of selectCatStoreList
                                  Obx(() {
                                    // Assuming you make isLoadingSelectedStores and selectedStoresErrorMessage observable
                                    // Or use GetBuilder and check boolean flags if not using Rx observables
                                    if (catController
                                        .isLoadingSelectedStores.value) {
                                      // Check loading state from controller
                                      return Container(
                                        height: 400,
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const CircularProgressIndicator(),
                                            const SizedBox(height: 10),
                                            Text("loading_stores".tr),
                                          ],
                                        ),
                                      );
                                    } else if (catController
                                            .selectedStoresErrorMessage.value !=
                                        null) {
                                      // Check error state
                                      return Container(
                                        height: 400,
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          catController
                                              .selectedStoresErrorMessage
                                              .value!,
                                          // Display error from controller
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.red.shade700),
                                        ),
                                      );
                                    } else if (catController
                                                .selectCatStoreList !=
                                            null &&
                                        catController
                                            .selectCatStoreList!.isNotEmpty) {
                                      // Data is available and not empty, show the GridView
                                      return SizedBox(
                                        width: double.infinity,
                                        child: GridView.builder(
                                          itemCount: catController
                                              .selectCatStoreList!.length,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          padding: const EdgeInsets.all(12.0),
                                          shrinkWrap: true,
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 8,
                                            mainAxisSpacing: 6,
                                            childAspectRatio:
                                                0.70, // Adjust this: width / height
                                          ),
                                          itemBuilder: (context, i) {
                                            // This check is good for safety, though itemCount should handle it
                                            if (catController
                                                        .selectCatStoreList ==
                                                    null ||
                                                i >=
                                                    catController
                                                        .selectCatStoreList!
                                                        .length) {
                                              return const SizedBox.shrink();
                                            }
                                            Store store = catController
                                                .selectCatStoreList![i];

                                            return Card(
                                              elevation: 2,
                                              clipBehavior: Clip.antiAlias,
                                              // Ensures content respects card's rounded corners
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  Dimensions.radiusSmall,
                                                ),
                                              ),
                                              child: InkWell(
                                                // Make card tappable
                                                onTap: () {
                                                  if (store != null) {
                                                    log("I am in store is not null...........");
                                                    if (Get.find<
                                                                SplashController>()
                                                            .moduleList !=
                                                        null) {
                                                      log("I am in store module list is not null...........");

                                                      for (ModuleModel module
                                                          in Get.find<
                                                                  SplashController>()
                                                              .moduleList!) {
                                                        if (module.id ==
                                                            store!.moduleId) {
                                                          log("i am in for if statement ...........");

                                                          Get.find<
                                                                  SplashController>()
                                                              .setModule(
                                                                  module);
                                                          break;
                                                        }
                                                      }
                                                    }
                                                    log("Store Id is: ${store!.id.toString()}");
                                                    Get.toNamed(
                                                      RouteHelper.getStoreRoute(
                                                          id: store!.id,
                                                          page: 'item'),
                                                      arguments: StoreScreen(
                                                        store: store,
                                                        fromModule: false,
                                                        isNewSuperMarket:
                                                            store.moduleId == 1
                                                                ? true
                                                                : false,
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  // Make children stretch horizontally
                                                  children: [
                                                    const SizedBox(height: 12),
                                                    Container(
                                                      // color: Colors.red,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12.0),
                                                      height: 90,
                                                      width: 90,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100),
                                                        child: CustomImage(
                                                          image: store
                                                                  .logoFullUrl ??
                                                              '',
                                                          height: 90,
                                                          width: 90,
                                                          fit: BoxFit
                                                              .fill, // Make image cover the space well
                                                          // Remove fixed width/height, let Expanded and aspect ratio handle it
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      // Use Expanded for the content part
                                                      flex:
                                                          4, // Adjust flex values
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          // Distribute space
                                                          children: [
                                                            Text(
                                                              store.name ??
                                                                  "status_not_applicable"
                                                                      .tr,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 14),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            Text(
                                                              store.address ??
                                                                  "status_not_applicable"
                                                                      .tr,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 12),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            const Divider(),
                                                            // Row(
                                                            //   mainAxisAlignment:
                                                            //       MainAxisAlignment
                                                            //           .center,
                                                            //   children: [
                                                            //     // const Icon(
                                                            //     //     Icons.star,
                                                            //     //     size: 16,),
                                                            //     const SizedBox(
                                                            //         width: 4),
                                                            //     Text(
                                                            //       '${store.avgRating?.toStringAsFixed(1) ?? "status_not_applicable".tr}',
                                                            //       style: const TextStyle(
                                                            //           fontWeight:
                                                            //               FontWeight
                                                            //                   .bold,
                                                            //           fontSize:
                                                            //               13),
                                                            //     ),
                                                            //     Text(
                                                            //       store.ratingCount !=
                                                            //               null
                                                            //           ? (store.ratingCount! >
                                                            //                   100)
                                                            //               ? " [100+]"
                                                            //               : " [${store.ratingCount.toString()}]"
                                                            //           : "",
                                                            //       style:
                                                            //           const TextStyle(
                                                            //         color: Colors
                                                            //             .grey,
                                                            //         fontWeight:
                                                            //             FontWeight
                                                            //                 .w500,
                                                            //         fontSize:
                                                            //             12,
                                                            //       ),
                                                            //     ),
                                                            //   ],
                                                            // ),
                                                            (store.active ==
                                                                    false)
                                                                ? Text(
                                                                    'status_closed'
                                                                        .tr,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .red,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        fontSize:
                                                                            12),
                                                                  )
                                                                : Text(
                                                                    "status_open"
                                                                        .tr,
                                                                    style: TextStyle(
                                                                        color: Theme.of(context)
                                                                            .primaryColor,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        fontSize:
                                                                            12),
                                                                  ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    } else {
                                      // selectCatStoreList is null or empty, but no error and not loading
                                      return Container(
                                        height:
                                            200, // Give some height to the message
                                        alignment: Alignment.center,
                                        child: Text(
                                          "no_stores_match_filter".tr,
                                        ), // Message for empty filtered list
                                      );
                                    }
                                  }),
                                ],
                              )
                            : Container(
                                // Fallback for when catController.categoryStoreList is null or empty
                                height: 200, // Give some height for the message
                                alignment: Alignment.center,
                                child: Text(
                                    catController
                                            .isLoading // Assuming a general loading flag for the category itself
                                        ? "loading_stores".tr
                                        : "no_stores_found_category".tr,
                                    textAlign: TextAlign.center),
                              ),

                        // (catController.categoryStoreList != null &&
                        //         catController.categoryStoreList!
                        //             .isNotEmpty) // << CORRECTED CONDITION
                        //     ? Column(
                        //         children: [
                        //           const Divider(),
                        //           const Text(
                        //             "Stores",
                        //             style: TextStyle(
                        //               fontWeight: FontWeight.bold,
                        //             ),
                        //           ),
                        //           Container(
                        //               height: 400,
                        //               width: double.infinity,
                        //               // color: Colors.red, // For debugging, good
                        //               child: ListView.builder(
                        //                   // Since we've confirmed selectedCategoryStores is not null and not empty,
                        //                   // selectedCategoryStores.length is safe here without '!'
                        //                   // but for absolute clarity with the type system, selectedCategoryStores! can be used.
                        //                   itemCount: catController
                        //                       .selectCatStoreList!.length,
                        //                   physics:
                        //                       const BouncingScrollPhysics(),
                        //                   // stores.length,
                        //                   shrinkWrap: true,
                        //                   scrollDirection: Axis.horizontal,
                        //                   itemBuilder: (context, i) {
                        //                     Store store = catController
                        //                         .selectCatStoreList![i];
                        //                     // Accessing by index is also safe now
                        //                     // final Store store = selectedCategoryStores![i]; // or selectedCategoryStores[i] if type promotion works
                        //                     return Padding(
                        //                       // Added Padding for better visual separation of items
                        //                       padding:
                        //                           const EdgeInsets.all(8.0),
                        //                       child: Container(
                        //                         padding:
                        //                             const EdgeInsets.all(8),
                        //                         decoration: BoxDecoration(
                        //                             // color: Colors.green,
                        //
                        //                             borderRadius:
                        //                                 BorderRadius.circular(
                        //                                     Dimensions
                        //                                         .radiusDefault),
                        //                             border: Border.all(
                        //                               color: Colors.grey,
                        //                             )),
                        //                         width: 120,
                        //                         child: Column(
                        //                           crossAxisAlignment:
                        //                               CrossAxisAlignment.center,
                        //                           // Align text to the start
                        //                           children: [
                        //                             ClipRRect(
                        //                               borderRadius:
                        //                                   BorderRadius.circular(
                        //                                       100),
                        //                               child: CustomImage(
                        //                                 image:
                        //                                     store.logoFullUrl!,
                        //                                 width: 70,
                        //                                 height: 70,
                        //                               ),
                        //                             ),
                        //                             const SizedBox(height: 3),
                        //                             Text(
                        //                                 store.name ??
                        //                                     "status_not_applicable"
                        //                                         .tr,
                        //                                 style: const TextStyle(
                        //                                     fontWeight:
                        //                                         FontWeight
                        //                                             .bold)),
                        //                             Text(
                        //                                 store.address ??
                        //                                     "status_not_applicable"
                        //                                         .tr,
                        //                                 style: const TextStyle(
                        //                                   color: Colors.grey,
                        //                                   fontSize: 13,
                        //                                 )),
                        //                             Text(
                        //                               store.slug ??
                        //                                   "status_not_applicable"
                        //                                       .tr,
                        //                               style: const TextStyle(
                        //                                 color: Colors.grey,
                        //                                 fontSize: 13,
                        //                               ),
                        //                             ),
                        //                             const Divider(),
                        //                             Row(
                        //                               mainAxisAlignment:
                        //                                   MainAxisAlignment
                        //                                       .center,
                        //                               children: [
                        //                                 const Icon(
                        //                                   Icons.star,
                        //                                   size: 18,
                        //                                 ),
                        //                                 const SizedBox(
                        //                                     width: 6),
                        //                                 Text(
                        //                                   '${store.avgRating ?? "status_not_applicable".tr}',
                        //                                   style:
                        //                                       const TextStyle(
                        //                                           fontWeight:
                        //                                               FontWeight
                        //                                                   .bold,
                        //                                           fontSize: 14),
                        //                                 ),
                        //                                 Text(
                        //                                   (store.ratingCount! >
                        //                                           100)
                        //                                       ? "[100+]"
                        //                                       : " [${store.ratingCount.toString()}]",
                        //                                   style:
                        //                                       const TextStyle(
                        //                                     color: Colors.grey,
                        //                                     fontWeight:
                        //                                         FontWeight.w500,
                        //                                     fontSize: 13,
                        //                                   ),
                        //                                 )
                        //                               ],
                        //                             ),
                        //                             (store.active == false)
                        //                                 ? Text(
                        //                                     'status_closed'.tr,
                        //                                     style: const TextStyle(
                        //                                         color:
                        //                                             Colors.red,
                        //                                         fontWeight:
                        //                                             FontWeight
                        //                                                 .w500,
                        //                                         fontSize: 13),
                        //                                   )
                        //                                 : Text(
                        //                                     "status_open".tr,
                        //                                     style: TextStyle(
                        //                                         color: Theme.of(
                        //                                                 context)
                        //                                             .primaryColor,
                        //                                         fontWeight:
                        //                                             FontWeight
                        //                                                 .w500,
                        //                                         fontSize: 13),
                        //                                   )
                        //                           ],
                        //                         ),
                        //                       ),
                        //                     );
                        //                   })),
                        //         ],
                        //       )
                        //     : const Center(child: Text("empty or null")),
                        // More descriptive text
                      ],
                    ),
                  )),
      );
    });
  }
}

// import 'package:flutter/foundation.dart';
// import 'package:sixam_mart/common/widgets/footer_view.dart';
// import 'package:sixam_mart/features/category/controllers/category_controller.dart';
// import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
// import 'package:sixam_mart/features/item/domain/models/item_model.dart';
// import 'package:sixam_mart/features/store/domain/models/store_model.dart';
// import 'package:sixam_mart/helper/responsive_helper.dart';
// import 'package:sixam_mart/helper/route_helper.dart';
// import 'package:sixam_mart/util/dimensions.dart';
// import 'package:sixam_mart/util/styles.dart';
// import 'package:sixam_mart/common/widgets/cart_widget.dart';
// import 'package:sixam_mart/common/widgets/item_view.dart';
// import 'package:sixam_mart/common/widgets/menu_drawer.dart';
// import 'package:sixam_mart/common/widgets/veg_filter_widget.dart';
// import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class CategoryItemScreen extends StatefulWidget {
//   final String? categoryID;
//   final String categoryName;
//   const CategoryItemScreen(
//       {super.key, required this.categoryID, required this.categoryName});
//
//   @override
//   CategoryItemScreenState createState() => CategoryItemScreenState();
// }
//
// class CategoryItemScreenState extends State<CategoryItemScreen>
//     with TickerProviderStateMixin {
//   final ScrollController scrollController = ScrollController();
//   final ScrollController storeScrollController = ScrollController();
//   TabController? _tabController;
//   final scaffoldKey = GlobalKey<ScaffoldState>();
//
//   @override
//   void initState() {
//     super.initState();
//
//     _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
//     Get.find<CategoryController>().getSubCategoryList(widget.categoryID);
//
//     Get.find<CategoryController>().getCategoryStoreList(
//       widget.categoryID,
//       1,
//       Get.find<CategoryController>().type,
//       false,
//     );
//
//     scrollController.addListener(() {
//       if (scrollController.position.pixels ==
//           scrollController.position.maxScrollExtent &&
//           Get.find<CategoryController>().categoryItemList != null &&
//           !Get.find<CategoryController>().isLoading) {
//         int pageSize = (Get.find<CategoryController>().pageSize! / 10).ceil();
//         if (Get.find<CategoryController>().offset < pageSize) {
//           if (kDebugMode) {
//             print('end of the page');
//           }
//           Get.find<CategoryController>().showBottomLoader();
//           Get.find<CategoryController>().getCategoryItemList(
//             Get.find<CategoryController>().subCategoryIndex == 0
//                 ? widget.categoryID
//                 : Get.find<CategoryController>()
//                 .subCategoryList![
//             Get.find<CategoryController>().subCategoryIndex]
//                 .id
//                 .toString(),
//             Get.find<CategoryController>().offset + 1,
//             Get.find<CategoryController>().type,
//             false,
//           );
//         }
//       }
//     });
//     storeScrollController.addListener(() {
//       if (storeScrollController.position.pixels ==
//           storeScrollController.position.maxScrollExtent &&
//           Get.find<CategoryController>().categoryStoreList != null &&
//           !Get.find<CategoryController>().isLoading) {
//         int pageSize =
//         (Get.find<CategoryController>().restPageSize! / 10).ceil();
//         if (Get.find<CategoryController>().offset < pageSize) {
//           if (kDebugMode) {
//             print('end of the page');
//           }
//           Get.find<CategoryController>().showBottomLoader();
//           Get.find<CategoryController>().getCategoryStoreList(
//             Get.find<CategoryController>().subCategoryIndex == 0
//                 ? widget.categoryID
//                 : Get.find<CategoryController>()
//                 .subCategoryList![
//             Get.find<CategoryController>().subCategoryIndex]
//                 .id
//                 .toString(),
//             Get.find<CategoryController>().offset + 1,
//             Get.find<CategoryController>().type,
//             false,
//           );
//         }
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<CategoryController>(builder: (catController) {
//       List<Item>? item;
//       List<Store>? stores;
//       if (catController.isSearching
//           ? catController.searchItemList != null
//           : catController.categoryItemList != null) {
//         item = [];
//         if (catController.isSearching) {
//           item.addAll(catController.searchItemList!);
//         } else {
//           item.addAll(catController.categoryItemList!);
//         }
//       }
//       if (catController.isSearching
//           ? catController.searchStoreList != null
//           : catController.categoryStoreList != null) {
//         stores = [];
//         if (catController.isSearching) {
//           stores.addAll(catController.searchStoreList!);
//         } else {
//           stores.addAll(catController.categoryStoreList!);
//         }
//       }
//
//       return PopScope(
//         canPop: true,
//         onPopInvokedWithResult: (didPop, result) async {
//           if (catController.isSearching) {
//             catController.toggleSearch();
//           } else {
//             return;
//           }
//         },
//         child: Scaffold(
//           appBar: (ResponsiveHelper.isDesktop(context)
//               ? const WebMenuBar()
//               : AppBar(
//             backgroundColor: Theme.of(context).cardColor,
//             surfaceTintColor: Theme.of(context).cardColor,
//             shadowColor:
//             Theme.of(context).disabledColor.withAlpha((0.5 * 255).toInt()),
//             elevation: 2,
//             title: catController.isSearching
//                 ? SizedBox(
//               height: 45,
//               child: TextField(
//                   autofocus: true,
//                   textInputAction: TextInputAction.search,
//                   decoration: InputDecoration(
//                     hintText: 'Search...',
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(
//                           Dimensions.radiusDefault),
//                       borderSide: BorderSide(
//                           color: Theme.of(context).disabledColor),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(
//                           Dimensions.radiusDefault),
//                       borderSide: BorderSide(
//                           color: Theme.of(context).disabledColor),
//                     ),
//                     suffixIcon: IconButton(
//                       onPressed: () => catController.toggleSearch(),
//                       icon: Icon(
//                         catController.isSearching
//                             ? Icons.close_sharp
//                             : Icons.search,
//                         color: Theme.of(context).disabledColor,
//                       ),
//                     ),
//                   ),
//                   style: STCRegular.copyWith(
//                       fontSize: Dimensions.fontSizeLarge),
//                   onSubmitted: (String query) {
//                     catController.searchData(
//                       query,
//                       catController.subCategoryIndex == 0
//                           ? widget.categoryID
//                           : catController
//                           .subCategoryList![
//                       catController.subCategoryIndex]
//                           .id
//                           .toString(),
//                       catController.type,
//                     );
//                   }),
//             )
//                 : Text(widget.categoryName,
//                 style: STCRegular.copyWith(
//                   fontSize: Dimensions.fontSizeLarge,
//                   color: Theme.of(context).textTheme.bodyLarge!.color,
//                 )),
//             centerTitle: false,
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back_ios),
//               color: Theme.of(context).textTheme.bodyLarge!.color,
//               onPressed: () {
//                 if (catController.isSearching) {
//                   catController.toggleSearch();
//                 } else {
//                   Get.back();
//                 }
//               },
//             ),
//             actions: [
//               !catController.isSearching
//                   ? IconButton(
//                 onPressed: () => catController.toggleSearch(),
//                 icon: Icon(
//                   catController.isSearching
//                       ? Icons.close_sharp
//                       : Icons.search,
//                   color:
//                   Theme.of(context).textTheme.bodyLarge!.color,
//                 ),
//               )
//                   : const SizedBox(),
//               IconButton(
//                 onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
//                 icon: CartWidget(
//                     color: Theme.of(context).textTheme.bodyLarge!.color,
//                     size: 25),
//               ),
//               VegFilterWidget(
//                   type: catController.type,
//                   fromAppBar: true,
//                   onSelected: (String type) {
//                     if (catController.isSearching) {
//                       catController.searchData(
//                         catController.subCategoryIndex == 0
//                             ? widget.categoryID
//                             : catController
//                             .subCategoryList![
//                         catController.subCategoryIndex]
//                             .id
//                             .toString(),
//                         '1',
//                         type,
//                       );
//                     } else {
//                       if (catController.isStore) {
//                         catController.getCategoryStoreList(
//                           catController.subCategoryIndex == 0
//                               ? widget.categoryID
//                               : catController
//                               .subCategoryList![
//                           catController.subCategoryIndex]
//                               .id
//                               .toString(),
//                           1,
//                           type,
//                           true,
//                         );
//                       } else {
//                         catController.getCategoryItemList(
//                           catController.subCategoryIndex == 0
//                               ? widget.categoryID
//                               : catController
//                               .subCategoryList![
//                           catController.subCategoryIndex]
//                               .id
//                               .toString(),
//                           1,
//                           type,
//                           true,
//                         );
//                       }
//                     }
//                   }),
//               const SizedBox(width: Dimensions.paddingSizeSmall),
//             ],
//           )),
//           endDrawer: const MenuDrawer(),
//           endDrawerEnableOpenDragGesture: false,
//           body: ResponsiveHelper.isDesktop(context)
//               ? SingleChildScrollView(
//             child: FooterView(
//               child: Center(
//                   child: SizedBox(
//                     width: Dimensions.webMaxWidth,
//                     child: Column(children: [
//                       (catController.subCategoryList != null &&
//                           !catController.isSearching)
//                           ? Center(
//                           child: Container(
//                             height: 40,
//                             width: Dimensions.webMaxWidth,
//                             color: Theme.of(context).cardColor,
//                             padding: const EdgeInsets.symmetric(
//                                 vertical: Dimensions.paddingSizeExtraSmall),
//                             child: ListView.builder(
//                               key: scaffoldKey,
//                               scrollDirection: Axis.horizontal,
//                               itemCount:
//                               catController.subCategoryList!.length,
//                               padding: const EdgeInsets.only(
//                                   left: Dimensions.paddingSizeSmall),
//                               physics: const BouncingScrollPhysics(),
//                               itemBuilder: (context, index) {
//                                 return InkWell(
//                                   onTap: () =>
//                                       catController.setSubCategoryIndex(
//                                           index, widget.categoryID),
//                                   child: Container(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal:
//                                         Dimensions.paddingSizeSmall,
//                                         vertical: Dimensions
//                                             .paddingSizeExtraSmall),
//                                     margin: const EdgeInsets.only(
//                                         right: Dimensions.paddingSizeSmall),
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(
//                                           Dimensions.radiusSmall),
//                                       color: index ==
//                                           catController.subCategoryIndex
//                                           ? Theme.of(context)
//                                           .primaryColor
//                                           .withAlpha((0.1 * 255).toInt())
//                                           : Colors.transparent,
//                                     ),
//                                     child: Column(
//                                         mainAxisAlignment:
//                                         MainAxisAlignment.center,
//                                         children: [
//                                           Text(
//                                             catController
//                                                 .subCategoryList![index]
//                                                 .name!,
//                                             style: index ==
//                                                 catController
//                                                     .subCategoryIndex
//                                                 ? STCMedium.copyWith(
//                                                 fontSize: Dimensions
//                                                     .fontSizeSmall,
//                                                 color: Theme.of(context)
//                                                     .primaryColor)
//                                                 : STCRegular.copyWith(
//                                                 fontSize: Dimensions
//                                                     .fontSizeSmall),
//                                           ),
//                                         ]),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ))
//                           : const SizedBox(),
//                       Center(
//                           child: Container(
//                             width: Dimensions.webMaxWidth,
//                             color: Theme.of(context).cardColor,
//                             child: TabBar(
//                               controller: _tabController,
//                               indicatorColor: Theme.of(context).primaryColor,
//                               indicatorWeight: 3,
//                               labelColor: Theme.of(context).primaryColor,
//                               unselectedLabelColor: Theme.of(context).disabledColor,
//                               unselectedLabelStyle: STCBold.copyWith(
//                                 color: Theme.of(context).disabledColor,
//                                 fontSize: 20,
//                               ),
//                               labelStyle: STCBold.copyWith(
//                                 fontSize: 20,
//                                 color: Theme.of(context).primaryColor,
//                               ),
//                               tabs: [
//                                 // ← اجعل "المطاعم / المتاجر" أول تبويب
//                                 Tab(
//                                   text: Get.find<SplashController>()
//                                       .configModel!
//                                       .moduleConfig!
//                                       .module!
//                                       .showRestaurantText!
//                                       ? 'restaurants'.tr
//                                       : 'stores'.tr,
//                                 ),
//                                 // ← ثم الوجبات
//                                 Tab(text: 'item'.tr),
//                               ],
//                             ),
//
//                           )),
//                       SizedBox(
//                         height: 600,
//                         child: NotificationListener(
//                           onNotification: (dynamic scrollNotification) {
//                             if (scrollNotification is ScrollEndNotification) {
//                               if ((_tabController!.index == 1 &&
//                                   !catController.isStore) ||
//                                   _tabController!.index == 0 &&
//                                       catController.isStore) {
//                                 catController.setRestaurant(
//                                     _tabController!.index == 1);
//                                 if (catController.isSearching) {
//                                   catController.searchData(
//                                     catController.searchText,
//                                     catController.subCategoryIndex == 0
//                                         ? widget.categoryID
//                                         : catController
//                                         .subCategoryList![catController
//                                         .subCategoryIndex]
//                                         .id
//                                         .toString(),
//                                     catController.type,
//                                   );
//                                 } else {
//                                   if (_tabController!.index == 1) {
//                                     catController.getCategoryStoreList(
//                                       catController.subCategoryIndex == 0
//                                           ? widget.categoryID
//                                           : catController
//                                           .subCategoryList![catController
//                                           .subCategoryIndex]
//                                           .id
//                                           .toString(),
//                                       1,
//                                       catController.type,
//                                       false,
//                                     );
//                                   } else {
//                                     catController.getCategoryItemList(
//                                       catController.subCategoryIndex == 0
//                                           ? widget.categoryID
//                                           : catController
//                                           .subCategoryList![catController
//                                           .subCategoryIndex]
//                                           .id
//                                           .toString(),
//                                       1,
//                                       catController.type,
//                                       false,
//                                     );
//                                   }
//                                 }
//                               }
//                             }
//                             return false;
//                           },
//                           child: TabBarView(
//                             controller: _tabController,
//                             children: [
//                               SingleChildScrollView(
//                                 controller: storeScrollController,
//                                 child: ItemsView(
//                                   isStore: true,
//                                   items: null,
//                                   stores: stores,
//                                   noDataText: Get.find<SplashController>()
//                                       .configModel!
//                                       .moduleConfig!
//                                       .module!
//                                       .showRestaurantText!
//                                       ? 'no_category_restaurant_found'.tr
//                                       : 'no_category_store_found'.tr,
//                                 ),
//                               ), SingleChildScrollView(
//                                 controller: scrollController,
//                                 child: ItemsView(
//                                   isStore: false,
//                                   items: item,
//                                   stores: null,
//                                   noDataText: 'no_category_item_found'.tr,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       catController.isLoading
//                           ? Center(
//                           child: Padding(
//                             padding: const EdgeInsets.all(
//                                 Dimensions.paddingSizeSmall),
//                             child: CircularProgressIndicator(
//                                 valueColor: AlwaysStoppedAnimation<Color>(
//                                     Theme.of(context).primaryColor)),
//                           ))
//                           : const SizedBox(),
//                     ]),
//                   )),
//             ),
//           )
//               : SizedBox(
//             width: Dimensions.webMaxWidth,
//             child: Column(children: [
//               const SizedBox(height: 10),
//               (catController.subCategoryList != null &&
//                   !catController.isSearching)
//                   ? Center(
//                   child: Container(
//                     height: 40,
//                     width: Dimensions.webMaxWidth,
//                     color: Theme.of(context).cardColor,
//                     padding: const EdgeInsets.symmetric(
//                         vertical: Dimensions.paddingSizeExtraSmall),
//                     child: ListView.builder(
//                       key: scaffoldKey,
//                       scrollDirection: Axis.horizontal,
//                       itemCount: catController.subCategoryList!.length,
//                       padding: const EdgeInsets.only(
//                           left: Dimensions.paddingSizeSmall),
//                       physics: const BouncingScrollPhysics(),
//                       itemBuilder: (context, index) {
//                         return InkWell(
//                           onTap: () =>
//                               catController.setSubCategoryIndex(
//                                   index, widget.categoryID),
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: Dimensions.paddingSizeSmall,
//                                 vertical:
//                                 Dimensions.paddingSizeExtraSmall),
//                             margin: const EdgeInsets.only(
//                                 right: Dimensions.paddingSizeSmall),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(
//                                   Dimensions.radiusSmall),
//                               color: index ==
//                                   catController.subCategoryIndex
//                                   ? Theme.of(context)
//                                   .primaryColor
//                                   .withAlpha((0.1 * 255).toInt())
//                                   : Colors.transparent,
//                             ),
//                             child: Column(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     catController
//                                         .subCategoryList![index].name!,
//                                     style: index ==
//                                         catController
//                                             .subCategoryIndex
//                                         ? STCMedium.copyWith(
//                                         fontSize: Dimensions
//                                             .fontSizeSmall,
//                                         color: Theme.of(context)
//                                             .primaryColor)
//                                         : STCRegular.copyWith(
//                                         fontSize: Dimensions
//                                             .fontSizeSmall),
//                                   ),
//                                 ]),
//                           ),
//                         );
//                       },
//                     ),
//                   ))
//                   : const SizedBox(),
//               Center(
//                   child: Container(
//                     width: Dimensions.webMaxWidth,
//                     color: Theme.of(context).cardColor,
//                     child: TabBar(
//                       controller: _tabController,
//                       indicatorColor: Theme.of(context).primaryColor,
//                       indicatorWeight: 3,
//                       labelColor: Theme.of(context).primaryColor,
//                       unselectedLabelColor: Theme.of(context).disabledColor,
//                       unselectedLabelStyle: STCRegular.copyWith(
//                           color: Theme.of(context).disabledColor,
//                           fontSize: 18),
//                       labelStyle: STCBold.copyWith(
//                           fontSize: 18,
//                           color: Theme.of(context).primaryColor),
//                       tabs: [
//                         Tab(
//                             text: Get.find<SplashController>()
//                                 .configModel!
//                                 .moduleConfig!
//                                 .module!
//                                 .showRestaurantText!
//                                 ? 'restaurants'.tr
//                                 : 'stores'.tr),
//                         Tab(text: 'item'.tr),
//
//                       ],
//                     ),
//                   )),
//               Expanded(
//                   child: NotificationListener(
//                     onNotification: (dynamic scrollNotification) {
//                       if (scrollNotification is ScrollEndNotification) {
//                         if ((_tabController!.index == 1 &&
//                             !catController.isStore) ||
//                             _tabController!.index == 0 &&
//                                 catController.isStore) {
//                           catController
//                               .setRestaurant(_tabController!.index == 1);
//                           if (catController.isSearching) {
//                             catController.searchData(
//                               catController.searchText,
//                               catController.subCategoryIndex == 0
//                                   ? widget.categoryID
//                                   : catController
//                                   .subCategoryList![
//                               catController.subCategoryIndex]
//                                   .id
//                                   .toString(),
//                               catController.type,
//                             );
//                           } else {
//                             if (_tabController!.index == 1) {
//                               catController.getCategoryStoreList(
//                                 catController.subCategoryIndex == 0
//                                     ? widget.categoryID
//                                     : catController
//                                     .subCategoryList![
//                                 catController.subCategoryIndex]
//                                     .id
//                                     .toString(),
//                                 1,
//                                 catController.type,
//                                 false,
//                               );
//                             } else {
//                               catController.getCategoryItemList(
//                                 catController.subCategoryIndex == 0
//                                     ? widget.categoryID
//                                     : catController
//                                     .subCategoryList![
//                                 catController.subCategoryIndex]
//                                     .id
//                                     .toString(),
//                                 1,
//                                 catController.type,
//                                 false,
//                               );
//                             }
//                           }
//                         }
//                       }
//                       return false;
//                     },
//                     child: TabBarView(
//                       controller: _tabController,
//                       children: [
//                         SingleChildScrollView(
//                           controller: storeScrollController,
//                           child: ItemsView(
//                             isStore: true,
//                             items: null,
//                             stores: stores,
//                             noDataText: Get.find<SplashController>()
//                                 .configModel!
//                                 .moduleConfig!
//                                 .module!
//                                 .showRestaurantText!
//                                 ? 'no_category_restaurant_found'.tr
//                                 : 'no_category_store_found'.tr,
//                           ),
//                         ),
//                         SingleChildScrollView(
//                           controller: scrollController,
//                           child: ItemsView(
//                             isStore: false,
//                             items: item,
//                             stores: null,
//                             noDataText: 'no_category_item_found'.tr,
//                           ),
//                         ),
//
//                       ],
//                     ),
//                   )),
//               catController.isLoading
//                   ? Center(
//                   child: Padding(
//                     padding: const EdgeInsets.all(
//                         Dimensions.paddingSizeSmall),
//                     child: CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                             Theme.of(context).primaryColor)),
//                   ))
//                   : const SizedBox(),
//             ]),
//           ),
//         ),
//       );
//     });
//   }
// }
