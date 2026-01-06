import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/banner/domain/models/banner_model.dart';
import 'package:sixam_mart/features/banner/domain/models/others_banner_model.dart';
import 'package:sixam_mart/features/banner/domain/models/promotional_banner_model.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/features/banner/domain/services/banner_service_interface.dart';

import '../../splash/controllers/splash_controller.dart';

class BannerController extends GetxController implements GetxService {
  final BannerServiceInterface bannerServiceInterface;
  BannerController({required this.bannerServiceInterface});

  List<String?>? _bannerImageList;
  // List<String?>? get bannerImageList => _bannerImageList;

  // NEW map-based storage for separated modules
  final Map<String, List<String?>?> _moduleBannerImageLists = {};
  final Map<String, List<dynamic>?> _moduleBannerDataLists = {};

  List<String?>? _taxiBannerImageList;
  // List<String?>? get taxiBannerImageList => _taxiBannerImageList;

  List<String?>? _featuredBannerList;
  List<String?>? get featuredBannerList => _featuredBannerList;

  List<dynamic>? _bannerDataList;
  // List<dynamic>? get bannerDataList => _bannerDataList;

  List<dynamic>? _taxiBannerDataList;
  List<dynamic>? get taxiBannerDataList => _taxiBannerDataList;

  List<dynamic>? _featuredBannerDataList;
  List<dynamic>? get featuredBannerDataList => _featuredBannerDataList;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  ParcelOtherBannerModel? _parcelOtherBannerModel;
  ParcelOtherBannerModel? get parcelOtherBannerModel => _parcelOtherBannerModel;

  PromotionalBanner? _promotionalBanner;
  PromotionalBanner? get promotionalBanner => _promotionalBanner;

  bool _initialRegularBannersPrecached = false;
  bool _initialFeaturedBannersPrecached = false;
  bool _initialTaxiBannersPrecached = false;

  // Track which images have been precached
  final Set<String> _precachedImages = {};


  //
  // NEW Getter to intelligently provide the correct list
  List<String?>? get bannerImageList {
    String? currentModuleId = Get.find<SplashController>().module?.id.toString();

    // Check if the current module is one of our special cases (Market/Home)
    // Replace '1' (Supermarket) and '2' (Restaurant/Food) with your actual module IDs
    if (currentModuleId == '1' || currentModuleId == '2') {
      return _moduleBannerImageLists[currentModuleId];
    }
    // For all other modules, use the old shared list
    return _bannerImageList;
  }

  List<dynamic>? get bannerDataList {
    String? currentModuleId = Get.find<SplashController>().module?.id.toString();

    if (currentModuleId == '1' || currentModuleId == '2') {
      return _moduleBannerDataLists[currentModuleId];
    }
    return _bannerDataList;
  }

  // --- END: MODIFICATION FOR MODULE-SPECIFIC CACHING ---


  // List<String?>? _taxiBannerImageList;
  List<String?>? get taxiBannerImageList => _taxiBannerImageList;
  // ... other properties like featuredBannerList, currentIndex etc. remain the same ...

  // ... _precacheBannerImagesProgressive and getFeaturedBanner methods remain the same ...

  void clearBanner() {
    _bannerImageList = null;
    _moduleBannerImageLists.clear(); // Also clear the new map
    _moduleBannerDataLists.clear();
    _initialRegularBannersPrecached = false;
    _precachedImages.clear();
    update();
  }

  /// Get banner list
  /// [localOnly] - If true, only loads from local cache without making API call
  Future<void> getBannerList(bool reload, {BuildContext? contextForPrecache, DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false, bool localOnly = false}) async {

    // --- START: NEW LOGIC INSIDE getBannerList ---
    String? currentModuleId = Get.find<SplashController>().module?.id.toString();

    // Determine if we need to use module-specific storage
    // Replace '1' and '2' with your actual module IDs for Supermarket and Food
    bool useModuleCache = currentModuleId == '1' || currentModuleId == '2';

    List<String?>? targetImageList = useModuleCache ? _moduleBannerImageLists[currentModuleId] : _bannerImageList;

    if (targetImageList == null || reload || fromRecall) {
      if (reload) {
        if(useModuleCache) {
          _moduleBannerImageLists[currentModuleId!] = null;
          _moduleBannerDataLists[currentModuleId] = null;
        } else {
          _bannerImageList = null;
          _bannerDataList = null;
        }
        _initialRegularBannersPrecached = false;
        // Don't clear _precachedImages here unless you want to re-download all images
      }

      BannerModel? bannerModel;
      if (dataSource == DataSourceEnum.local) {
        bannerModel = await bannerServiceInterface.getBannerList(source: DataSourceEnum.local);
        await _prepareBanner(bannerModel, contextForPrecache: contextForPrecache);
        // Only fetch from API if not localOnly
        if (!localOnly) {
          getBannerList(false, contextForPrecache: contextForPrecache, dataSource: DataSourceEnum.client, fromRecall: true);
        }
      } else {
        bannerModel = await bannerServiceInterface.getBannerList(source: DataSourceEnum.client);
        await _prepareBanner(bannerModel, contextForPrecache: contextForPrecache, isClientCall: true);
      }
    }
    // --- END: NEW LOGIC ---
  }

  _prepareBanner(BannerModel? bannerModel, {BuildContext? contextForPrecache, bool isClientCall = false}) async {
    if (bannerModel != null) {
      // --- START: NEW LOGIC INSIDE _prepareBanner ---
      String? currentModuleId = Get.find<SplashController>().module?.id.toString();
      bool useModuleCache = currentModuleId == '1' || currentModuleId == '2';

      List<String?> newImageList = [];
      List<dynamic> newDataList = [];
      // --- END: NEW LOGIC ---

      for (var campaign in bannerModel.campaigns!) {
        if(newImageList.contains(campaign.imageFullUrl)) {
          newImageList.add('${campaign.imageFullUrl}${bannerModel.campaigns!.indexOf(campaign)}');
        } else {
          newImageList.add(campaign.imageFullUrl);
        }
        newDataList.add(campaign);
      }
      for (var banner in bannerModel.banners!) {
        if(newImageList.contains(banner.imageFullUrl)) {
          newImageList.add('${banner.imageFullUrl}${bannerModel.banners!.indexOf(banner)}');
        } else {
          newImageList.add(banner.imageFullUrl);
        }
        if(banner.item != null) {
          newDataList.add(banner.item);
        } else if(banner.store != null){
          newDataList.add(banner.store);
        } else if(banner.type == 'default'){
          newDataList.add(banner.link);
        } else{
          newDataList.add(null);
        }
      }

      // --- START: NEW LOGIC TO STORE DATA ---
      if(useModuleCache) {
        _moduleBannerImageLists[currentModuleId!] = newImageList;
        _moduleBannerDataLists[currentModuleId] = newDataList;
      } else {
        _bannerImageList = newImageList;
        _bannerDataList = newDataList;
      }
      // --- END: NEW LOGIC ---

      if (isClientCall && contextForPrecache != null && !_initialRegularBannersPrecached && newImageList.isNotEmpty) {
        await _precacheBannerImagesProgressive(contextForPrecache, newImageList);
        _initialRegularBannersPrecached = true;
      }
    }
    update();
  }
  //



  // --- OPTIMIZED: Progressive precaching method ---
  Future<void> _precacheBannerImagesProgressive(
      BuildContext context,
      List<String?>? images,
      {int initialBatchSize = 3}
      ) async {
    if (images == null || images.isEmpty) {
      return;
    }

    // Precache first batch immediately (visible + next few banners)
    final initialBatch = images.take(initialBatchSize).toList();

    for (final String? imageUrl in initialBatch) {
      if (imageUrl != null && imageUrl.isNotEmpty && !_precachedImages.contains(imageUrl)) {
        _precachedImages.add(imageUrl);
        unawaited(
          precacheImage(
            CachedNetworkImageProvider(imageUrl),
            context,
            onError: (exception, stackTrace) {
              debugPrint('BannerController: Precache error for $imageUrl: $exception');
            },
          ),
        );
      }
    }

    // Precache remaining images after a delay to avoid UI jank
    if (images.length > initialBatchSize) {
      Future.delayed(const Duration(seconds: 2), () {
        for (final String? imageUrl in images.sublist(initialBatchSize)) {
          if (imageUrl != null && imageUrl.isNotEmpty && !_precachedImages.contains(imageUrl)) {
            _precachedImages.add(imageUrl);
            unawaited(
              precacheImage(
                CachedNetworkImageProvider(imageUrl),
                context,
                onError: (exception, stackTrace) {
                  debugPrint('BannerController: Precache error for $imageUrl: $exception');
                },
              ),
            );
          }
        }
      });
    }
  }

  Future<void> getFeaturedBanner({BuildContext? contextForPrecache}) async {
    BannerModel? bannerModel = await bannerServiceInterface.getFeaturedBannerList();
    if (bannerModel != null) {
      _featuredBannerList = [];
      _featuredBannerDataList = [];

      List<int?> moduleIdList = bannerServiceInterface.moduleIdList();

      for (var campaign in bannerModel.campaigns!) {
        if(_featuredBannerList!.contains(campaign.imageFullUrl)) {
          _featuredBannerList!.add('${campaign.imageFullUrl}${bannerModel.campaigns!.indexOf(campaign)}');
        } else {
          _featuredBannerList!.add(campaign.imageFullUrl);
        }
        _featuredBannerDataList!.add(campaign);
      }
      for (var banner in bannerModel.banners!) {
        if(_featuredBannerList!.contains(banner.imageFullUrl)) {
          _featuredBannerList!.add('${banner.imageFullUrl}${bannerModel.banners!.indexOf(banner)}');
        } else {
          _featuredBannerList!.add(banner.imageFullUrl);
        }
        if(banner.item != null && moduleIdList.contains(banner.item!.moduleId)) {
          _featuredBannerDataList!.add(banner.item);
        }else if(banner.store != null && moduleIdList.contains(banner.store!.moduleId)) {
          _featuredBannerDataList!.add(banner.store);
        }else if(banner.type == 'default') {
          _featuredBannerDataList!.add(banner.link);
        }else{
          _featuredBannerDataList!.add(null);
        }
      }

      // --- Call optimized precache for featured banners ---
      if (contextForPrecache != null && !_initialFeaturedBannersPrecached && _featuredBannerList != null && _featuredBannerList!.isNotEmpty) {
        await _precacheBannerImagesProgressive(contextForPrecache, _featuredBannerList);
        _initialFeaturedBannersPrecached = true;
      }
    }
    update();
  }

  // void clearBanner() {
  //   _bannerImageList = null;
  //   _initialRegularBannersPrecached = false;
  //   _precachedImages.clear();
  //   update();
  // }

  // Future<void> getBannerList(bool reload, {BuildContext? contextForPrecache, DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
  //   if(_bannerImageList == null || reload || fromRecall) {
  //     if(reload) {
  //       _bannerImageList = null;
  //       _initialRegularBannersPrecached = false;
  //       _precachedImages.clear();
  //     }
  //     BannerModel? bannerModel;
  //     if(dataSource == DataSourceEnum.local) {
  //       bannerModel = await bannerServiceInterface.getBannerList(source: DataSourceEnum.local);
  //       await _prepareBanner(bannerModel, contextForPrecache: contextForPrecache);
  //       getBannerList(false, contextForPrecache: contextForPrecache, dataSource: DataSourceEnum.client, fromRecall: true);
  //     } else {
  //       bannerModel = await bannerServiceInterface.getBannerList(source: DataSourceEnum.client);
  //       await _prepareBanner(bannerModel, contextForPrecache: contextForPrecache, isClientCall: true);
  //     }
  //   }
  // }

  // _prepareBanner(BannerModel? bannerModel, {BuildContext? contextForPrecache, bool isClientCall = false}) async {
  //   if (bannerModel != null) {
  //     _bannerImageList = [];
  //     _bannerDataList = [];
  //     for (var campaign in bannerModel.campaigns!) {
  //       if(_bannerImageList!.contains(campaign.imageFullUrl)) {
  //         _bannerImageList!.add('${campaign.imageFullUrl}${bannerModel.campaigns!.indexOf(campaign)}');
  //       } else {
  //         _bannerImageList!.add(campaign.imageFullUrl);
  //       }
  //       _bannerDataList!.add(campaign);
  //     }
  //     for (var banner in bannerModel.banners!) {
  //       if(_bannerImageList!.contains(banner.imageFullUrl)) {
  //         _bannerImageList!.add('${banner.imageFullUrl}${bannerModel.banners!.indexOf(banner)}');
  //       } else {
  //         _bannerImageList!.add(banner.imageFullUrl);
  //       }
  //       if(banner.item != null) {
  //         _bannerDataList!.add(banner.item);
  //       }else if(banner.store != null){
  //         _bannerDataList!.add(banner.store);
  //       }else if(banner.type == 'default'){
  //         _bannerDataList!.add(banner.link);
  //       }else{
  //         _bannerDataList!.add(null);
  //       }
  //     }
  //
  //     // --- Call optimized precache for regular banners ---
  //     if (isClientCall && contextForPrecache != null && !_initialRegularBannersPrecached && _bannerImageList != null && _bannerImageList!.isNotEmpty) {
  //       await _precacheBannerImagesProgressive(contextForPrecache, _bannerImageList);
  //       _initialRegularBannersPrecached = true;
  //     }
  //   }
  //   update();
  // }

  Future<void> getTaxiBannerList(bool reload, {BuildContext? contextForPrecache}) async {
    if(_taxiBannerImageList == null || reload) {
      _taxiBannerImageList = null;
      _initialTaxiBannersPrecached = false;
      _precachedImages.clear();
      BannerModel? bannerModel = await bannerServiceInterface.getTaxiBannerList();
      if (bannerModel != null) {
        _taxiBannerImageList = [];
        _taxiBannerDataList = [];
        for (var campaign in bannerModel.campaigns!) {
          _taxiBannerImageList!.add(campaign.imageFullUrl);
          _taxiBannerDataList!.add(campaign);
        }
        for (var banner in bannerModel.banners!) {
          _taxiBannerImageList!.add(banner.imageFullUrl);
          if(banner.item != null) {
            _taxiBannerDataList!.add(banner.item);
          }else if(banner.store != null){
            _taxiBannerDataList!.add(banner.store);
          }else if(banner.type == 'default'){
            _taxiBannerDataList!.add(banner.link);
          }else{
            _taxiBannerDataList!.add(null);
          }
        }
        if(ResponsiveHelper.isDesktop(Get.context) && _taxiBannerImageList!.length % 2 != 0){
          _taxiBannerImageList!.add(_taxiBannerImageList![0]);
          _taxiBannerDataList!.add(_taxiBannerDataList![0]);
        }

        // --- Call optimized precache for taxi banners ---
        if (contextForPrecache != null && !_initialTaxiBannersPrecached && _taxiBannerImageList != null && _taxiBannerImageList!.isNotEmpty) {
          await _precacheBannerImagesProgressive(contextForPrecache, _taxiBannerImageList);
          _initialTaxiBannersPrecached = true;
        }
      }
      update();
    }
  }

  // Preload next image when index changes
  void preloadNextImage(BuildContext context, List<String?>? bannerList) {
    if (bannerList == null || bannerList.isEmpty) return;

    final nextIndex = (_currentIndex + 1) % bannerList.length;
    final nextImageUrl = bannerList[nextIndex];

    if (nextImageUrl != null && nextImageUrl.isNotEmpty && !_precachedImages.contains(nextImageUrl)) {
      _precachedImages.add(nextImageUrl);
      unawaited(
        precacheImage(
          CachedNetworkImageProvider(nextImageUrl),
          context,
          onError: (exception, stackTrace) {
            debugPrint('BannerController: Precache error for $nextImageUrl: $exception');
          },
        ),
      );
    }
  }

  void setCurrentIndex(int index, bool notify, {BuildContext? contextForPrecache}) {
    _currentIndex = index;

    // Preload next image when index changes
    if (contextForPrecache != null) {
      List<String?>? currentBannerList;
      if (_featuredBannerList != null && _featuredBannerList!.isNotEmpty) {
        currentBannerList = _featuredBannerList;
      } else if (_bannerImageList != null && _bannerImageList!.isNotEmpty) {
        currentBannerList = _bannerImageList;
      } else if (_taxiBannerImageList != null && _taxiBannerImageList!.isNotEmpty) {
        currentBannerList = _taxiBannerImageList;
      }

      if (currentBannerList != null) {
        preloadNextImage(contextForPrecache, currentBannerList);
      }
    }

    if(notify) {
      update();
    }
  }
// ... (getParcelOtherBannerList, _prepareParcelBanner, getPromotionalBannerList - no changes needed here unless they also have image lists for carousels) ...
  Future<void> getParcelOtherBannerList(bool reload, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    if(_parcelOtherBannerModel == null || reload || fromRecall) {
      ParcelOtherBannerModel? parcelOtherBannerModel;
      if(dataSource == DataSourceEnum.local) {
        parcelOtherBannerModel = await bannerServiceInterface.getParcelOtherBannerList(source: dataSource);
        _prepareParcelBanner(parcelOtherBannerModel);
        getParcelOtherBannerList(false, dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        parcelOtherBannerModel = await bannerServiceInterface.getParcelOtherBannerList(source: dataSource);
        _prepareParcelBanner(parcelOtherBannerModel);
      }
    }
  }

  _prepareParcelBanner(ParcelOtherBannerModel? parcelOtherBannerModel) {
    if (parcelOtherBannerModel != null) {
      _parcelOtherBannerModel = parcelOtherBannerModel;
    }
    update();
  }

  Future<void> getPromotionalBannerList(bool reload) async {
    if(_promotionalBanner == null || reload) {
      PromotionalBanner? promotionalBanner = await bannerServiceInterface.getPromotionalBannerList();
      if (promotionalBanner != null) {
        _promotionalBanner = promotionalBanner;
      }
      update();
    }
  }
}

// class BannerController extends GetxController implements GetxService {
//   final BannerServiceInterface bannerServiceInterface;
//   BannerController({required this.bannerServiceInterface});
//
//   List<String?>? _bannerImageList;
//   List<String?>? get bannerImageList => _bannerImageList;
//
//   List<String?>? _taxiBannerImageList;
//   List<String?>? get taxiBannerImageList => _taxiBannerImageList;
//
//   List<String?>? _featuredBannerList;
//   List<String?>? get featuredBannerList => _featuredBannerList;
//
//   List<dynamic>? _bannerDataList;
//   List<dynamic>? get bannerDataList => _bannerDataList;
//
//   List<dynamic>? _taxiBannerDataList;
//   List<dynamic>? get taxiBannerDataList => _taxiBannerDataList;
//
//   List<dynamic>? _featuredBannerDataList;
//   List<dynamic>? get featuredBannerDataList => _featuredBannerDataList;
//
//   int _currentIndex = 0;
//   int get currentIndex => _currentIndex;
//
//   ParcelOtherBannerModel? _parcelOtherBannerModel;
//   ParcelOtherBannerModel? get parcelOtherBannerModel => _parcelOtherBannerModel;
//
//   PromotionalBanner? _promotionalBanner;
//   PromotionalBanner? get promotionalBanner => _promotionalBanner;
//
//   bool _initialRegularBannersPrecached = false;
//   bool _initialFeaturedBannersPrecached = false;
//   bool _initialTaxiBannersPrecached = false;
//
//   // Track which images have been precached
//   final Set<String> _precachedImages = {};
//
//   // --- OPTIMIZED: Progressive precaching method ---
//   Future<void> _precacheBannerImagesProgressive(
//       BuildContext context,
//       List<String?>? images,
//       {int initialBatchSize = 3}
//       ) async {
//     if (images == null || images.isEmpty) {
//       return;
//     }
//
//     // Precache first batch immediately (visible + next few banners)
//     final initialBatch = images.take(initialBatchSize).toList();
//
//     for (final String? imageUrl in initialBatch) {
//       if (imageUrl != null && imageUrl.isNotEmpty && !_precachedImages.contains(imageUrl)) {
//         _precachedImages.add(imageUrl);
//         unawaited(
//           precacheImage(
//             CachedNetworkImageProvider(imageUrl),
//             context,
//             onError: (exception, stackTrace) {
//               debugPrint('BannerController: Precache error for $imageUrl: $exception');
//             },
//           ),
//         );
//       }
//     }
//
//     // Precache remaining images after a delay to avoid UI jank
//     if (images.length > initialBatchSize) {
//       Future.delayed(const Duration(seconds: 2), () {
//         for (final String? imageUrl in images.sublist(initialBatchSize)) {
//           if (imageUrl != null && imageUrl.isNotEmpty && !_precachedImages.contains(imageUrl)) {
//             _precachedImages.add(imageUrl);
//             unawaited(
//               precacheImage(
//                 CachedNetworkImageProvider(imageUrl),
//                 context,
//                 onError: (exception, stackTrace) {
//                   debugPrint('BannerController: Precache error for $imageUrl: $exception');
//                 },
//               ),
//             );
//           }
//         }
//       });
//     }
//   }
//
//   Future<void> getFeaturedBanner({BuildContext? contextForPrecache}) async {
//     BannerModel? bannerModel = await bannerServiceInterface.getFeaturedBannerList();
//     if (bannerModel != null) {
//       _featuredBannerList = [];
//       _featuredBannerDataList = [];
//
//       List<int?> moduleIdList = bannerServiceInterface.moduleIdList();
//
//       for (var campaign in bannerModel.campaigns!) {
//         if(_featuredBannerList!.contains(campaign.imageFullUrl)) {
//           _featuredBannerList!.add('${campaign.imageFullUrl}${bannerModel.campaigns!.indexOf(campaign)}');
//         } else {
//           _featuredBannerList!.add(campaign.imageFullUrl);
//         }
//         _featuredBannerDataList!.add(campaign);
//       }
//       for (var banner in bannerModel.banners!) {
//         if(_featuredBannerList!.contains(banner.imageFullUrl)) {
//           _featuredBannerList!.add('${banner.imageFullUrl}${bannerModel.banners!.indexOf(banner)}');
//         } else {
//           _featuredBannerList!.add(banner.imageFullUrl);
//         }
//         if(banner.item != null && moduleIdList.contains(banner.item!.moduleId)) {
//           _featuredBannerDataList!.add(banner.item);
//         }else if(banner.store != null && moduleIdList.contains(banner.store!.moduleId)) {
//           _featuredBannerDataList!.add(banner.store);
//         }else if(banner.type == 'default') {
//           _featuredBannerDataList!.add(banner.link);
//         }else{
//           _featuredBannerDataList!.add(null);
//         }
//       }
//
//       // --- Call optimized precache for featured banners ---
//       if (contextForPrecache != null && !_initialFeaturedBannersPrecached && _featuredBannerList != null && _featuredBannerList!.isNotEmpty) {
//         await _precacheBannerImagesProgressive(contextForPrecache, _featuredBannerList);
//         _initialFeaturedBannersPrecached = true;
//       }
//     }
//     update();
//   }
//
//   void clearBanner() {
//     _bannerImageList = null;
//     _initialRegularBannersPrecached = false;
//     _precachedImages.clear();
//     update();
//   }
//
//   Future<void> getBannerList(bool reload, {BuildContext? contextForPrecache, DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
//     if(_bannerImageList == null || reload || fromRecall) {
//       if(reload) {
//         _bannerImageList = null;
//         _initialRegularBannersPrecached = false;
//         _precachedImages.clear();
//       }
//       BannerModel? bannerModel;
//       if(dataSource == DataSourceEnum.local) {
//         bannerModel = await bannerServiceInterface.getBannerList(source: DataSourceEnum.local);
//         await _prepareBanner(bannerModel, contextForPrecache: contextForPrecache);
//         getBannerList(false, contextForPrecache: contextForPrecache, dataSource: DataSourceEnum.client, fromRecall: true);
//       } else {
//         bannerModel = await bannerServiceInterface.getBannerList(source: DataSourceEnum.client);
//         await _prepareBanner(bannerModel, contextForPrecache: contextForPrecache, isClientCall: true);
//       }
//     }
//   }
//
//   _prepareBanner(BannerModel? bannerModel, {BuildContext? contextForPrecache, bool isClientCall = false}) async {
//     if (bannerModel != null) {
//       _bannerImageList = [];
//       _bannerDataList = [];
//       for (var campaign in bannerModel.campaigns!) {
//         if(_bannerImageList!.contains(campaign.imageFullUrl)) {
//           _bannerImageList!.add('${campaign.imageFullUrl}${bannerModel.campaigns!.indexOf(campaign)}');
//         } else {
//           _bannerImageList!.add(campaign.imageFullUrl);
//         }
//         _bannerDataList!.add(campaign);
//       }
//       for (var banner in bannerModel.banners!) {
//         if(_bannerImageList!.contains(banner.imageFullUrl)) {
//           _bannerImageList!.add('${banner.imageFullUrl}${bannerModel.banners!.indexOf(banner)}');
//         } else {
//           _bannerImageList!.add(banner.imageFullUrl);
//         }
//         if(banner.item != null) {
//           _bannerDataList!.add(banner.item);
//         }else if(banner.store != null){
//           _bannerDataList!.add(banner.store);
//         }else if(banner.type == 'default'){
//           _bannerDataList!.add(banner.link);
//         }else{
//           _bannerDataList!.add(null);
//         }
//       }
//
//       // --- Call optimized precache for regular banners ---
//       if (isClientCall && contextForPrecache != null && !_initialRegularBannersPrecached && _bannerImageList != null && _bannerImageList!.isNotEmpty) {
//         await _precacheBannerImagesProgressive(contextForPrecache, _bannerImageList);
//         _initialRegularBannersPrecached = true;
//       }
//     }
//     update();
//   }
//
//   Future<void> getTaxiBannerList(bool reload, {BuildContext? contextForPrecache}) async {
//     if(_taxiBannerImageList == null || reload) {
//       _taxiBannerImageList = null;
//       _initialTaxiBannersPrecached = false;
//       _precachedImages.clear();
//       BannerModel? bannerModel = await bannerServiceInterface.getTaxiBannerList();
//       if (bannerModel != null) {
//         _taxiBannerImageList = [];
//         _taxiBannerDataList = [];
//         for (var campaign in bannerModel.campaigns!) {
//           _taxiBannerImageList!.add(campaign.imageFullUrl);
//           _taxiBannerDataList!.add(campaign);
//         }
//         for (var banner in bannerModel.banners!) {
//           _taxiBannerImageList!.add(banner.imageFullUrl);
//           if(banner.item != null) {
//             _taxiBannerDataList!.add(banner.item);
//           }else if(banner.store != null){
//             _taxiBannerDataList!.add(banner.store);
//           }else if(banner.type == 'default'){
//             _taxiBannerDataList!.add(banner.link);
//           }else{
//             _taxiBannerDataList!.add(null);
//           }
//         }
//         if(ResponsiveHelper.isDesktop(Get.context) && _taxiBannerImageList!.length % 2 != 0){
//           _taxiBannerImageList!.add(_taxiBannerImageList![0]);
//           _taxiBannerDataList!.add(_taxiBannerDataList![0]);
//         }
//
//         // --- Call optimized precache for taxi banners ---
//         if (contextForPrecache != null && !_initialTaxiBannersPrecached && _taxiBannerImageList != null && _taxiBannerImageList!.isNotEmpty) {
//           await _precacheBannerImagesProgressive(contextForPrecache, _taxiBannerImageList);
//           _initialTaxiBannersPrecached = true;
//         }
//       }
//       update();
//     }
//   }
//
//   // Preload next image when index changes
//   void preloadNextImage(BuildContext context, List<String?>? bannerList) {
//     if (bannerList == null || bannerList.isEmpty) return;
//
//     final nextIndex = (_currentIndex + 1) % bannerList.length;
//     final nextImageUrl = bannerList[nextIndex];
//
//     if (nextImageUrl != null && nextImageUrl.isNotEmpty && !_precachedImages.contains(nextImageUrl)) {
//       _precachedImages.add(nextImageUrl);
//       unawaited(
//         precacheImage(
//           CachedNetworkImageProvider(nextImageUrl),
//           context,
//           onError: (exception, stackTrace) {
//             debugPrint('BannerController: Precache error for $nextImageUrl: $exception');
//           },
//         ),
//       );
//     }
//   }
//
//   void setCurrentIndex(int index, bool notify, {BuildContext? contextForPrecache}) {
//     _currentIndex = index;
//
//     // Preload next image when index changes
//     if (contextForPrecache != null) {
//       List<String?>? currentBannerList;
//       if (_featuredBannerList != null && _featuredBannerList!.isNotEmpty) {
//         currentBannerList = _featuredBannerList;
//       } else if (_bannerImageList != null && _bannerImageList!.isNotEmpty) {
//         currentBannerList = _bannerImageList;
//       } else if (_taxiBannerImageList != null && _taxiBannerImageList!.isNotEmpty) {
//         currentBannerList = _taxiBannerImageList;
//       }
//
//       if (currentBannerList != null) {
//         preloadNextImage(contextForPrecache, currentBannerList);
//       }
//     }
//
//     if(notify) {
//       update();
//     }
//   }
// // ... (getParcelOtherBannerList, _prepareParcelBanner, getPromotionalBannerList - no changes needed here unless they also have image lists for carousels) ...
//   Future<void> getParcelOtherBannerList(bool reload, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
//     if(_parcelOtherBannerModel == null || reload || fromRecall) {
//       ParcelOtherBannerModel? parcelOtherBannerModel;
//       if(dataSource == DataSourceEnum.local) {
//         parcelOtherBannerModel = await bannerServiceInterface.getParcelOtherBannerList(source: dataSource);
//         _prepareParcelBanner(parcelOtherBannerModel);
//         getParcelOtherBannerList(false, dataSource: DataSourceEnum.client, fromRecall: true);
//       } else {
//         parcelOtherBannerModel = await bannerServiceInterface.getParcelOtherBannerList(source: dataSource);
//         _prepareParcelBanner(parcelOtherBannerModel);
//       }
//     }
//   }
//
//   _prepareParcelBanner(ParcelOtherBannerModel? parcelOtherBannerModel) {
//     if (parcelOtherBannerModel != null) {
//       _parcelOtherBannerModel = parcelOtherBannerModel;
//     }
//     update();
//   }
//
//   Future<void> getPromotionalBannerList(bool reload) async {
//     if(_promotionalBanner == null || reload) {
//       PromotionalBanner? promotionalBanner = await bannerServiceInterface.getPromotionalBannerList();
//       if (promotionalBanner != null) {
//         _promotionalBanner = promotionalBanner;
//       }
//       update();
//     }
//   }
// }