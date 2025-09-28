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
class BannerController extends GetxController implements GetxService {
  final BannerServiceInterface bannerServiceInterface;
  BannerController({required this.bannerServiceInterface});

  List<String?>? _bannerImageList;
  List<String?>? get bannerImageList => _bannerImageList;

  List<String?>? _taxiBannerImageList;
  List<String?>? get taxiBannerImageList => _taxiBannerImageList;

  List<String?>? _featuredBannerList;
  List<String?>? get featuredBannerList => _featuredBannerList;

  List<dynamic>? _bannerDataList;
  List<dynamic>? get bannerDataList => _bannerDataList;

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

  void clearBanner() {
    _bannerImageList = null;
    _initialRegularBannersPrecached = false;
    _precachedImages.clear();
    update();
  }

  Future<void> getBannerList(bool reload, {BuildContext? contextForPrecache, DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    if(_bannerImageList == null || reload || fromRecall) {
      if(reload) {
        _bannerImageList = null;
        _initialRegularBannersPrecached = false;
        _precachedImages.clear();
      }
      BannerModel? bannerModel;
      if(dataSource == DataSourceEnum.local) {
        bannerModel = await bannerServiceInterface.getBannerList(source: DataSourceEnum.local);
        await _prepareBanner(bannerModel, contextForPrecache: contextForPrecache);
        getBannerList(false, contextForPrecache: contextForPrecache, dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        bannerModel = await bannerServiceInterface.getBannerList(source: DataSourceEnum.client);
        await _prepareBanner(bannerModel, contextForPrecache: contextForPrecache, isClientCall: true);
      }
    }
  }

  _prepareBanner(BannerModel? bannerModel, {BuildContext? contextForPrecache, bool isClientCall = false}) async {
    if (bannerModel != null) {
      _bannerImageList = [];
      _bannerDataList = [];
      for (var campaign in bannerModel.campaigns!) {
        if(_bannerImageList!.contains(campaign.imageFullUrl)) {
          _bannerImageList!.add('${campaign.imageFullUrl}${bannerModel.campaigns!.indexOf(campaign)}');
        } else {
          _bannerImageList!.add(campaign.imageFullUrl);
        }
        _bannerDataList!.add(campaign);
      }
      for (var banner in bannerModel.banners!) {
        if(_bannerImageList!.contains(banner.imageFullUrl)) {
          _bannerImageList!.add('${banner.imageFullUrl}${bannerModel.banners!.indexOf(banner)}');
        } else {
          _bannerImageList!.add(banner.imageFullUrl);
        }
        if(banner.item != null) {
          _bannerDataList!.add(banner.item);
        }else if(banner.store != null){
          _bannerDataList!.add(banner.store);
        }else if(banner.type == 'default'){
          _bannerDataList!.add(banner.link);
        }else{
          _bannerDataList!.add(null);
        }
      }

      // --- Call optimized precache for regular banners ---
      if (isClientCall && contextForPrecache != null && !_initialRegularBannersPrecached && _bannerImageList != null && _bannerImageList!.isNotEmpty) {
        await _precacheBannerImagesProgressive(contextForPrecache, _bannerImageList);
        _initialRegularBannersPrecached = true;
      }
    }
    update();
  }

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
/*class BannerController extends GetxController implements GetxService {
  final BannerServiceInterface bannerServiceInterface;
  BannerController({required this.bannerServiceInterface});

  List<String?>? _bannerImageList;
  List<String?>? get bannerImageList => _bannerImageList;

  List<String?>? _taxiBannerImageList;
  List<String?>? get taxiBannerImageList => _taxiBannerImageList;

  List<String?>? _featuredBannerList;
  List<String?>? get featuredBannerList => _featuredBannerList;

  List<dynamic>? _bannerDataList;
  List<dynamic>? get bannerDataList => _bannerDataList;

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

  // --- MODIFIED: Pre-caching Method to load ALL images in the list ---
  Future<void> _precacheAllImagesInList(BuildContext context, List<String?>? images) async {
    if (images == null || images.isEmpty) {
      return;
    }

    // print('BannerController: Starting to precache ALL ${images.length} images in a list.');
    List<Future<void>> precacheFutures = [];

    for (final String? imageUrl in images) {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        precacheFutures.add(
            precacheImage(
              CachedNetworkImageProvider(imageUrl),
              context,
              onError: (exception, stackTrace) {
                // print('BannerController: Precache error for $imageUrl: $exception');
              },
            ).catchError((e) {
              // print('BannerController: Precache future error for $imageUrl: $e');
              // Catch errors from the future itself if precacheImage throws synchronously
              // or if the future returned by precacheImage completes with an error
              // that isn't caught by the onError callback.
            })
        );
      }
    }

    // Wait for all precaching operations to attempt completion.
    // We don't necessarily need to halt execution if some fail.
    try {
      await Future.wait(precacheFutures);
      // print('BannerController: Attempted to precache ALL images in the list.');
    } catch (e) {
      // print('BannerController: One or more images failed to precache during Future.wait: $e');
    }
  }
  // --- END MODIFIED Pre-caching Method ---

  Future<void> getFeaturedBanner({BuildContext? contextForPrecache}) async {
    BannerModel? bannerModel = await bannerServiceInterface.getFeaturedBannerList();
    if (bannerModel != null) {
      // ... (your existing logic to populate _featuredBannerList and _featuredBannerDataList) ...
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
      // --- Call precache for featured banners ---
      if (contextForPrecache != null && !_initialFeaturedBannersPrecached && _featuredBannerList != null && _featuredBannerList!.isNotEmpty) {
        // print("BannerController: Triggering precache for ALL Featured Banners");
        await _precacheAllImagesInList(contextForPrecache, _featuredBannerList); // MODIFIED CALL
        _initialFeaturedBannersPrecached = true;
      }
    }
    update();
  }

  void clearBanner() {
    _bannerImageList = null;
    _initialRegularBannersPrecached = false;
    update();
  }

  Future<void> getBannerList(bool reload, {BuildContext? contextForPrecache, DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    if(_bannerImageList == null || reload || fromRecall) {
      if(reload) {
        _bannerImageList = null;
        _initialRegularBannersPrecached = false;
      }
      BannerModel? bannerModel;
      if(dataSource == DataSourceEnum.local) {
        bannerModel = await bannerServiceInterface.getBannerList(source: DataSourceEnum.local);
        await _prepareBanner(bannerModel, contextForPrecache: contextForPrecache);
        getBannerList(false, contextForPrecache: contextForPrecache, dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        bannerModel = await bannerServiceInterface.getBannerList(source: DataSourceEnum.client);
        await _prepareBanner(bannerModel, contextForPrecache: contextForPrecache, isClientCall: true);
      }
    }
  }

  _prepareBanner(BannerModel? bannerModel, {BuildContext? contextForPrecache, bool isClientCall = false}) async {
    if (bannerModel != null) {
      // ... (your existing logic to populate _bannerImageList and _bannerDataList) ...
      _bannerImageList = [];
      _bannerDataList = [];
      for (var campaign in bannerModel.campaigns!) {
        if(_bannerImageList!.contains(campaign.imageFullUrl)) {
          _bannerImageList!.add('${campaign.imageFullUrl}${bannerModel.campaigns!.indexOf(campaign)}');
        } else {
          _bannerImageList!.add(campaign.imageFullUrl);
        }
        _bannerDataList!.add(campaign);
      }
      for (var banner in bannerModel.banners!) {
        if(_bannerImageList!.contains(banner.imageFullUrl)) {
          _bannerImageList!.add('${banner.imageFullUrl}${bannerModel.banners!.indexOf(banner)}');
        } else {
          _bannerImageList!.add(banner.imageFullUrl);
        }
        if(banner.item != null) {
          _bannerDataList!.add(banner.item);
        }else if(banner.store != null){
          _bannerDataList!.add(banner.store);
        }else if(banner.type == 'default'){
          _bannerDataList!.add(banner.link);
        }else{
          _bannerDataList!.add(null);
        }
      }
      // --- Call precache for regular banners ---
      if (isClientCall && contextForPrecache != null && !_initialRegularBannersPrecached && _bannerImageList != null && _bannerImageList!.isNotEmpty) {
        // print("BannerController: Triggering precache for ALL Regular Banners after client call");
        await _precacheAllImagesInList(contextForPrecache, _bannerImageList); // MODIFIED CALL
        _initialRegularBannersPrecached = true;
      }
    }
    update();
  }

  Future<void> getTaxiBannerList(bool reload, {BuildContext? contextForPrecache}) async {
    if(_taxiBannerImageList == null || reload) {
      _taxiBannerImageList = null;
      _initialTaxiBannersPrecached = false;
      BannerModel? bannerModel = await bannerServiceInterface.getTaxiBannerList();
      if (bannerModel != null) {
        // ... (your existing logic to populate _taxiBannerImageList and _taxiBannerDataList) ...
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
        // --- Call precache for taxi banners ---
        if (contextForPrecache != null && !_initialTaxiBannersPrecached && _taxiBannerImageList != null && _taxiBannerImageList!.isNotEmpty) {
          // print("BannerController: Triggering precache for ALL Taxi Banners");
          await _precacheAllImagesInList(contextForPrecache, _taxiBannerImageList); // MODIFIED CALL
          _initialTaxiBannersPrecached = true;
        }
      }
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

  void setCurrentIndex(int index, bool notify, {BuildContext? contextForPrecache}) { // contextForPrecache is no longer needed here for this strategy
    _currentIndex = index;
    if(notify) {
      update();
    }
    // No need to precache on swipe if all images are already being precached initially
  }
}*/


// import 'package:sixam_mart/common/enums/data_source_enum.dart';
// import 'package:sixam_mart/features/banner/domain/models/banner_model.dart';
// import 'package:sixam_mart/features/banner/domain/models/others_banner_model.dart';
// import 'package:sixam_mart/features/banner/domain/models/promotional_banner_model.dart';
// import 'package:get/get.dart';
// import 'package:sixam_mart/helper/responsive_helper.dart';
// import 'package:sixam_mart/features/banner/domain/services/banner_service_interface.dart';
//
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
//   Future<void> getFeaturedBanner() async {
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
//     }
//     update();
//   }
//
//   void clearBanner() {
//     _bannerImageList = null;
//   }
//
//   Future<void> getBannerList(bool reload, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
//     if(_bannerImageList == null || reload || fromRecall) {
//       if(reload) {
//         _bannerImageList = null;
//       }
//       BannerModel? bannerModel;
//       if(dataSource == DataSourceEnum.local) {
//         bannerModel = await bannerServiceInterface.getBannerList(source: DataSourceEnum.local);
//         await _prepareBanner(bannerModel);
//
//         getBannerList(false, dataSource: DataSourceEnum.client, fromRecall: true);
//       } else {
//         bannerModel = await bannerServiceInterface.getBannerList(source: DataSourceEnum.client);
//         _prepareBanner(bannerModel);
//       }
//
//     }
//   }
//
//   _prepareBanner(BannerModel? bannerModel) async{
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
//
//         if(_bannerImageList!.contains(banner.imageFullUrl)) {
//           _bannerImageList!.add('${banner.imageFullUrl}${bannerModel.banners!.indexOf(banner)}');
//         } else {
//           _bannerImageList!.add(banner.imageFullUrl);
//         }
//
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
//     }
//     update();
//   }
//
//   Future<void> getTaxiBannerList(bool reload) async {
//     if(_taxiBannerImageList == null || reload) {
//       _taxiBannerImageList = null;
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
//       }
//       update();
//     }
//   }
//
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
//
//   void setCurrentIndex(int index, bool notify) {
//     _currentIndex = index;
//     if(notify) {
//       update();
//     }
//   }
//
// }