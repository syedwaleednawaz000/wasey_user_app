import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/banner/controllers/banner_controller.dart';
import 'package:sixam_mart/features/brands/controllers/brands_controller.dart';
import 'package:sixam_mart/features/home/controllers/advertisement_controller.dart';
import 'package:sixam_mart/features/home/controllers/home_controller.dart';
import 'package:sixam_mart/features/home/widgets/all_store_filter_widget.dart';
import 'package:sixam_mart/features/home/widgets/cashback_logo_widget.dart';
import 'package:sixam_mart/features/home/widgets/cashback_dialog_widget.dart';
import 'package:sixam_mart/features/home/widgets/refer_bottom_sheet_widget.dart';
import 'package:sixam_mart/features/home/widgets/web/module_widget.dart';
import 'package:sixam_mart/features/item/controllers/campaign_controller.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/coupon/controllers/coupon_controller.dart';
import 'package:sixam_mart/features/flash_sale/controllers/flash_sale_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/menu/screens/menu_screen.dart';
import 'package:sixam_mart/features/notification/controllers/notification_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/features/home/screens/modules/food_home_screen.dart';
import 'package:sixam_mart/features/home/screens/modules/grocery_home_screen.dart';
import 'package:sixam_mart/features/home/screens/modules/pharmacy_home_screen.dart';
import 'package:sixam_mart/features/home/screens/modules/shop_home_screen.dart';
import 'package:sixam_mart/features/parcel/controllers/parcel_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/item_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/paginated_list_view.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:sixam_mart/features/home/screens/web_new_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/home/widgets/module_view.dart';
import 'package:sixam_mart/features/parcel/screens/parcel_category_screen.dart';

import '../../coupon/domain/models/coupon_model.dart';
import '../../dashboard/widgets/bottom_nav_item_widget.dart';
import '../../store/domain/models/category_with_stores.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static Future<void> loadData(bool reload, {bool fromModule = false}) async {
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
      Get.find<BannerController>().getBannerList(reload);
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
    print("getCategoriesWithStoreList called");
    await Get.find<StoreController>()
        .getCategoriesWithStoreList(reload: reload);
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool searchBgShow = false;
  final GlobalKey _headerKey = GlobalKey();

  SplashController splashController = Get.find();

  @override
  void initState() {
    super.initState();

    // splashController.switchModule(1, true);
    // setModuleRestaurant();
    // Get.find<SplashController>().getStoredModule();

    // print("splashController.switchModule(0, true); executed");

    Get.find<HomeController>().loadHomeData(false).then((value) {
      Get.find<SplashController>().getReferBottomSheetStatus();

      if ((Get.find<ProfileController>().userInfoModel?.isValidForDiscount ??
              false) &&
          Get.find<SplashController>().showReferBottomSheet) {
        _showReferBottomSheet();
      }
    });

    if (!ResponsiveHelper.isWeb()) {
      Get.find<LocationController>().getZone(
          AddressHelper.getUserAddressFromSharedPref()!.latitude,
          AddressHelper.getUserAddressFromSharedPref()!.longitude,
          false,
          updateInAddress: true);
    }

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (Get.find<HomeController>().showFavButton) {
          Get.find<HomeController>().changeFavVisibility();
          Future.delayed(const Duration(milliseconds: 800),
              () => Get.find<HomeController>().changeFavVisibility());
        }
      } else {
        if (Get.find<HomeController>().showFavButton) {
          Get.find<HomeController>().changeFavVisibility();
          Future.delayed(const Duration(milliseconds: 800),
              () => Get.find<HomeController>().changeFavVisibility());
        }
      }
    });
    // Get.find<HomeController>().setModuleRestaurant();
  }

  //
  // setModuleRestaurant() async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   sharedPreferences.setString("moduleId", "2");
  //   splashController.switchModule(1, true);
  //   print("ModuleID is Set to: ${sharedPreferences.getString("moduleId")}");
  //   print("Module setting to 1////////////////////////////////////////");
  //   await sharedPreferences.setString(
  //       AppConstants.moduleId, AppConstants.restaurantModuleId);
  //   print(
  //       "Module settled to ${sharedPreferences.getString(AppConstants.moduleId)}////////////////////////////////////////");
  // }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void _showReferBottomSheet() {
    ResponsiveHelper.isDesktop(context)
        ? Get.dialog(
            Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusExtraLarge)),
              insetPadding: const EdgeInsets.all(22),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: const ReferBottomSheetWidget(),
            ),
            useSafeArea: false,
          ).then((value) =>
            Get.find<SplashController>().saveReferBottomSheetStatus(false))
        : showModalBottomSheet(
            isScrollControlled: true,
            useRootNavigator: true,
            context: Get.context!,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.radiusExtraLarge),
                  topRight: Radius.circular(Dimensions.radiusExtraLarge)),
            ),
            builder: (context) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8),
                child: const ReferBottomSheetWidget(),
              );
            },
          ).then((value) =>
            Get.find<SplashController>().saveReferBottomSheetStatus(false));
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splashController) {
      if (splashController.moduleList != null &&
          splashController.moduleList!.length == 1) {
        // splashController.switchModule(1, true);
        Get.find<HomeController>().setModuleRestaurant();
      }
      bool showMobileModule = !ResponsiveHelper.isDesktop(context) &&
          splashController.module == null &&
          splashController.configModel!.module == null;

      bool isParcel = splashController.module != null &&
          splashController.configModel!.moduleConfig!.module!.isParcel!;
      bool isPharmacy = splashController.module != null &&
          splashController.module!.moduleType.toString() ==
              AppConstants.pharmacy;
      bool isFood = splashController.module != null &&
          splashController.module!.moduleType.toString() == AppConstants.food;
      bool isShop = splashController.module != null &&
          splashController.module!.moduleType.toString() ==
              AppConstants.ecommerce;
      bool isGrocery = splashController.module != null &&
          splashController.module!.moduleType.toString() ==
              AppConstants.grocery;

      return GetBuilder<HomeController>(builder: (homeController) {
        return Scaffold(
          appBar:
              ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
          endDrawer: const MenuDrawer(),
          endDrawerEnableOpenDragGesture: false,
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: isParcel
              ? const ParcelCategoryScreen()
              : SafeArea(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      splashController.setRefreshing(true);
                      print("getCategoriesWithStoreList called");
                      await Get.find<StoreController>()
                          .getCategoriesWithStoreList(reload: true);
                      if (Get.find<SplashController>().module != null) {
                        await Get.find<LocationController>().syncZoneData();
                        await Get.find<BannerController>().getBannerList(true);
                        if (isGrocery) {
                          await Get.find<FlashSaleController>()
                              .getFlashSale(true, true);
                        }
                        await Get.find<BannerController>()
                            .getPromotionalBannerList(true);
                        await Get.find<ItemController>()
                            .getDiscountedItemList(true, false, 'all');
                        await Get.find<CategoryController>()
                            .getCategoryList(true);
                        await Get.find<StoreController>()
                            .getPopularStoreList(true, 'all', false);
                        await Get.find<CampaignController>()
                            .getItemCampaignList(true);
                        Get.find<CampaignController>()
                            .getBasicCampaignList(true);
                        await Get.find<ItemController>()
                            .getPopularItemList(true, 'all', false);
                        await Get.find<StoreController>()
                            .getLatestStoreList(true, 'all', false);
                        await Get.find<StoreController>()
                            .getTopOfferStoreList(true, false);
                        await Get.find<ItemController>()
                            .getReviewedItemList(true, 'all', false);
                        await Get.find<StoreController>().getStoreList(1, true);
                        Get.find<AdvertisementController>()
                            .getAdvertisementList();
                        if (AuthHelper.isLoggedIn()) {
                          await Get.find<ProfileController>().getUserInfo();
                          await Get.find<NotificationController>()
                              .getNotificationList(true);
                          Get.find<CouponController>().getCouponList();
                        }
                        if (isPharmacy) {
                          Get.find<ItemController>()
                              .getBasicMedicine(true, true);
                          Get.find<ItemController>().getCommonConditions(true);
                        }
                        if (isShop) {
                          await Get.find<FlashSaleController>()
                              .getFlashSale(true, true);
                          Get.find<ItemController>()
                              .getFeaturedCategoriesItemList(true, true);
                          Get.find<BrandsController>().getBrandList();
                        }
                      } else {
                        await Get.find<BannerController>().getFeaturedBanner();
                        await Get.find<SplashController>().getModules();
                        if (AuthHelper.isLoggedIn()) {
                          await Get.find<AddressController>().getAddressList();
                        }
                        await Get.find<StoreController>()
                            .getFeaturedStoreList();
                      }
                      splashController.setRefreshing(false);
                    },
                    child: ResponsiveHelper.isDesktop(context)
                        ? WebNewHomeScreen(
                            scrollController: _scrollController,
                          )
                        : CustomScrollView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              /// App Bar
                              SliverAppBar(
                                floating: true,
                                elevation: 0,
                                automaticallyImplyLeading: false,
                                surfaceTintColor:
                                    Theme.of(context).colorScheme.surface,
                                backgroundColor:
                                    ResponsiveHelper.isDesktop(context)
                                        ? Colors.transparent
                                        : Theme.of(context).colorScheme.surface,
                                title: Center(
                                    child: Container(
                                  width: Dimensions.webMaxWidth,
                                  height:
                                      Get.find<LocalizationController>().isLtr
                                          ? 60
                                          : 70,
                                  color: Theme.of(context).colorScheme.surface,
                                  child: Row(children: [
                                    // (splashController.module != null &&
                                    //         splashController
                                    //                 .configModel!.module ==
                                    //             null &&
                                    //         splashController.moduleList !=
                                    //             null &&
                                    //         splashController
                                    //                 .moduleList!.length !=
                                    //             1)
                                    //     ? InkWell(
                                    //         onTap: () {
                                    //           splashController.removeModule();
                                    //           Get.find<StoreController>()
                                    //               .resetStoreData();
                                    //         },
                                    //         child: Image.asset(
                                    //             Images.moduleIcon,
                                    //             height: 25,
                                    //             width: 25,
                                    //             color: Theme.of(context)
                                    //                 .textTheme
                                    //                 .bodyLarge!
                                    //                 .color),
                                    //       )
                                    //     : const SizedBox(),
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(const MenuScreen());
                                      },
                                      child: SizedBox(
                                        width: 45,
                                        // color: Colors.red,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.menu,
                                            ),
                                            Text(
                                              "menu".tr,
                                              style: STCRegular.copyWith(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color!,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        width: (splashController.module !=
                                                    null &&
                                                splashController
                                                        .configModel!.module ==
                                                    null &&
                                                splashController.moduleList !=
                                                    null &&
                                                splashController
                                                        .moduleList!.length !=
                                                    1)
                                            ? Dimensions.paddingSizeSmall
                                            : 0),
                                    Expanded(
                                        child: InkWell(
                                      onTap: () =>
                                          Get.find<LocationController>()
                                              .navigateToLocationScreen('home'),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: Dimensions.paddingSizeSmall,
                                          horizontal:
                                              ResponsiveHelper.isDesktop(
                                                      context)
                                                  ? Dimensions.paddingSizeSmall
                                                  : 0,
                                        ),
                                        child: GetBuilder<LocationController>(
                                            builder: (locationController) {
                                          return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  AuthHelper.isLoggedIn()
                                                      ? AddressHelper
                                                                  .getUserAddressFromSharedPref()!
                                                              .addressType!
                                                              .tr ??
                                                          ""
                                                      : 'your_location'.tr,
                                                  style: STCMedium.copyWith(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .color,
                                                      fontSize: Dimensions
                                                          .fontSizeDefault),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Row(children: [
                                                  Flexible(
                                                    child: Text(
                                                      AddressHelper
                                                                  .getUserAddressFromSharedPref()!
                                                              .address!
                                                              .isNotEmpty
                                                          ? AddressHelper
                                                                  .getUserAddressFromSharedPref()!
                                                              .address!
                                                          : "",
                                                      style: STCRegular.copyWith(
                                                          color: Theme.of(
                                                                  context)
                                                              .disabledColor,
                                                          fontSize: Dimensions
                                                              .fontSizeSmall),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.expand_more,
                                                    color: Theme.of(context)
                                                        .disabledColor,
                                                    size: 18,
                                                  ),
                                                ]),
                                              ]);
                                        }),
                                      ),
                                    )),
                                    IconButton(
                                      onPressed: () => Get.toNamed(
                                          // RouteHelper.getSearchStoreItemRoute(
                                          //   Get.find<StoreController>().store!.id,
                                          // ),
                                          RouteHelper.search),
                                      icon: const Icon(Icons.search_outlined),
                                    ),
                                    // InkWell(
                                    //   child: GetBuilder<NotificationController>(
                                    //       builder: (notificationController) {
                                    //     return Stack(children: [
                                    //       Icon(CupertinoIcons.bell,
                                    //           size: 25,
                                    //           color: Theme.of(context)
                                    //               .textTheme
                                    //               .bodyLarge!
                                    //               .color),
                                    //       notificationController.hasNotification
                                    //           ? Positioned(
                                    //               top: 0,
                                    //               right: 0,
                                    //               child: Container(
                                    //                 height: 10,
                                    //                 width: 10,
                                    //                 decoration: BoxDecoration(
                                    //                   color: Theme.of(context)
                                    //                       .primaryColor,
                                    //                   shape: BoxShape.circle,
                                    //                   border: Border.all(
                                    //                       width: 1,
                                    //                       color:
                                    //                           Theme.of(context)
                                    //                               .cardColor),
                                    //                 ),
                                    //               ))
                                    //           : const SizedBox(),
                                    //     ]);
                                    //   }),
                                    //   onTap: () => Get.toNamed(
                                    //       RouteHelper.getNotificationRoute()),
                                    // ),
                                  ]),
                                )),
                                actions: const [SizedBox()],
                              ),

                              SliverToBoxAdapter(
                                child: Center(
                                    child: SizedBox(
                                  width: Dimensions.webMaxWidth,
                                  child: !showMobileModule
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                              // Container(
                                              //     height: 200,
                                              //     width: double.infinity,
                                              //     color: Colors.green,
                                              //     child: ModuleWidget()),
                                              isGrocery
                                                  ? const GroceryHomeScreen()
                                                  : isPharmacy
                                                      ? const PharmacyHomeScreen()
                                                      : isFood
                                                          ? const FoodHomeScreen()
                                                          // ? Text("data")
                                                          : isShop
                                                              ? const ShopHomeScreen()
                                                              : const SizedBox(),
                                            ])
                                      : ModuleView(
                                          splashController: splashController,
                                        ),
                                )),
                              ),

                              !showMobileModule
                                  ? SliverPersistentHeader(
                                      key: _headerKey,
                                      pinned: true,
                                      delegate: SliverDelegate(
                                        height: 50,
                                        callback: (val) {
                                          searchBgShow = val;
                                        },
                                        child: const AllStoreFilterWidget(),
                                      ),
                                    )
                                  : const SliverToBoxAdapter(),

                              SliverToBoxAdapter(
                                  child: !showMobileModule
                                      ? Column(
                                          children: [
                                            GetBuilder<StoreController>(
                                                builder: (storeController) {
                                              if (storeController
                                                  .isLoadingCategoriesWithStores) {
                                                return const Padding(
                                                  padding: EdgeInsets.all(
                                                      Dimensions
                                                          .paddingSizeDefault),
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                );
                                              }

                                              if (storeController
                                                          .categoryWithStoreList ==
                                                      null ||
                                                  storeController
                                                      .categoryWithStoreList!
                                                      .isEmpty) {
                                                return Padding(
                                                  padding: const EdgeInsets.all(
                                                    Dimensions
                                                        .paddingSizeDefault,
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      const SizedBox(
                                                        height: Dimensions
                                                            .paddingSizeDefault,
                                                      ),
                                                      Center(
                                                        child: Text(
                                                          'no_categories_with_stores_found_yet'
                                                              .tr,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: Dimensions
                                                            .paddingSizeDefault,
                                                      ),
                                                      ElevatedButton.icon(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              Dimensions
                                                                  .paddingSizeSmall,
                                                            ),
                                                          ),
                                                        ),
                                                        label:
                                                            Text("refresh".tr),
                                                        icon: const Icon(
                                                            Icons.refresh),
                                                        onPressed: () async {
                                                          print(
                                                              "getCategoriesWithStoreList called");
                                                          await Get.find<
                                                                  StoreController>()
                                                              .getCategoriesWithStoreList(
                                                                  reload: true);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                              return ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount: storeController
                                                    .categoryWithStoreList!
                                                    .length,
                                                itemBuilder: (context, index) {
                                                  CategoryWithStores
                                                      categoryWithStore =
                                                      storeController
                                                              .categoryWithStoreList![
                                                          index];

                                                  return categoryWithStore
                                                          .stores!.isEmpty
                                                      ? const SizedBox.shrink()
                                                      : Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              // Display the category name
                                                              child: Text(
                                                                categoryWithStore
                                                                        .cName ??
                                                                    '',
                                                                style: STCBold
                                                                    .copyWith(
                                                                        fontSize:
                                                                            20),
                                                              ),
                                                            ),

                                                            ItemsView(
                                                              isStore: true,
                                                              items: null,
                                                              isFromHome: true,
                                                              isFoodOrGrocery:
                                                                  (isFood ||
                                                                      isGrocery),
                                                              stores:
                                                                  categoryWithStore
                                                                      .stores,
                                                              // storeController
                                                              //     .storeModel?.stores,
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                horizontal: ResponsiveHelper
                                                                        .isDesktop(
                                                                            context)
                                                                    ? Dimensions
                                                                        .paddingSizeExtraSmall
                                                                    : Dimensions
                                                                        .paddingSizeSmall,
                                                                vertical: ResponsiveHelper
                                                                        .isDesktop(
                                                                            context)
                                                                    ? Dimensions
                                                                        .paddingSizeExtraSmall
                                                                    : Dimensions
                                                                        .paddingSizeDefault,
                                                              ),
                                                            )
                                                            // Create a horizontal list for the stores in this category
                                                            // SizedBox(
                                                            //   height: 220,
                                                            //   // Adjust height as needed
                                                            //   child: ListView.builder(
                                                            //     scrollDirection:
                                                            //         Axis.horizontal,
                                                            //     shrinkWrap: true,
                                                            //     itemCount:
                                                            //         categoryWithStore
                                                            //                 .stores
                                                            //                 ?.length ??
                                                            //             0,
                                                            //     itemBuilder: (context,
                                                            //         storeIndex) {
                                                            //       final store =
                                                            //           categoryWithStore
                                                            //                   .stores![
                                                            //               storeIndex];
                                                            //       // Use your existing StoreWidget to display the store
                                                            //       return Padding(
                                                            //         padding:
                                                            //             const EdgeInsets
                                                            //                 .symmetric(
                                                            //                 horizontal:
                                                            //                     8.0),
                                                            //         child: Text(store
                                                            //             .name
                                                            //             .toString()),
                                                            //       );
                                                            //     },
                                                            //   ),
                                                            // ),
                                                          ],
                                                        );
                                                },
                                              );
                                            }),
                                            const SizedBox(height: 200),
                                            // Center(
                                            //   child:
                                            //       GetBuilder<StoreController>(
                                            //           builder:
                                            //               (storeController) {
                                            //     return Padding(
                                            //       padding: EdgeInsets.only(
                                            //           bottom: ResponsiveHelper
                                            //                   .isDesktop(
                                            //                       context)
                                            //               ? 0
                                            //               : 100),
                                            //       child: PaginatedListView(
                                            //         scrollController:
                                            //             _scrollController,
                                            //         totalSize: storeController
                                            //             .storeModel?.totalSize,
                                            //         offset: storeController
                                            //             .storeModel?.offset,
                                            //         onPaginate: (int?
                                            //                 offset) async =>
                                            //             await storeController
                                            //                 .getStoreList(
                                            //                     offset!, false),
                                            //         itemView: ItemsView(
                                            //           isStore: true,
                                            //           items: null,
                                            //           isFoodOrGrocery:
                                            //               (isFood || isGrocery),
                                            //           stores: storeController
                                            //               .storeModel?.stores,
                                            //           padding:
                                            //               EdgeInsets.symmetric(
                                            //             horizontal: ResponsiveHelper
                                            //                     .isDesktop(
                                            //                         context)
                                            //                 ? Dimensions
                                            //                     .paddingSizeExtraSmall
                                            //                 : Dimensions
                                            //                     .paddingSizeSmall,
                                            //             vertical: ResponsiveHelper
                                            //                     .isDesktop(
                                            //                         context)
                                            //                 ? Dimensions
                                            //                     .paddingSizeExtraSmall
                                            //                 : Dimensions
                                            //                     .paddingSizeDefault,
                                            //           ),
                                            //         ),
                                            //       ),
                                            //     );
                                            //   }),
                                            // ),
                                          ],
                                        )
                                      : const SizedBox()),
                            ],
                          ),
                  ),
                ),
          floatingActionButton: AuthHelper.isLoggedIn() &&
                  homeController.cashBackOfferList != null &&
                  homeController.cashBackOfferList!.isNotEmpty
              ? homeController.showFavButton
                  ? Padding(
                      padding: EdgeInsets.only(
                          bottom: 50.0,
                          right: ResponsiveHelper.isDesktop(context) ? 50 : 0),
                      child: InkWell(
                        onTap: () => Get.dialog(const CashBackDialogWidget()),
                        child: const CashBackLogoWidget(),
                      ),
                    )
                  : null
              : null,
        );
      });
    });
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;
  Function(bool isPinned)? callback;
  bool isPinned = false;

  SliverDelegate({required this.child, this.height = 50, this.callback});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    isPinned = shrinkOffset == maxExtent /*|| shrinkOffset < maxExtent*/;
    callback!(isPinned);
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height ||
        oldDelegate.minExtent != height ||
        child != oldDelegate.child;
  }
}
