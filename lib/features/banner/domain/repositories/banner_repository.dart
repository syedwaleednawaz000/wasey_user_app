import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/api/local_client.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/banner/domain/models/banner_model.dart';
import 'package:sixam_mart/features/banner/domain/models/others_banner_model.dart';
import 'package:sixam_mart/features/banner/domain/models/promotional_banner_model.dart';
import 'package:sixam_mart/features/banner/domain/repositories/banner_repository_interface.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/header_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';

class BannerRepository implements BannerRepositoryInterface {
  final ApiClient apiClient;
  BannerRepository({required this.apiClient});

  @override
  Future getList({int? offset, bool isBanner = false, bool isTaxiBanner = false, bool isFeaturedBanner = false, bool isParcelOtherBanner = false, bool isPromotionalBanner = false, DataSourceEnum? source}) async {
    if (isBanner) {
      return await _getBannerList(source: source!);
    } else if (isTaxiBanner) {
      return await _getTaxiBannerList();
    } else if (isFeaturedBanner) {
      return await _getFeaturedBannerList();
    } else if (isParcelOtherBanner) {
      return await _getParcelOtherBannerList();
    } else if (isPromotionalBanner) {
      return await _getPromotionalBannerList();
    }
  }

  Future<BannerModel?> _getBannerList({required DataSourceEnum source}) async {
    BannerModel? bannerModel;
    String cacheId = '${AppConstants.bannerUri}-${Get.find<SplashController>().module!.id!}';

    switch(source) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(AppConstants.bannerUri);
        if (response.statusCode == 200) {
          log("bannerListFromAPI===");
          log(response.body.toString());
          bannerModel = BannerModel.fromJson(response.body);
          LocalClient.organize(source, cacheId, jsonEncode(response.body), apiClient.getHeader());
         // bannerModel.map;
        }
    // ... existing code ...
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(source, cacheId, null, null);
        if (cacheResponseData != null) {
          bannerModel = BannerModel.fromJson(jsonDecode(cacheResponseData));
          log("bannerListFromLocal===");

          // Log all campaign image URLs
          if (bannerModel.campaigns != null && bannerModel.campaigns!.isNotEmpty) {
            log("Campaign Image URLs from Local Cache:");
            for (var campaign in bannerModel.campaigns!) {
              // Assuming 'BasicCampaignModel' has 'imageFullUrl'
              // If the actual type is different, adjust campaign.imageFullUrl accordingly
              log(" - Campaign ID ${campaign.id}: ${campaign.imageFullUrl}");
            }
          } else {
            log("No campaigns found in local cache or campaigns list is empty.");
          }

          // Log all banner image URLs
          if (bannerModel.banners != null && bannerModel.banners!.isNotEmpty) {
            log("Banner Image URLs from Local Cache:");
            for (var bannerItem in bannerModel.banners!) {
              // Assuming 'Banner' (or the type of items in bannerModel.banners) has 'imageFullUrl'
              log(" - Banner ID ${bannerItem.id}: ${bannerItem.imageFullUrl}");
            }
          } else {
            log("No banners found in local cache or banners list is empty.");
          }
        }
// ... rest of the code ...

    // case DataSourceEnum.local:
      //
      //   String? cacheResponseData = await LocalClient.organize(source, cacheId, null, null);
      //   if(cacheResponseData != null) {
      //     bannerModel = BannerModel.fromJson(jsonDecode(cacheResponseData));
      //   log("bannerListFromLocal===");
      //   log(bannerModel.campaigns.first.imageFullUrl);
      //   log(bannerModel.banners.first.imageFullUrl);
      //   }
    }


    return bannerModel;
  }

  Future<BannerModel?> _getTaxiBannerList() async {
    BannerModel? bannerModel;
    Response response = await apiClient.getData(AppConstants.taxiBannerUri);
    if (response.statusCode == 200) {
      bannerModel = BannerModel.fromJson(response.body);
    }
    return bannerModel;
  }

  Future<BannerModel?> _getFeaturedBannerList() async {
    BannerModel? bannerModel;
    Response response = await apiClient.getData('${AppConstants.bannerUri}?featured=1', headers: HeaderHelper.featuredHeader());
    if (response.statusCode == 200) {
      bannerModel = BannerModel.fromJson(response.body);
    }
    return bannerModel;
  }

  Future<ParcelOtherBannerModel?> _getParcelOtherBannerList() async {
    ParcelOtherBannerModel? parcelOtherBannerModel;
    Response response = await apiClient.getData(AppConstants.parcelOtherBannerUri);
    if (response.statusCode == 200) {
      parcelOtherBannerModel = ParcelOtherBannerModel.fromJson(response.body);
    }
    return parcelOtherBannerModel;
  }

  Future<PromotionalBanner?> _getPromotionalBannerList() async {
    PromotionalBanner? promotionalBanner;
    Response response = await apiClient.getData(AppConstants.promotionalBannerUri);
    if (response.statusCode == 200 && response.body is Map) {
      promotionalBanner = PromotionalBanner.fromJson(response.body);
    }
    return promotionalBanner;
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

}