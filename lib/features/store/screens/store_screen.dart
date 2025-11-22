import 'package:flutter/rendering.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/store/component/store_item_view.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/category/domain/models/category_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/store/screens/store_categories_screen.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/item_view.dart';
import 'package:sixam_mart/common/widgets/item_widget.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/veg_filter_widget.dart';
import 'package:sixam_mart/common/widgets/web_item_widget.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:sixam_mart/features/checkout/screens/checkout_screen.dart';
import 'package:sixam_mart/features/search/widgets/custom_check_box_widget.dart';
import 'package:sixam_mart/features/store/widgets/customizable_space_bar_widget.dart';
import 'package:sixam_mart/features/store/widgets/store_banner_widget.dart';
import 'package:sixam_mart/features/store/widgets/store_description_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/store/widgets/store_details_screen_shimmer_widget.dart';

import '../widgets/bottom_cart_widget.dart';

class StoreScreen extends StatefulWidget {
  final Store? store;
  final bool fromModule;
  final String slug;
  final bool isNewSuperMarket;

  const StoreScreen({
    super.key,
    required this.store,
    required this.fromModule,
    this.slug = '',
    this.isNewSuperMarket = false,
  });

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    initDataCall();
  }

  @override
  void dispose() {
    super.dispose();

    scrollController.dispose();
  }

  Future<void> initDataCall() async {
    if (Get.find<StoreController>().isSearching) {
      Get.find<StoreController>().changeSearchStatus(isUpdate: false);
    }
    Get.find<StoreController>().hideAnimation();
    await Get.find<StoreController>()
        .getStoreDetails(Store(id: widget.store!.id), widget.fromModule,
            slug: widget.slug)
        .then((value) {
      Get.find<StoreController>().showButtonAnimation();
    });
    if (Get.find<CategoryController>().categoryList == null) {
      Get.find<CategoryController>().getCategoryList(true);
    }
    Get.find<StoreController>().getStoreBannerList(
        widget.store!.id ?? Get.find<StoreController>().store!.id);
    Get.find<StoreController>().getRestaurantRecommendedItemList(
        widget.store!.id ?? Get.find<StoreController>().store!.id, false);
    Get.find<StoreController>().getStoreItemList(
      widget.store!.id ?? Get.find<StoreController>().store!.id,
      1,
      'all',
      false,
    );

    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (Get.find<StoreController>().showFavButton) {
          Get.find<StoreController>().changeFavVisibility();
          Get.find<StoreController>().hideAnimation();
        }
      } else {
        if (!Get.find<StoreController>().showFavButton) {
          Get.find<StoreController>().changeFavVisibility();
          Get.find<StoreController>().showButtonAnimation();
        }
      }
    });
    // Get.find<StoreController>().getSubCatWithItems();
  }

  @override
  Widget build(BuildContext context) {
    return (widget.isNewSuperMarket && (!ResponsiveHelper.isDesktop(context)))
        ? GetBuilder<StoreController>(builder: (storeController) {
            Store? store;
            if (storeController.store != null) {
              store = storeController.store;
            }
            bool ltr = Get.find<LocalizationController>().isLtr;
            return Scaffold(
              backgroundColor: Theme.of(context).cardColor,
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                leading: const SizedBox.shrink(),
                leadingWidth: 0,
                titleSpacing: 0,
                title: SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: InkWell(
                          onTap: () => Get.back(),
                          child: Container(
                            // height: 50,
                            // width: 50,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).cardColor),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.chevron_left,
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                        ),
                      ),
                      // ... inside your Row or wherever this Flexible widget is ...
                      Flexible(
                        flex: 6,
                        child: GestureDetector(
                          onTap: () {
                            // Ensure 'store' and 'store.id' are not null before navigating
                            if (store != null && store.id != null) {
                              Get.toNamed(RouteHelper.getSearchStoreItemRoute(
                                  store.id!));
                            } else {
                              // Handle the case where store or store.id is null, maybe show a message
                              print(
                                  "Error: Store ID is null, cannot navigate to search.");
                              // Get.snackbar("Error", "Could not initiate search. Store details missing.");
                            }
                          },
                          child: AbsorbPointer(
                            // Makes sure the TextFormField doesn't try to handle taps
                            child: TextFormField(
                              enabled: false,
                              // Disables the TextFormField for input
                              decoration: InputDecoration(
                                hintText: "🔍︎  ${'search_products'.tr}",
                                hintStyle: TextStyle(
                                  color: Theme.of(context).disabledColor,
                                  fontSize: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                fillColor: Theme.of(context).cardColor,
                                filled: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical:
                                      10, // Added some vertical padding to better center hint text
                                ),
                                // To make it look more like a button if `enabled: false` changes its appearance too much:
                                disabledBorder: OutlineInputBorder(
                                  // Define how it looks when disabled
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none, // Keep no border
                                ),
                              ),
                              // style: TextStyle(color: Colors.transparent), // Optional: hides the caret if it still appears
                            ),
                          ),
                        ),
                      ),

                      GetBuilder<StoreController>(builder: (storeController) {
                        return AppConstants.webHostedUrl.isNotEmpty
                            ? Flexible(
                                flex: 1,
                                child: InkWell(
                                  onTap: () {
                                    storeController.shareStore();
                                  },
                                  child: Container(
                                    height: 40,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 6),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context).cardColor),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.share,
                                      size: 17,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink();
                      })
                    ],
                  ),
                ),
              ),
              body: (storeController.store != null &&
                      storeController.store!.name != null)
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            color: Theme.of(context).cardColor,
                            height: 420,
                            child: Stack(
                              children: [
                                Container(
                                  color: Theme.of(context)
                                      .disabledColor
                                      .withOpacity(.2),
                                  child: CustomImage(
                                    fit: BoxFit.cover,
                                    height: 250,
                                    width: double.infinity,
                                    image: store?.coverPhotoFullUrl ?? '',
                                  ),
                                ),
                                Positioned(
                                  bottom: 10,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 210,
                                    margin: const EdgeInsets.only(
                                      left: 8,
                                      right: 8,
                                    ),
                                    padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeSmall,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .cardColor, //Colors.red,
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radiusDefault),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          // Shadow color with some opacity
                                          spreadRadius: 1,
                                          // How far the shadow spreads before blurring
                                          blurRadius: 5,
                                          // How blurry the shadow is
                                          offset: const Offset(0,
                                              3), // changes position of shadow (x, y)
                                          // Offset(0, 3) will move it 3 pixels down
                                          // This will create a shadow primarily at the bottom
                                          // and slightly on the sides due to blur.
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              child: CustomImage(
                                                image: store!.logoFullUrl ?? '',
                                                height: 40,
                                                width: 40,
                                              ),
                                            ),
                                            GetBuilder<FavouriteController>(
                                                builder: (favouriteController) {
                                              bool isWished =
                                                  favouriteController
                                                      .wishStoreIdList
                                                      .contains(store!.id);
                                              return InkWell(
                                                onTap: () {
                                                  if (AuthHelper.isLoggedIn()) {
                                                    isWished
                                                        ? favouriteController
                                                            .removeFromFavouriteList(
                                                                store!.id, true)
                                                        : favouriteController
                                                            .addToFavouriteList(
                                                                null,
                                                                store?.id,
                                                                true);
                                                  } else {
                                                    showCustomSnackBar(
                                                        'you_are_not_logged_in'
                                                            .tr);
                                                  }
                                                },
                                                child: Icon(
                                                  isWished
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  size: 24,
                                                  color: isWished
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : Theme.of(context)
                                                          .disabledColor,
                                                ),
                                              );
                                            }),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              store.name ?? '',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Get.to(StoreCategoriesScreen(
                                                    store: store));
                                              },
                                              child: Icon(
                                                ltr
                                                    ? Icons
                                                        .arrow_forward_ios_outlined
                                                    : Icons
                                                        .arrow_back_ios_new_outlined,
                                                size: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Align(
                                          alignment: ltr
                                              ? Alignment.topLeft
                                              : Alignment.topRight,
                                          child: Text(
                                            store.address ??
                                                "status_not_applicable".tr,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w300,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Align(
                                          alignment: ltr
                                              ? Alignment.topLeft
                                              : Alignment.topRight,
                                          child: Text(
                                            ((store.open == 1) &&
                                                    (store.active == 1))
                                                ? 'status_open'.tr
                                                : store.active == -1
                                                    ? "temporarily_closed_label".tr
                                                    : "closed_now".tr,
                                            style: TextStyle(
                                              color: ((store.open == 1) &&
                                                      (store.active == 1))
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                        Divider(
                                          color: Theme.of(context).dividerColor,
                                          thickness: .15,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Column(
                                              children: [
                                                const Icon(
                                                  Icons.delivery_dining,
                                                  size: 18,
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  store.deliveryTime ??
                                                      "status_not_applicable"
                                                          .tr,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                )
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                const Icon(
                                                  Icons
                                                      .access_time_filled_outlined,
                                                  size: 18,
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  store.storeOpeningTime ??
                                                      "status_not_applicable"
                                                          .tr,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                )
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  size: 18,
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  (store.avgRating
                                                          .toString()) ??
                                                      "status_not_applicable"
                                                          .tr,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                Text(
                                                  "(${store.ratingCount.toString()})" ??
                                                      "status_not_applicable"
                                                          .tr,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            color: Theme.of(context).cardColor,
                            child: Column(
                              children: [
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Align(
                                    alignment: ltr
                                        ? Alignment.topLeft
                                        : Alignment.topRight,
                                    child: Text(
                                      "available_categories".tr,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        // fontSize: 15
                                      ),
                                    ),
                                  ),
                                ),
                                StoreCategoriesGrid(store: store),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  : const SizedBox(),
              bottomNavigationBar:
                  GetBuilder<CartController>(builder: (cartController) {
                return cartController.cartList.isNotEmpty &&
                        !ResponsiveHelper.isDesktop(context)
                    ? const BottomCartWidget()
                    : const SizedBox();
              }),
            );
          })
        : Scaffold(
            appBar:
                ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
            endDrawer: const MenuDrawer(),
            endDrawerEnableOpenDragGesture: false,
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: GetBuilder<StoreController>(builder: (storeController) {
              Store? store;
              if (storeController.store != null) {
                store = storeController.store;
              }
              return (storeController.store != null &&
                      storeController.store!.name != null)
                  ? CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: scrollController,
                      slivers: [
                        ResponsiveHelper.isDesktop(context)
                            ? SliverToBoxAdapter(
                                child: Container(
                                  color: const Color(0xFF171A29),
                                  padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeLarge),
                                  alignment: Alignment.center,
                                  child: Center(
                                      child: SizedBox(
                                          width: Dimensions.webMaxWidth,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: Dimensions
                                                    .paddingSizeSmall),
                                            child: Row(children: [
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions
                                                              .radiusDefault),
                                                  child: Stack(
                                                    children: [
                                                      CustomImage(
                                                        fit: BoxFit.cover,
                                                        height: 240,
                                                        width: 590,
                                                        image: store
                                                                ?.coverPhotoFullUrl ??
                                                            '',
                                                      ),
                                                      store?.discount != null
                                                          ? Positioned(
                                                              bottom: 0,
                                                              left: 0,
                                                              right: 0,
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor,
                                                                ),
                                                                padding: const EdgeInsets
                                                                    .all(
                                                                    Dimensions
                                                                        .paddingSizeExtraSmall),
                                                                child: Text(
                                                                  '${store?.discount!.discountType == 'percent' ? '${store?.discount!.discount}% ${'off'.tr}' : '${PriceConverter.convertPrice(store?.discount!.discount)} ${'off'.tr}'} '
                                                                  '${'on_all_products'.tr}, ${'after_minimum_purchase'.tr} ${PriceConverter.convertPrice(store?.discount!.minPurchase)},'
                                                                  ' ${'daily_time'.tr}: ${DateConverter.convertTimeToTime(store!.discount!.startTime!)} '
                                                                  '- ${DateConverter.convertTimeToTime(store.discount!.endTime!)}',
                                                                  style: STCMedium
                                                                      .copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeSmall,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeLarge),
                                              Expanded(
                                                  child:
                                                      StoreDescriptionViewWidget(
                                                          store: store)),
                                            ]),
                                          ))),
                                ),
                              )
                            : SliverAppBar(
                                expandedHeight: 300,
                                toolbarHeight: 100,
                                pinned: true,
                                floating: false,
                                elevation: 0.5,
                                backgroundColor: Theme.of(context).cardColor,
                                leading: IconButton(
                                  icon: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context).primaryColor),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.chevron_left,
                                      color: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  onPressed: () => Get.back(),
                                ),
                                flexibleSpace: FlexibleSpaceBar(
                                  titlePadding: EdgeInsets.zero,
                                  centerTitle: true,
                                  expandedTitleScale: 1.1,
                                  title: CustomizableSpaceBarWidget(
                                    builder: (context, scrollingRate) {
                                      return Container(
                                        height:
                                            store!.discount != null ? 145 : 100,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                  top: Radius.circular(
                                                      Dimensions.radiusLarge)),
                                        ),
                                        child: Column(
                                          children: [
                                            store.discount != null
                                                ? Container(
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .primaryColor
                                                          .withAlpha(
                                                              ((1 - scrollingRate) *
                                                                      255)
                                                                  .toInt()),
                                                      borderRadius: const BorderRadius
                                                          .vertical(
                                                          top: Radius.circular(
                                                              Dimensions
                                                                  .radiusLarge)),
                                                    ),
                                                    padding: EdgeInsets.all(Dimensions
                                                            .paddingSizeExtraSmall -
                                                        (GetPlatform.isAndroid
                                                            ? (scrollingRate *
                                                                Dimensions
                                                                    .paddingSizeExtraSmall)
                                                            : 0)),
                                                    child: Text(
                                                      '${store.discount!.discountType == 'percent' ? '${store.discount!.discount}% ${'off'.tr}' : '${PriceConverter.convertPrice(store.discount!.discount)} ${'off'.tr}'} '
                                                      '${'on_all_products'.tr}, ${'after_minimum_purchase'.tr} ${PriceConverter.convertPrice(store.discount!.minPurchase)},'
                                                      ' ${'daily_time'.tr}: ${DateConverter.convertTimeToTime(store.discount!.startTime!)} '
                                                      '- ${DateConverter.convertTimeToTime(store.discount!.endTime!)}',
                                                      style: STCMedium.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeSmall,
                                                        color: Colors.black
                                                            .withAlpha(
                                                                ((1 - scrollingRate) *
                                                                        255)
                                                                    .toInt()),
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  )
                                                : const SizedBox(),
                                            Container(
                                              color: Theme.of(context)
                                                  .cardColor
                                                  .withAlpha(
                                                      scrollingRate == 0.0
                                                          ? 255
                                                          : 0),
                                              padding: EdgeInsets.only(
                                                bottom: 0,
                                                left: Get.find<
                                                            LocalizationController>()
                                                        .isLtr
                                                    ? 40 * scrollingRate
                                                    : 0,
                                                right: Get.find<
                                                            LocalizationController>()
                                                        .isLtr
                                                    ? 0
                                                    : 40 * scrollingRate,
                                              ),
                                              child: Align(
                                                alignment: Alignment.bottomLeft,
                                                child: Container(
                                                  height: 100,
                                                  color: Theme.of(context)
                                                      .cardColor
                                                      .withAlpha(
                                                          scrollingRate == 0.0
                                                              ? 255
                                                              : 0),
                                                  padding: EdgeInsets.only(
                                                    left: Get.find<
                                                                LocalizationController>()
                                                            .isLtr
                                                        ? 20
                                                        : 0,
                                                    right: Get.find<
                                                                LocalizationController>()
                                                            .isLtr
                                                        ? 0
                                                        : 20,
                                                  ),
                                                  child: Row(children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        Dimensions.radiusSmall,
                                                      ),
                                                      child: Stack(children: [
                                                        CustomImage(
                                                          image:
                                                              '${store.logoFullUrl}',
                                                          height: 60 -
                                                              (scrollingRate *
                                                                  15),
                                                          width: 70 -
                                                              (scrollingRate *
                                                                  15),
                                                          fit: BoxFit.cover,
                                                        ),
                                                        storeController
                                                                .isStoreOpenNow(
                                                                    store
                                                                        .active,
                                                                    store
                                                                        .schedules)
                                                            ? const SizedBox()
                                                            : Positioned(
                                                                bottom: 0,
                                                                left: 0,
                                                                right: 0,
                                                                child:
                                                                    Container(
                                                                  height: 30,
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius: const BorderRadius
                                                                        .vertical(
                                                                        bottom:
                                                                            Radius.circular(Dimensions.radiusSmall)),
                                                                    color: Colors
                                                                        .black
                                                                        .withAlpha((0.6 *
                                                                                255)
                                                                            .toInt()),
                                                                  ),
                                                                  child: Text(
                                                                    store.active == -1
                                                                        ? 'temporarily_closed_label'
                                                                            .tr
                                                                        : 'closed_now'
                                                                            .tr,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: STCRegular.copyWith(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize: store.active ==
                                                                                -1
                                                                            ? Dimensions.fontSizeExtraSmall
                                                                            : Dimensions.fontSizeSmall),
                                                                  ),
                                                                ),
                                                              ),
                                                      ]),
                                                    ),
                                                    const SizedBox(
                                                        width: Dimensions
                                                            .paddingSizeSmall),
                                                    Expanded(
                                                        child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                          Row(children: [
                                                            Expanded(
                                                                child: Text(
                                                              store.name!,
                                                              style: STCMedium.copyWith(
                                                                  fontSize: Dimensions
                                                                          .fontSizeLarge -
                                                                      (scrollingRate *
                                                                          3),
                                                                  color: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodyMedium!
                                                                      .color),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            )),
                                                            const SizedBox(
                                                                width: Dimensions
                                                                    .paddingSizeSmall),
                                                          ]),
                                                          const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeExtraSmall),
                                                          Text(
                                                            store.address ?? '',
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: STCRegular.copyWith(
                                                                fontSize: Dimensions
                                                                        .fontSizeSmall -
                                                                    (scrollingRate *
                                                                        2),
                                                                color: Theme.of(
                                                                        context)
                                                                    .disabledColor),
                                                          ),
                                                          SizedBox(
                                                              height: ResponsiveHelper
                                                                      .isDesktop(
                                                                          context)
                                                                  ? Dimensions
                                                                      .paddingSizeExtraSmall
                                                                  : 0),
                                                          Row(children: [
                                                            Flexible(
                                                              child: Text(
                                                                  'minimum_order'
                                                                      .tr,
                                                                  style: STCRegular
                                                                      .copyWith(
                                                                    fontSize: Dimensions
                                                                            .fontSizeExtraSmall -
                                                                        (scrollingRate *
                                                                            2),
                                                                    color: Theme.of(
                                                                            context)
                                                                        .disabledColor,
                                                                  ),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis),
                                                            ),
                                                            const SizedBox(
                                                                width: Dimensions
                                                                    .paddingSizeExtraSmall),
                                                            Text(
                                                              PriceConverter
                                                                  .convertPrice(
                                                                      store
                                                                          .minimumOrder),
                                                              textDirection:
                                                                  TextDirection
                                                                      .ltr,
                                                              style: STCMedium.copyWith(
                                                                  fontSize: Dimensions
                                                                          .fontSizeExtraSmall -
                                                                      (scrollingRate *
                                                                          2),
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor),
                                                            ),
                                                          ]),
                                                        ])),
                                                    GetBuilder<
                                                            FavouriteController>(
                                                        builder:
                                                            (favouriteController) {
                                                      bool isWished =
                                                          favouriteController
                                                              .wishStoreIdList
                                                              .contains(
                                                                  store!.id);
                                                      return InkWell(
                                                        onTap: () {
                                                          if (AuthHelper
                                                              .isLoggedIn()) {
                                                            isWished
                                                                ? favouriteController
                                                                    .removeFromFavouriteList(
                                                                        store!
                                                                            .id,
                                                                        true)
                                                                : favouriteController
                                                                    .addToFavouriteList(
                                                                        null,
                                                                        store
                                                                            ?.id,
                                                                        true);
                                                          } else {
                                                            showCustomSnackBar(
                                                                'you_are_not_logged_in'
                                                                    .tr);
                                                          }
                                                        },
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor
                                                                .withAlpha((0.1 *
                                                                        255)
                                                                    .toInt()),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              Dimensions
                                                                  .radiusDefault,
                                                            ),
                                                          ),
                                                          padding: const EdgeInsets
                                                              .all(Dimensions
                                                                  .paddingSizeExtraSmall),
                                                          child: Icon(
                                                            isWished
                                                                ? Icons.favorite
                                                                : Icons
                                                                    .favorite_border,
                                                            color: isWished
                                                                ? Theme.of(
                                                                        context)
                                                                    .primaryColor
                                                                : Theme.of(
                                                                        context)
                                                                    .disabledColor,
                                                            size: 24 -
                                                                (scrollingRate *
                                                                    4),
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                    const SizedBox(
                                                        width: Dimensions
                                                            .paddingSizeSmall),
                                                    AppConstants.webHostedUrl
                                                            .isNotEmpty
                                                        ? InkWell(
                                                            onTap: () {
                                                              storeController
                                                                  .shareStore();
                                                            },
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor
                                                                    .withAlpha((0.1 *
                                                                            255)
                                                                        .toInt()),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        Dimensions
                                                                            .radiusDefault),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      Dimensions
                                                                          .paddingSizeExtraSmall),
                                                              child: Icon(
                                                                Icons.share,
                                                                size: 24 -
                                                                    (scrollingRate *
                                                                        4),
                                                              ),
                                                            ),
                                                          )
                                                        : const SizedBox(),
                                                    const SizedBox(
                                                        width: Dimensions
                                                            .paddingSizeSmall),
                                                  ]),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  background: CustomImage(
                                    fit: BoxFit.cover,
                                    image: '${store!.coverPhotoFullUrl}',
                                  ),
                                ),
                                actions: const [
                                  SizedBox(),
                                ],
                              ),

                        (ResponsiveHelper.isDesktop(context) &&
                                storeController.recommendedItemModel != null &&
                                storeController
                                    .recommendedItemModel!.items!.isNotEmpty)
                            ? SliverToBoxAdapter(
                                child: Container(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withAlpha((0.10 * 255).toInt()),
                                  child: Center(
                                    child: SizedBox(
                                      width: Dimensions.webMaxWidth,
                                      height:
                                          ResponsiveHelper.isDesktop(context)
                                              ? 325
                                              : 125,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeSmall),
                                          Text('recommended_for_you'.tr,
                                              style: STCMedium.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeLarge,
                                                  fontWeight: FontWeight.w700)),
                                          const SizedBox(
                                              height: Dimensions
                                                  .paddingSizeExtraSmall),
                                          Text('here_is_what_you_might_like'.tr,
                                              style: STCRegular.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeSmall,
                                                  color: Theme.of(context)
                                                      .disabledColor)),
                                          const SizedBox(
                                              height: Dimensions
                                                  .paddingSizeExtraSmall),
                                          SizedBox(
                                            height: 250,
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: storeController
                                                  .recommendedItemModel!
                                                  .items!
                                                  .length,
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                  vertical: Dimensions
                                                      .paddingSizeExtraSmall),
                                              itemBuilder: (context, index) {
                                                return Container(
                                                  width: 225,
                                                  padding: const EdgeInsets
                                                      .only(
                                                      right: Dimensions
                                                          .paddingSizeSmall,
                                                      left: Dimensions
                                                          .paddingSizeExtraSmall),
                                                  margin: const EdgeInsets.only(
                                                      right: Dimensions
                                                          .paddingSizeSmall),
                                                  child: WebItemWidget(
                                                    isStore: false,
                                                    item: storeController
                                                        .recommendedItemModel!
                                                        .items![index],
                                                    store: null,
                                                    index: index,
                                                    length: null,
                                                    isCampaign: false,
                                                    inStore: true,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SliverToBoxAdapter(child: SizedBox()),
                        const SliverToBoxAdapter(
                            child:
                                SizedBox(height: Dimensions.paddingSizeSmall)),

                        ///web view..
                        ResponsiveHelper.isDesktop(context)
                            ? SliverToBoxAdapter(
                                child: FooterView(
                                  child: SizedBox(
                                    width: Dimensions.webMaxWidth,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: Dimensions.paddingSizeSmall),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 175,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    itemCount: storeController
                                                        .categoryList!.length,
                                                    padding: const EdgeInsets
                                                        .only(
                                                        left: Dimensions
                                                            .paddingSizeSmall),
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemBuilder:
                                                        (context, index) {
                                                      return InkWell(
                                                        onTap: () {
                                                          storeController
                                                              .setCategoryIndex(
                                                                  index,
                                                                  itemSearching:
                                                                      storeController
                                                                          .isSearching);
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets
                                                              .only(
                                                              bottom: Dimensions
                                                                  .paddingSizeSmall),
                                                          child: Container(
                                                            padding: const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    Dimensions
                                                                        .paddingSizeSmall,
                                                                vertical: Dimensions
                                                                    .paddingSizeExtraSmall),
                                                            decoration:
                                                                BoxDecoration(
                                                                    gradient: LinearGradient(
                                                                        begin: Alignment
                                                                            .bottomRight,
                                                                        end: Alignment
                                                                            .topLeft,
                                                                        colors: <Color>[
                                                                  index ==
                                                                          storeController
                                                                              .categoryIndex
                                                                      ? Theme.of(
                                                                              context)
                                                                          .primaryColor
                                                                          .withAlpha((0.50 * 255)
                                                                              .toInt())
                                                                      : Colors
                                                                          .transparent,
                                                                  index ==
                                                                          storeController
                                                                              .categoryIndex
                                                                      ? Theme.of(
                                                                              context)
                                                                          .cardColor
                                                                      : Colors
                                                                          .transparent,
                                                                ])),
                                                            child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    storeController
                                                                        .categoryList![
                                                                            index]
                                                                        .name!,
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: index ==
                                                                            storeController
                                                                                .categoryIndex
                                                                        ? STCMedium.copyWith(
                                                                            fontSize: Dimensions
                                                                                .fontSizeSmall,
                                                                            color: Theme.of(context)
                                                                                .primaryColor)
                                                                        : STCRegular.copyWith(
                                                                            fontSize:
                                                                                Dimensions.fontSizeSmall),
                                                                  ),
                                                                ]),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                Container(
                                                  height: storeController
                                                          .categoryList!
                                                          .length *
                                                      50,
                                                  width: 1,
                                                  color: Theme.of(context)
                                                      .disabledColor
                                                      .withAlpha(
                                                          (0.5 * 255).toInt()),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                              width:
                                                  Dimensions.paddingSizeLarge),
                                          Expanded(
                                              child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .all(Dimensions
                                                            .paddingSizeExtraSmall),
                                                    height: 45,
                                                    width: 430,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius
                                                          .circular(Dimensions
                                                              .radiusDefault),
                                                      color: Theme.of(context)
                                                          .cardColor,
                                                      border: Border.all(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor
                                                              .withAlpha((0.40 *
                                                                      255)
                                                                  .toInt())),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: TextField(
                                                            controller:
                                                                _searchController,
                                                            textInputAction:
                                                                TextInputAction
                                                                    .search,
                                                            decoration:
                                                                InputDecoration(
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          0,
                                                                      vertical:
                                                                          0),
                                                              hintText:
                                                                  'search_for_items'
                                                                      .tr,
                                                              hintStyle: STCRegular.copyWith(
                                                                  fontSize:
                                                                      Dimensions
                                                                          .fontSizeSmall,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .disabledColor),
                                                              border: OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          Dimensions
                                                                              .radiusSmall),
                                                                  borderSide:
                                                                      BorderSide
                                                                          .none),
                                                              filled: true,
                                                              fillColor: Theme.of(
                                                                      context)
                                                                  .cardColor,
                                                              isDense: true,
                                                              prefixIcon: Icon(
                                                                  Icons.search,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor
                                                                      .withAlpha((0.50 *
                                                                              255)
                                                                          .toInt())),
                                                            ),
                                                            onSubmitted:
                                                                (String?
                                                                    value) {
                                                              if (value!
                                                                  .isNotEmpty) {
                                                                Get.find<
                                                                        StoreController>()
                                                                    .getStoreSearchItemList(
                                                                  _searchController
                                                                      .text
                                                                      .trim(),
                                                                  widget
                                                                      .store!.id
                                                                      .toString(),
                                                                  1,
                                                                  storeController
                                                                      .type,
                                                                );
                                                              }
                                                            },
                                                            onChanged: (String?
                                                                value) {},
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: Dimensions
                                                                .paddingSizeSmall),
                                                        !storeController
                                                                .isSearching
                                                            ? CustomButton(
                                                                radius: Dimensions
                                                                    .radiusSmall,
                                                                height: 40,
                                                                width: 74,
                                                                buttonText:
                                                                    'search'.tr,
                                                                isBold: false,
                                                                fontSize: Dimensions
                                                                    .fontSizeSmall,
                                                                onPressed: () {
                                                                  storeController
                                                                      .getStoreSearchItemList(
                                                                    _searchController
                                                                        .text
                                                                        .trim(),
                                                                    widget
                                                                        .store!
                                                                        .id
                                                                        .toString(),
                                                                    1,
                                                                    storeController
                                                                        .type,
                                                                  );
                                                                },
                                                              )
                                                            : InkWell(
                                                                onTap: () {
                                                                  _searchController
                                                                      .text = '';
                                                                  storeController
                                                                      .initSearchData();
                                                                  storeController
                                                                      .changeSearchStatus();
                                                                },
                                                                child:
                                                                    Container(
                                                                  decoration: BoxDecoration(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .primaryColor,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              Dimensions.radiusSmall)),
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          3,
                                                                      horizontal:
                                                                          Dimensions
                                                                              .paddingSizeSmall),
                                                                  child: const Icon(
                                                                      Icons
                                                                          .clear,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                      width: Dimensions
                                                          .paddingSizeSmall),
                                                  (Get.find<SplashController>()
                                                              .configModel!
                                                              .moduleConfig!
                                                              .module!
                                                              .vegNonVeg! &&
                                                          Get.find<
                                                                  SplashController>()
                                                              .configModel!
                                                              .toggleVegNonVeg!)
                                                      ? SizedBox(
                                                          width: 300,
                                                          height: 30,
                                                          child:
                                                              ListView.builder(
                                                            shrinkWrap: true,
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            itemCount: Get.find<
                                                                    ItemController>()
                                                                .itemTypeList
                                                                .length,
                                                            padding: const EdgeInsets
                                                                .only(
                                                                left: Dimensions
                                                                    .paddingSizeSmall),
                                                            physics:
                                                                const NeverScrollableScrollPhysics(),
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return Padding(
                                                                padding: const EdgeInsets
                                                                    .only(
                                                                    right: Dimensions
                                                                        .paddingSizeSmall),
                                                                child:
                                                                    CustomCheckBoxWidget(
                                                                  title: Get.find<
                                                                          ItemController>()
                                                                      .itemTypeList[
                                                                          index]
                                                                      .tr,
                                                                  value: storeController
                                                                          .type ==
                                                                      Get.find<ItemController>()
                                                                              .itemTypeList[
                                                                          index],
                                                                  onClick: () {
                                                                    if (storeController
                                                                        .isSearching) {
                                                                      storeController
                                                                          .getStoreSearchItemList(
                                                                        storeController
                                                                            .searchText,
                                                                        widget
                                                                            .store!
                                                                            .id
                                                                            .toString(),
                                                                        1,
                                                                        Get.find<ItemController>()
                                                                            .itemTypeList[index],
                                                                      );
                                                                    } else {
                                                                      storeController.getStoreItemList(
                                                                          storeController
                                                                              .store!
                                                                              .id,
                                                                          1,
                                                                          Get.find<ItemController>()
                                                                              .itemTypeList[index],
                                                                          true);
                                                                    }
                                                                  },
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        )
                                                      : const SizedBox(),
                                                ],
                                              ),
                                              const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeSmall),
                                              // PaginatedListView(
                                              //   scrollController:
                                              //       scrollController,
                                              //   onPaginate: (int? offset) {
                                              //     if (storeController
                                              //         .isSearching) {
                                              //       storeController
                                              //           .getStoreSearchItemList(
                                              //         storeController.searchText,
                                              //         widget.store!.id.toString(),
                                              //         offset!,
                                              //         storeController.type,
                                              //       );
                                              //     } else {
                                              //       storeController
                                              //           .getStoreItemList(
                                              //               widget.store!.id ??
                                              //                   storeController
                                              //                       .store!.id,
                                              //               offset!,
                                              //               storeController.type,
                                              //               false);
                                              //     }
                                              //   },
                                              //   totalSize:
                                              //       storeController.isSearching
                                              //           ? storeController
                                              //               .storeSearchItemModel
                                              //               ?.totalSize
                                              //           : storeController
                                              //               .storeItemModel
                                              //               ?.totalSize,
                                              //   offset:
                                              //       storeController.isSearching
                                              //           ? storeController
                                              //               .storeSearchItemModel
                                              //               ?.offset
                                              //           : storeController
                                              //               .storeItemModel
                                              //               ?.offset,
                                              //   itemView: WebItemsView(
                                              //     isStore: false,
                                              //     stores: null,
                                              //     fromStore: true,
                                              //     items: storeController
                                              //             .isSearching
                                              //         ? storeController
                                              //             .storeSearchItemModel
                                              //             ?.items
                                              //         : (storeController
                                              //                     .categoryList!
                                              //                     .isNotEmpty &&
                                              //                 storeController
                                              //                         .storeItemModel !=
                                              //                     null)
                                              //             ? storeController
                                              //                 .storeItemModel.categories[0].items
                                              //             : null,
                                              //     inStorePage: true,
                                              //     padding:
                                              //         const EdgeInsets.symmetric(
                                              //       horizontal: Dimensions
                                              //           .paddingSizeSmall,
                                              //       vertical: Dimensions
                                              //           .paddingSizeSmall,
                                              //     ),
                                              //   ),
                                              // ),
                                            ],
                                          ))
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SliverToBoxAdapter(child: SizedBox()),

                        ///mobile view..
                        ResponsiveHelper.isDesktop(context)
                            ? const SliverToBoxAdapter(child: SizedBox())
                            // : SliverToBoxAdapter(child: Center(child: Text("data"))),
                            : SliverToBoxAdapter(
                                child: Center(
                                    child: Container(
                                width: Dimensions.webMaxWidth,
                                padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeSmall),
                                color: Theme.of(context).cardColor,
                                child: Column(children: [
                                  ResponsiveHelper.isDesktop(context)
                                      ? const SizedBox()
                                      : StoreDescriptionViewWidget(
                                          store: store),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeSmall),
                                  store?.announcementActive ?? false
                                      ? Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withAlpha(
                                                    (0.05 * 255).toInt()),
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.radiusDefault),
                                            border: Border.all(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withAlpha(
                                                        (0.2 * 255).toInt())),
                                          ),
                                          padding: const EdgeInsets.all(
                                              Dimensions.paddingSizeSmall),
                                          margin: const EdgeInsets.only(
                                              top: Dimensions.paddingSizeSmall),
                                          child: Row(children: [
                                            Image.asset(Images.announcement,
                                                height: 20, width: 20),
                                            const SizedBox(
                                                width: Dimensions
                                                    .paddingSizeSmall),
                                            Flexible(
                                                child: Text(
                                                    store?.announcementMessage ??
                                                        '',
                                                    style: STCRegular.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeSmall))),
                                          ]),
                                        )
                                      : const SizedBox(),
                                  StoreBannerWidget(
                                      storeController: storeController),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeLarge),
                                  (!ResponsiveHelper.isDesktop(context) &&
                                          storeController
                                                  .recommendedItemModel !=
                                              null &&
                                          storeController.recommendedItemModel!
                                              .items!.isNotEmpty)
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('recommended_for_you'.tr,
                                                style: STCMedium),
                                            const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeExtraSmall),
                                            SizedBox(
                                              height:
                                                  ResponsiveHelper.isDesktop(
                                                          context)
                                                      ? 150
                                                      : 130,
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: storeController
                                                    .recommendedItemModel!
                                                    .items!
                                                    .length,
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  return Padding(
                                                    padding: ResponsiveHelper
                                                            .isDesktop(context)
                                                        ? const EdgeInsets
                                                            .symmetric(
                                                            vertical: 20)
                                                        : const EdgeInsets
                                                            .symmetric(
                                                            vertical: 10),
                                                    child: Container(
                                                      width: ResponsiveHelper
                                                              .isDesktop(
                                                                  context)
                                                          ? 500
                                                          : 300,
                                                      padding: const EdgeInsets
                                                          .only(
                                                          right: Dimensions
                                                              .paddingSizeSmall,
                                                          left: Dimensions
                                                              .paddingSizeExtraSmall),
                                                      margin: const EdgeInsets
                                                          .only(
                                                          right: Dimensions
                                                              .paddingSizeSmall),
                                                      child: ItemWidget(
                                                        isStore: false,
                                                        item: storeController
                                                            .recommendedItemModel!
                                                            .items![index],
                                                        store: null,
                                                        index: index,
                                                        length: null,
                                                        isCampaign: false,
                                                        inStore: true,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                      : const SizedBox(),
                                ]),
                              ))),

                        ResponsiveHelper.isDesktop(context)
                            ? const SliverToBoxAdapter(child: SizedBox())
                            : SliverPersistentHeader(
                                pinned: true,
                                delegate: SliverDelegate(
                                    height: 60,
                                    child: Center(
                                        child: Container(
                                      width: Dimensions.webMaxWidth,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        boxShadow: const [
                                          BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 5,
                                              spreadRadius: 1)
                                        ],
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical:
                                              Dimensions.paddingSizeExtraSmall),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: Dimensions
                                                    .paddingSizeSmall),
                                            child: Row(children: [
                                              Text(
                                                  // "nkjasbv",
                                                  'all_products'.tr,
                                                  style: STCBold.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeDefault)),
                                              const Expanded(child: SizedBox()),
                                              !ResponsiveHelper.isDesktop(
                                                      context)
                                                  ? InkWell(
                                                      onTap: () => Get.toNamed(
                                                        RouteHelper
                                                            .getSearchStoreItemRoute(
                                                          store!.id,
                                                        ),
                                                      ),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius: BorderRadius
                                                              .circular(Dimensions
                                                                  .radiusDefault),
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor
                                                              .withAlpha(
                                                                  (0.1 * 255)
                                                                      .toInt()),
                                                        ),
                                                        padding: const EdgeInsets
                                                            .all(Dimensions
                                                                .paddingSizeExtraSmall),
                                                        child: Icon(
                                                            Icons.search,
                                                            size: 28,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor),
                                                      ),
                                                    )
                                                  : const SizedBox(),
                                              // storeController.type.isNotEmpty
                                              //     ? VegFilterWidget(
                                              //         type:
                                              //             storeController.type,
                                              //         onSelected:
                                              //             (String type) {
                                              //           storeController
                                              //               .getStoreItemList(
                                              //                   storeController
                                              //                       .store!.id,
                                              //                   1,
                                              //                   type,
                                              //                   true);
                                              //         },
                                              //       )
                                              //     : const SizedBox(),
                                            ]),
                                          ),
                                          const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeSmall),
                                        ],
                                      ),
                                    ))),
                              ),
                        ResponsiveHelper.isDesktop(context)
                            ? const SliverToBoxAdapter(child: SizedBox())
                            : SliverToBoxAdapter(
                                child: Container(
                                  width: Dimensions.webMaxWidth,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                  ),
                                  child: storeController.storeItemModel == null
                                      ? ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          itemCount: 6,
                                          // number of shimmer placeholders
                                          padding: const EdgeInsets.only(
                                            left: Dimensions.paddingSizeSmall,
                                            right: Dimensions.paddingSizeSmall,
                                            top: Dimensions.paddingSizeSmall,
                                          ),
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            return SizedBox(
                                              height: 130,
                                              width: double.infinity,
                                              child: ListView.builder(
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: 6,
                                                  // number of shimmer placeholders
                                                  padding:
                                                      const EdgeInsets.only(
                                                    left: Dimensions
                                                        .paddingSizeDefault,
                                                    right: Dimensions
                                                        .paddingSizeDefault,
                                                    top: Dimensions
                                                        .paddingSizeDefault,
                                                  ),
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        bottom: 6,
                                                        left: 4,
                                                        right: 4,
                                                      ),
                                                      child: Shimmer(
                                                        duration:
                                                            const Duration(
                                                          seconds: 3,
                                                        ),
                                                        interval:
                                                            const Duration(
                                                          seconds: 5,
                                                        ),
                                                        color: Colors.white,
                                                        colorOpacity: 0.3,
                                                        enabled: true,
                                                        direction:
                                                            const ShimmerDirection
                                                                .fromLTRB(),
                                                        child: Container(
                                                          height: 120,
                                                          width: 150,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Theme.of(
                                                                    context)
                                                                .disabledColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                            );
                                          },
                                        )
                                      : (storeController.storeItemModel!
                                                      .categories ==
                                                  null ||
                                              storeController.storeItemModel!
                                                  .categories!.isEmpty)
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Center(
                                                child: Text(
                                                  "Items are empty",
                                                  style: STCRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                    color: Theme.of(context)
                                                        .hintColor,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.vertical,
                                              itemCount: storeController
                                                  .storeItemModel!
                                                  .categories!
                                                  .length,
                                              padding: const EdgeInsets.only(
                                                left: Dimensions
                                                    .paddingSizeExtraSmall,
                                                right: Dimensions
                                                    .paddingSizeExtraSmall,
                                              ),
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                return Container(
                                                  margin: const EdgeInsets.only(
                                                    top: 12,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .cardColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      Dimensions.radiusDefault,
                                                    ),
                                                    boxShadow: [
                                                      // Add this boxShadow list
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.1),
                                                        // Shadow color - subtle black
                                                        spreadRadius: 2,
                                                        // How much the shadow spreads outwards
                                                        blurRadius: 3,
                                                        // How blurry the shadow is
                                                        offset: const Offset(
                                                          0,
                                                          1,
                                                        ), // Shadow position (horizontal, vertical) - slightly below
                                                      ),
                                                    ],
                                                  ),
                                                  child: InkWell(
                                                    onTap: () {
                                                      // storeController.setCategoryIndex(index);
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        12.0),
                                                            child: Text(
                                                                storeController
                                                                    .storeItemModel!
                                                                    .categories![
                                                                        index]
                                                                    .name!,
                                                                style: STCMedium
                                                                    .copyWith(
                                                                  fontSize:
                                                                      Dimensions
                                                                          .fontSizeExtraLarge,
                                                                  // color: Theme.of(
                                                                  //         context)
                                                                  //     .primaryColor,
                                                                )
                                                                // : STCRegular
                                                                //     .copyWith(
                                                                //     fontSize:
                                                                //         Dimensions
                                                                //             .fontSizeExtraLarge,
                                                                //   ),
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                              height: 5),
                                                          StoreItemView(
                                                            categoryId: '0',
                                                            isStore: false,
                                                            stores: null,
                                                            items: storeController
                                                                .storeItemModel!
                                                                .categories![
                                                                    index]
                                                                .items,
                                                            inStorePage: true,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: Dimensions
                                                                  .paddingSizeSmall,
                                                              vertical: Dimensions
                                                                  .paddingSizeSmall,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                ),
                              )
                      ],
                    )
                  : const StoreDetailsScreenShimmerWidget();
            }),
            floatingActionButton:
                GetBuilder<StoreController>(builder: (storeController) {
              return Visibility(
                visible: storeController.showFavButton &&
                    Get.find<SplashController>()
                        .configModel!
                        .moduleConfig!
                        .module!
                        .orderAttachment! &&
                    (storeController.store != null &&
                        storeController.store!.prescriptionOrder!) &&
                    Get.find<SplashController>()
                        .configModel!
                        .prescriptionStatus! &&
                    AuthHelper.isLoggedIn(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context)
                              .primaryColor
                              .withAlpha((0.5 * 255).toInt()),
                          blurRadius: 10,
                          offset: const Offset(2, 2))
                    ],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      width: storeController.currentState == true
                          ? 0
                          : ResponsiveHelper.isDesktop(context)
                              ? 180
                              : 150,
                      height: 30,
                      curve: Curves.linear,
                      child: Center(
                        child: Text(
                          'prescription_order'.tr,
                          textAlign: TextAlign.center,
                          style: STCMedium.copyWith(
                              color: Theme.of(context).primaryColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Get.toNamed(
                        RouteHelper.getCheckoutRoute('prescription',
                            storeId: storeController.store!.id),
                        arguments: CheckoutScreen(
                            fromCart: false,
                            cartList: null,
                            storeId: storeController.store!.id),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        padding:
                            const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: Image.asset(Images.prescriptionIcon,
                            height: 25, width: 25),
                      ),
                    ),
                  ]),
                ),
              );
            }),
            bottomNavigationBar:
                GetBuilder<CartController>(builder: (cartController) {
              return cartController.cartList.isNotEmpty &&
                      !ResponsiveHelper.isDesktop(context)
                  ? const BottomCartWidget()
                  : const SizedBox();
            }));
  }
}

// Widget that displays the grid of categories for a given store
class StoreCategoriesGrid extends StatelessWidget {
  final Store store; // Pass the specific store to this widget

  const StoreCategoriesGrid({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CategoryController categoryController =
        Get.find<CategoryController>();

    // First, check if the store even has category IDs
    if (store.categoryIds == null || store.categoryIds!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.center,
        child: Text("no_categories_found_for_store".tr),
      );
    }

    // If categoryList in controller is null (still loading perhaps), show loading
    // This assumes categoryList is fetched elsewhere and this widget depends on it.
    // If not, you might need a loading state specific to this process.
    if (categoryController.categoryList == null) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 10),
            Text("loading_categories".tr),
          ],
        ),
      );
    }

    // If we have category IDs, proceed to build the grid
    return GridView.builder(
      itemCount: store.categoryIds!.length,
      shrinkWrap: true,
      // If this grid is inside another scrollable (e.g., SingleChildScrollView for the store page)
      physics: const NeverScrollableScrollPhysics(),
      // Paired with shrinkWrap when nested
      // If this GridView is the primary scrollable, use BouncingScrollPhysics or similar
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 10,
        top: 10,
        bottom: 30,
      ),
      // Padding around the GridView

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Two cards per row
        crossAxisSpacing: 12, // Horizontal spacing
        mainAxisSpacing: 12, // Vertical spacing
        childAspectRatio:
            1.15, // Adjust this: width / height (e.g., for a slightly taller card)
        // For square-ish: 1.0 or close to it like 0.9 or 1.1
        // For taller cards: < 1.0 (e.g. 0.8)
        // For wider cards: > 1.0 (e.g. 1.2)
      ),
      itemBuilder: (context, index) {
        CategoryModel? category;
        String errorMessage =
            "category_not_found".tr; // Default error for this item

        // This safety check for index should not be strictly necessary
        // if itemCount is correct, but good for defense.
        if (index < store.categoryIds!.length) {
          final int catId = store.categoryIds![index];

          if (categoryController.categoryList != null) {
            category = categoryController.categoryList!
                .firstWhereOrNull((categoryItem) => categoryItem.id == catId);
          } else {
            // This case is theoretically covered by the check before GridView.builder
            errorMessage = "error_loading_category_details".tr;
            print(
                "CategoryController's categoryList became null during build (should not happen).");
          }
        } else {
          errorMessage = "error_loading_category_details"
              .tr; // Or some index out of bounds error
          print("Index out of bounds for store.categoryIds.");
        }

        if (category != null) {
          // Category found, build the card
          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                Dimensions.radiusSmall,
              ), // Assuming Dimensions.radiusDefault exists
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  // Shadow color with some opacity
                  spreadRadius: 1,
                  // How far the shadow spreads before blurring
                  blurRadius: 3,
                  // How blurry the shadow is
                  offset:
                      const Offset(0, 1), // changes position of shadow (x, y)
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                // Handle category tap, e.g., navigate to products of this category
                print('Tapped on category: ${category?.name}');
                // Get.toNamed('/category-products', arguments: category?.id);
                Get.to(StoreCategoriesScreen(store: store));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                // Make children take full width
                children: [
                  Expanded(
                    flex: 2, // Give more space to the image
                    child: CustomImage(
                      image: category.imageFullUrl ?? '',
                      // Handle if imageFullUrl can be null
                      fit: BoxFit.cover,
                      // width: double.infinity, // Let Expanded handle width
                      // height: 80, // Let Expanded handle height based on aspect ratio of GridView
                    ),
                  ),
                  Expanded(
                    flex: 1, // Give less space to the text part
                    child: Align(
                      alignment: Get.find<LocalizationController>().isLtr
                          ? Alignment.topLeft
                          : Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        // Reduced padding for smaller card
                        child: Text(
                          category.name ?? "category_not_found".tr,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: 13, // Adjust font size for card
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          // Category not found for this catId, or some error occurred
          return Card(
            color: Theme.of(context).disabledColor.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;

  SliverDelegate({required this.child, this.height = 100});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
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

class CategoryProduct {
  CategoryModel category;
  List<Item> products;

  CategoryProduct(this.category, this.products);
}
