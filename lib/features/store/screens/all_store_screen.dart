import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/item_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/web_page_title_widget.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

import '../../../helper/module_helper.dart';
import '../../../util/app_constants.dart';

enum StoreFilterType { all, popular, featured, newest, offers }

class AllStoreScreen extends StatefulWidget {
  final StoreFilterType initialFilter;

  // These are no longer needed as the screen is self-contained
  final bool isPopular;
  final bool isFeatured;
  final bool isTopOfferStore;
  final bool isNearbyStore;

  const AllStoreScreen({
    super.key,
    this.initialFilter = StoreFilterType.all,
    // Remove the required booleans
    required this.isPopular,
    required this.isFeatured,
    required this.isTopOfferStore,
    required this.isNearbyStore,
  });

  @override
  State<AllStoreScreen> createState() => _AllStoreScreenState();
}

class _AllStoreScreenState extends State<AllStoreScreen> {
  final ScrollController _scrollController = ScrollController();
  late StoreFilterType _activeFilter;

  @override
  void initState() {
    super.initState();
    _activeFilter = widget.initialFilter;
    _fetchDataForFilter(_activeFilter, isInitialLoad: true);

    // --- CORRECTED PAGINATION LOGIC ---
    _scrollController.addListener(() {
      // We only paginate for the 'all' filter
      if (_activeFilter == StoreFilterType.all) {
        if (_scrollController.position.pixels ==
                _scrollController.position.maxScrollExtent &&
            Get.find<StoreController>().storeModel != null &&
            !Get.find<StoreController>().isLoading) {
          int pageSize =
              (Get.find<StoreController>().storeModel!.totalSize! / 10).ceil();
          // The StoreController's getStoreList method internally manages its offset.
          // We just need to check if we can load more data.
          if (Get.find<StoreController>().storeModel!.offset! < pageSize) {
            // The controller will automatically handle the next offset.
            Get.find<StoreController>().getStoreList(
                Get.find<StoreController>().storeModel!.offset! + 1, false);
          }
        }
      }
    });
    // --- END CORRECTION ---
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void _fetchDataForFilter(StoreFilterType filterType,
      {bool isInitialLoad = false}) {
    final storeController = Get.find<StoreController>();

    // --- REMOVED `setPaginatedStore` ---
    // The controller methods already handle their own state.

    switch (filterType) {
      case StoreFilterType.popular:
        storeController.getPopularStoreList(!isInitialLoad, 'all', false);
        break;
      case StoreFilterType.featured:
        storeController.getFeaturedStoreList();
        break;
      case StoreFilterType.newest:
        storeController.getLatestStoreList(!isInitialLoad, 'all', false);
        break;
      case StoreFilterType.offers:
        storeController.getTopOfferStoreList(!isInitialLoad, false);
        break;
      case StoreFilterType.all:
      default:
        // This method resets the list to the first page.
        storeController.getStoreList(1, !isInitialLoad);
        break;
    }
  }

  String _getTitle() {
    bool isRestaurant = ModuleHelper.getModule()!.id!.toString() ==
        AppConstants.restaurantModuleId;
    switch (_activeFilter) {
      case StoreFilterType.popular:
        return isRestaurant ? 'popular_restaurants'.tr : 'popular_stores'.tr;
      case StoreFilterType.featured:
        return isRestaurant ? "featured_restaurants".tr : 'featured_stores'.tr;
      case StoreFilterType.newest:
        return isRestaurant
            ? "newly_added_restaurants".tr
            : 'newly_added_stores'.tr;
      case StoreFilterType.offers:
        return 'top_offers_near_me'.tr;
      case StoreFilterType.all:
      default:
        return isRestaurant ? 'all_restaurants'.tr : 'all_stores'.tr;
    }
  }

  Widget _buildFilterChips() {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeExtraSmall,
        horizontal: Dimensions.paddingSizeSmall,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildChip('all'.tr, StoreFilterType.all),
            _buildChip('popular'.tr, StoreFilterType.popular),
            _buildChip('featured'.tr, StoreFilterType.featured),
            _buildChip('newest'.tr, StoreFilterType.newest),
            _buildChip('offers'.tr, StoreFilterType.offers),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, StoreFilterType filterType) {
    bool isSelected = _activeFilter == filterType;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeExtraSmall),
      child: ChoiceChip(
        label: Text(label),
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeExtraSmall),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _activeFilter = filterType;
            });
            _scrollController.animateTo(0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut);
            _fetchDataForFilter(filterType);
          }
        },
        selectedColor: Theme.of(context).primaryColor,
        labelStyle: isSelected
            ? STCMedium.copyWith(color: Theme.of(context).cardColor)
            : STCRegular,
        backgroundColor: Theme.of(context).disabledColor.withOpacity(0.1),
        shape: StadiumBorder(
          side: BorderSide(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(builder: (storeController) {
      // Logic for total stores remains the same, but safer
      String? totalStores;
      if (_activeFilter == StoreFilterType.all &&
          storeController.storeModel != null) {
        totalStores = storeController.storeModel!.stores?.length.toString();
      } else if (_activeFilter == StoreFilterType.popular) {
        totalStores = storeController.popularStoreList?.length.toString();
      } else if (_activeFilter == StoreFilterType.featured) {
        totalStores = storeController.featuredStoreList?.length.toString();
      } else if (_activeFilter == StoreFilterType.newest) {
        totalStores = storeController.latestStoreList?.length.toString();
      } else if (_activeFilter == StoreFilterType.offers) {
        totalStores = storeController.topOfferStoreList?.length.toString();
      }

      return Scaffold(
        appBar: CustomAppBar(
          title: _getTitle(),
          type: (_activeFilter == StoreFilterType.popular ||
                  _activeFilter == StoreFilterType.newest ||
                  _activeFilter == StoreFilterType.all)
              ? storeController.type
              : null,
          onVegFilterTap: (String type) {
            // This logic remains the same
            if (_activeFilter == StoreFilterType.popular) {
              storeController.getPopularStoreList(true, type, true);
            } else if (_activeFilter == StoreFilterType.newest) {
              storeController.getLatestStoreList(true, type, true);
            } else if (_activeFilter == StoreFilterType.all) {
              storeController.getStoreList(1, true);
            }
          },
        ),
        endDrawer: const MenuDrawer(),
        endDrawerEnableOpenDragGesture: false,
        body: RefreshIndicator(
          onRefresh: () async {
            _fetchDataForFilter(_activeFilter, isInitialLoad: true);
          },
          child: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                    child: WebScreenTitleWidget(title: _getTitle())),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: SliverDelegate(child: _buildFilterChips()),
                ),
              ];
            },
            body: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              // The parent NestedScrollView handles scrolling
              child: FooterView(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: Dimensions.paddingSizeSmall,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _getTitle(),
                              style: STCMedium.copyWith(
                                  fontSize: Dimensions.fontSizeLarge),
                            ),
                            if (totalStores != null)
                              Text(
                                '$totalStores ${(ModuleHelper.getModule()!.id!.toString() == AppConstants.restaurantModuleId) ? 'restaurants'.tr : 'stores'.tr}',
                                style: STCRegular.copyWith(
                                  color: Theme.of(context).disabledColor,
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                          ],
                        ),
                      ),
                      ItemsView(
                        isStore: true,
                        items: null,
                        isFeatured: _activeFilter == StoreFilterType.featured,
                        noDataText: Get.find<SplashController>()
                                .configModel!
                                .moduleConfig!
                                .module!
                                .showRestaurantText!
                            ? 'no_restaurant_available'.tr
                            : 'no_store_available'.tr,
                        stores: _activeFilter == StoreFilterType.all
                            ? storeController.storeModel?.stores
                            : _activeFilter == StoreFilterType.popular
                                ? storeController.popularStoreList
                                : _activeFilter == StoreFilterType.featured
                                    ? storeController.featuredStoreList
                                    : _activeFilter == StoreFilterType.newest
                                        ? storeController.latestStoreList
                                        : _activeFilter ==
                                                StoreFilterType.offers
                                            ? storeController.topOfferStoreList
                                            : [],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  SliverDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
// import 'package:sixam_mart/common/widgets/footer_view.dart';
// import 'package:sixam_mart/common/widgets/item_view.dart';
// import 'package:sixam_mart/common/widgets/menu_drawer.dart';
// import 'package:sixam_mart/common/widgets/web_page_title_widget.dart';
// import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
// import 'package:sixam_mart/util/dimensions.dart';
// import 'package:sixam_mart/util/styles.dart';
//
// import '../controllers/store_controller.dart';
//
// // --- NEW: Enum to manage the currently selected filter state ---
// enum StoreFilterType { all, popular, featured, newest, offers }
//
// class AllStoreScreen extends StatefulWidget {
//   // The 'initialFilter' will determine which filter is active when the page first loads.
//   final StoreFilterType initialFilter;
//
//   const AllStoreScreen(
//       {super.key,
//       this.initialFilter = StoreFilterType.all,
//       required bool isPopular,
//       required bool isFeatured,
//       required bool isTopOfferStore,
//       required bool isNearbyStore});
//
//   @override
//   State<AllStoreScreen> createState() => _AllStoreScreenState();
// }
//
// class _AllStoreScreenState extends State<AllStoreScreen> {
//   final ScrollController _scrollController = ScrollController();
//
//   // State variable to hold the currently active filter. It's initialized from the widget.
//   late StoreFilterType _activeFilter;
//
//   @override
//   void initState() {
//     super.initState();
//     _activeFilter = widget.initialFilter;
//     _fetchDataForFilter(_activeFilter, isInitialLoad: true);
//
//     // --- MODIFICATION: Pagination logic is now handled here ---
//     _scrollController.addListener(() {
//       // Check if the user has scrolled to the end of the page
//       if (_scrollController.position.pixels ==
//               _scrollController.position.maxScrollExtent &&
//           Get.find<StoreController>().storeModel != null &&
//           !Get.find<StoreController>().isLoading) {
//         // Only paginate if the 'All' filter is selected
//         if (_activeFilter == StoreFilterType.all) {
//           int pageSize =
//               (Get.find<StoreController>().storeModel!.totalSize! / 10).ceil();
//           if (Get.find<StoreController>().offset < pageSize) {
//             Get.find<StoreController>().getStoreList(Get.find<StoreController>().offset + 1, false);
//           }
//         }
//       }
//     });
//     // --- END MODIFICATION ---
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     _scrollController.dispose();
//   }
//
//   // Helper method to fetch data based on the selected filter
//   void _fetchDataForFilter(StoreFilterType filterType,
//       {bool isInitialLoad = false}) {
//     final storeController = Get.find<StoreController>();
//     if (filterType != StoreFilterType.all) {
//       storeController.setPaginatedStore(false);
//     }
//
//     switch (filterType) {
//       case StoreFilterType.popular:
//         storeController.getPopularStoreList(!isInitialLoad, 'all', false);
//         break;
//       case StoreFilterType.featured:
//         storeController.getFeaturedStoreList();
//         break;
//       case StoreFilterType.newest:
//         storeController.getLatestStoreList(!isInitialLoad, 'all', false);
//         break;
//       case StoreFilterType.offers:
//         storeController.getTopOfferStoreList(!isInitialLoad, false);
//         break;
//       case StoreFilterType.all:
//       default:
//         storeController.getStoreList(1, !isInitialLoad);
//         break;
//     }
//   }
//
//   // Helper method to get the correct title based on the active filter
//   String _getTitle() {
//     bool isRestaurant = Get.find<SplashController>()
//         .configModel!
//         .moduleConfig!
//         .module!
//         .showRestaurantText!;
//
//     switch (_activeFilter) {
//       case StoreFilterType.popular:
//         return isRestaurant ? 'popular_restaurants'.tr : 'popular_stores'.tr;
//       case StoreFilterType.featured:
//         return 'featured_stores'.tr;
//       case StoreFilterType.newest:
//         return 'newly_added_stores'.tr;
//       case StoreFilterType.offers:
//         return 'top_offers_near_me'.tr;
//       case StoreFilterType.all:
//       default:
//         return isRestaurant ? 'all_restaurants'.tr : 'all_stores'.tr;
//     }
//   }
//
//   // Widget for the filter chips
//   Widget _buildFilterChips(// {required String? totalStores}
//       ) {
//     return Container(
//       color: Theme.of(context).cardColor,
//       // height: 100,
//       // color: Colors.red,
//       padding: const EdgeInsets.symmetric(
//         vertical: Dimensions.paddingSizeExtraSmall,
//         horizontal: Dimensions.paddingSizeSmall,
//       ),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         physics: const BouncingScrollPhysics(),
//         // padding: const EdgeInsets.symmetric(
//         //   horizontal: Dimensions.paddingSizeSmall,
//         // ),
//         child: Row(
//           children: [
//             _buildChip('all'.tr, StoreFilterType.all),
//             _buildChip('popular'.tr, StoreFilterType.popular),
//             _buildChip('featured'.tr, StoreFilterType.featured),
//             _buildChip('newest'.tr, StoreFilterType.newest),
//             _buildChip('offers'.tr, StoreFilterType.offers),
//             // Text(totalStores.toString()),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildChip(String label, StoreFilterType filterType) {
//     bool isSelected = _activeFilter == filterType;
//     return Padding(
//       padding: const EdgeInsets.only(
//         left: Dimensions.paddingSizeExtraSmall,
//         right: Dimensions.paddingSizeExtraSmall,
//         // bottom: Dimensions.paddingSizeExtraSmall,
//       ),
//       child: ChoiceChip(
//         label: Text(
//           label,
//         ),
//         padding: const EdgeInsets.only(
//           // bottom: 6,
//           right: Dimensions.paddingSizeExtraSmall,
//           left: Dimensions.paddingSizeExtraSmall,
//         ),
//         selected: isSelected,
//         onSelected: (selected) {
//           if (selected) {
//             setState(() {
//               _activeFilter = filterType;
//             });
//             // Scroll to top when a new filter is selected
//             _scrollController.animateTo(
//               0,
//               duration: const Duration(milliseconds: 300),
//               curve: Curves.easeOut,
//             );
//             _fetchDataForFilter(filterType);
//           }
//         },
//         selectedColor: Theme.of(context).primaryColor,
//         labelStyle: isSelected
//             ? STCMedium.copyWith(color: Theme.of(context).cardColor)
//             : STCRegular,
//         backgroundColor: Theme.of(context).disabledColor.withOpacity(0.1),
//         shape: StadiumBorder(
//           side: BorderSide(
//             color: Theme.of(context).primaryColor.withOpacity(0.2),
//             width: 1,
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<StoreController>(builder: (storeController) {
//       final String? totalStores = _activeFilter == StoreFilterType.all
//           ? storeController?.storeModel?.stores?.length.toString()
//           : _activeFilter == StoreFilterType.popular
//               ? storeController.popularStoreList?.length.toString()
//               : _activeFilter == StoreFilterType.featured
//                   ? storeController.featuredStoreList?.length.toString()
//                   : _activeFilter == StoreFilterType.newest
//                       ? storeController.latestStoreList?.length.toString()
//                       : _activeFilter == StoreFilterType.offers
//                           ? storeController.topOfferStoreList?.length.toString()
//                           : "";
//       return Scaffold(
//         appBar: CustomAppBar(
//           title: _getTitle(),
//           type: (_activeFilter == StoreFilterType.popular ||
//                   _activeFilter == StoreFilterType.newest ||
//                   _activeFilter == StoreFilterType.all)
//               ? storeController.type
//               : null,
//           onVegFilterTap: (String type) {
//             if (_activeFilter == StoreFilterType.popular) {
//               storeController.getPopularStoreList(true, type, true);
//             } else if (_activeFilter == StoreFilterType.newest) {
//               storeController.getLatestStoreList(true, type, true);
//             } else if (_activeFilter == StoreFilterType.all) {
//               storeController.getStoreList(1, true);
//             }
//           },
//         ),
//         endDrawer: const MenuDrawer(),
//         endDrawerEnableOpenDragGesture: false,
//         body: RefreshIndicator(
//           onRefresh: () async {
//             _fetchDataForFilter(_activeFilter);
//           },
//           child: NestedScrollView(
//             controller: _scrollController,
//             // Important: Use the same scroll controller here
//             headerSliverBuilder: (context, innerBoxIsScrolled) {
//               return [
//                 SliverToBoxAdapter(
//                     child: WebScreenTitleWidget(title: _getTitle())),
//                 SliverPersistentHeader(
//                   pinned: true,
//                   delegate: SliverDelegate(
//                       child: _buildFilterChips(
//                           // totalStores: totalStores
//                           )),
//                 ),
//               ];
//             },
//             body: SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               child: FooterView(
//                 child: SizedBox(
//                   width: Dimensions.webMaxWidth,
//                   // --- MODIFICATION: ItemsView is now much simpler ---
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: Dimensions.paddingSizeDefault,
//                           vertical: Dimensions.paddingSizeExtraSmall,
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Text(
//                               Get.find<SplashController>()
//                                   .configModel!
//                                   .moduleConfig!
//                                   .module!
//                                   .showRestaurantText!
//                                   ? 'restaurants'.tr
//                                   : 'stores'.tr,
//                               style: STCBold.copyWith(
//                                   fontSize: Dimensions.fontSizeLarge),
//                             ),
//                             totalStores != null
//                                 // ? Text("${totalStores.toString()} ${"restaurants_near_you".tr}")
//                                 ? Text(
//                                     '${totalStores.toString() ?? 0} ${Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! ? 'restaurants_near_you'.tr : 'stores_near_you'.tr}',
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: STCRegular.copyWith(
//                                       color: Theme.of(context).disabledColor,
//                                       fontSize: Dimensions.fontSizeSmall,
//                                     ),
//                                   )
//                                 : const LinearProgressIndicator(),
//                           ],
//                         ),
//                       ),
//                       ItemsView(
//                         isStore: true,
//                         items: null,
//                         isFeatured: _activeFilter == StoreFilterType.featured,
//                         noDataText: Get.find<SplashController>()
//                                 .configModel!
//                                 .moduleConfig!
//                                 .module!
//                                 .showRestaurantText!
//                             ? 'no_restaurant_available'.tr
//                             : 'no_store_available'.tr,
//                         stores: _activeFilter == StoreFilterType.all
//                             ? storeController.storeModel?.stores
//                             : _activeFilter == StoreFilterType.popular
//                                 ? storeController.popularStoreList
//                                 : _activeFilter == StoreFilterType.featured
//                                     ? storeController.featuredStoreList
//                                     : _activeFilter == StoreFilterType.newest
//                                         ? storeController.latestStoreList
//                                         : _activeFilter ==
//                                                 StoreFilterType.offers
//                                             ? storeController.topOfferStoreList
//                                             : [],
//                       ),
//                     ],
//                   ),
//                   // --- END MODIFICATION ---
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//     });
//   }
// }
//
// // Helper class to make the filter chips stick to the top
// class SliverDelegate extends SliverPersistentHeaderDelegate {
//   final Widget child;
//
//   SliverDelegate({required this.child});
//
//   @override
//   Widget build(
//       BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return child;
//   }
//
//   @override
//   double get maxExtent => 50;
//
//   @override
//   double get minExtent => 50;
//
//   @override
//   bool shouldRebuild(SliverDelegate oldDelegate) {
//     return oldDelegate.child != child;
//   }
// }

// import 'package:sixam_mart/features/store/controllers/store_controller.dart';
// import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
// import 'package:sixam_mart/util/app_constants.dart';
// import 'package:sixam_mart/util/dimensions.dart';
// import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
// import 'package:sixam_mart/common/widgets/footer_view.dart';
// import 'package:sixam_mart/common/widgets/item_view.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:sixam_mart/common/widgets/menu_drawer.dart';
// import 'package:sixam_mart/common/widgets/web_page_title_widget.dart';
//
// import '../../../helper/responsive_helper.dart';
// import '../../home/widgets/filter_view.dart';
// import '../../home/widgets/store_filter_button_widget.dart';
//
// class AllStoreScreen extends StatefulWidget {
//   final bool isPopular;
//   final bool isFeatured;
//   final bool isNearbyStore;
//   final bool isTopOfferStore;
//
//   const AllStoreScreen(
//       {super.key,
//       required this.isPopular,
//       required this.isFeatured,
//       required this.isNearbyStore,
//       required this.isTopOfferStore});
//
//   @override
//   State<AllStoreScreen> createState() => _AllStoreScreenState();
// }
//
// class _AllStoreScreenState extends State<AllStoreScreen> {
//   final ScrollController scrollController = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//
//     if (widget.isFeatured) {
//       Get.find<StoreController>().getFeaturedStoreList();
//     } else if (widget.isPopular) {
//       Get.find<StoreController>().getPopularStoreList(false, 'all', false);
//     } else if (widget.isTopOfferStore) {
//       Get.find<StoreController>().getTopOfferStoreList(false, false);
//     } else {
//       Get.find<StoreController>().getLatestStoreList(false, 'all', false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<StoreController>(builder: (storeController) {
//       return Scaffold(
//         appBar: CustomAppBar(
//           title: widget.isFeatured
//               ? 'featured_stores'.tr
//               : widget.isPopular
//                   ? Get.find<SplashController>()
//                           .configModel!
//                           .moduleConfig!
//                           .module!
//                           .showRestaurantText!
//                       ? widget.isNearbyStore
//                           ? 'best_store_nearby'.tr
//                           : 'popular_restaurants'.tr
//                       : widget.isNearbyStore
//                           ? 'best_store_nearby'.tr
//                           : 'popular_stores'.tr
//                   : widget.isTopOfferStore
//                       ? 'top_offers_near_me'.tr
//                       : '${'new_on'.tr} ${AppConstants.appName}',
//           type: widget.isFeatured ? null : storeController.type,
//           onVegFilterTap: (String type) {
//             if (widget.isPopular) {
//               Get.find<StoreController>().getPopularStoreList(true, type, true);
//             } else {
//               Get.find<StoreController>().getLatestStoreList(true, type, true);
//             }
//           },
//         ),
//         endDrawer: const MenuDrawer(),
//         endDrawerEnableOpenDragGesture: false,
//         body: RefreshIndicator(
//           onRefresh: () async {
//             if (widget.isFeatured) {
//               await Get.find<StoreController>().getFeaturedStoreList();
//             } else if (widget.isPopular) {
//               await Get.find<StoreController>().getPopularStoreList(
//                 true,
//                 Get.find<StoreController>().type,
//                 false,
//               );
//             } else {
//               await Get.find<StoreController>().getLatestStoreList(
//                 true,
//                 Get.find<StoreController>().type,
//                 false,
//               );
//             }
//           },
//           child: SingleChildScrollView(
//               controller: scrollController,
//               child: FooterView(
//                   child: Column(
//                 children: [
//                   WebScreenTitleWidget(
//                     title: widget.isFeatured
//                         ? 'featured_stores'.tr
//                         : widget.isPopular
//                             ? Get.find<SplashController>()
//                                     .configModel!
//                                     .moduleConfig!
//                                     .module!
//                                     .showRestaurantText!
//                                 ? 'popular_restaurants'.tr
//                                 : 'popular_stores'.tr
//                             : widget.isTopOfferStore
//                                 ? 'top_offers_near_me'.tr
//                                 : '${'new_on'.tr} ${AppConstants.appName}',
//                   ),
//                   SizedBox(
//                     width: Dimensions.webMaxWidth,
//                     child:
//                         GetBuilder<StoreController>(builder: (storeController) {
//                       return ItemsView(
//                         isStore: true,
//                         items: null,
//                         isFeatured: widget.isFeatured,
//                         noDataText: widget.isFeatured
//                             ? 'no_store_available'.tr
//                             : Get.find<SplashController>()
//                                     .configModel!
//                                     .moduleConfig!
//                                     .module!
//                                     .showRestaurantText!
//                                 ? 'no_restaurant_available'.tr
//                                 : 'no_store_available'.tr,
//                         stores: widget.isFeatured
//                             ? storeController.featuredStoreList
//                             : widget.isPopular
//                                 ? storeController.popularStoreList
//                                 : widget.isTopOfferStore
//                                     ? storeController.topOfferStoreList
//                                     : storeController.latestStoreList,
//                       );
//                     }),
//                   ),
//                 ],
//               ))),
//         ),
//       );
//     });
//   }
// }
