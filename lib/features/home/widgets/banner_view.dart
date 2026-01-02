import 'package:carousel_slider/carousel_slider.dart';
import 'package:sixam_mart/features/banner/controllers/banner_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/item/domain/models/basic_campaign_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../util/images.dart';

class BannerView extends StatefulWidget {
  final bool isFeatured;

  const BannerView({super.key, required this.isFeatured});

  @override
  State<BannerView> createState() => _BannerViewState();
}

class _BannerViewState extends State<BannerView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBanners();
    });
  }

  void _loadBanners() {
    final bannerController = Get.find<BannerController>();
    if (widget.isFeatured) {
      if (bannerController.featuredBannerList == null) {
        bannerController.getFeaturedBanner(contextForPrecache: context);
      }
    } else {
      if (bannerController.bannerImageList == null) {
        bannerController.getBannerList(false, contextForPrecache: context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double bannerHeight = screenWidth * (450 / 550); // نسبة الأبعاد 550x450

    return GetBuilder<BannerController>(builder: (bannerController) {
      List<String?>? bannerList = widget.isFeatured
          ? bannerController.featuredBannerList
          : bannerController.bannerImageList;
      List<dynamic>? bannerDataList = widget.isFeatured
          ? bannerController.featuredBannerDataList
          : bannerController.bannerDataList;

      // If banners list is empty, show SizedBox instead of shimmer
      if (bannerList != null && bannerList.isEmpty) {
        return const SizedBox();
      }

      return Container(
        width: screenWidth,
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
        child: (bannerList != null && bannerList.isNotEmpty)
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    children: [
                      CarouselSlider.builder(
                        options: CarouselOptions(
                          autoPlay: true,
                          enlargeCenterPage: false,
                          viewportFraction: 1.0,
                          autoPlayInterval: const Duration(seconds: 4),
                          autoPlayAnimationDuration:
                              const Duration(milliseconds: 800),
                          pauseAutoPlayOnTouch: true,
                          onPageChanged: (index, reason) {
                            bannerController.setCurrentIndex(index, true,
                                contextForPrecache: context);
                          },
                          height: bannerHeight,
                        ),
                        itemCount: bannerList.length,
                        itemBuilder: (context, index, _) {
                          return InkWell(
                            onTap: () async {
                              var data = bannerDataList![index];
                              if (data is Item) {
                                Get.find<ItemController>()
                                    .navigateToItemPage(data, context);
                              } else if (data is Store) {
                                if (widget.isFeatured &&
                                    (AddressHelper
                                                .getUserAddressFromSharedPref()
                                            ?.zoneData
                                            ?.isNotEmpty ??
                                        false)) {
                                  for (ModuleModel module
                                      in Get.find<SplashController>()
                                          .moduleList!) {
                                    if (module.id == data.moduleId) {
                                      Get.find<SplashController>()
                                          .setModule(module);
                                      break;
                                    }
                                  }
                                  ZoneData zoneData = AddressHelper
                                          .getUserAddressFromSharedPref()!
                                      .zoneData!
                                      .firstWhere((z) => z.id == data.zoneId);
                                  Modules module = zoneData.modules!
                                      .firstWhere((m) => m.id == data.moduleId);
                                  Get.find<SplashController>().setModule(
                                    ModuleModel(
                                      id: module.id,
                                      moduleName: module.moduleName,
                                      moduleType: module.moduleType,
                                      themeId: module.themeId,
                                      storesCount: module.storesCount,
                                    ),
                                  );
                                }
                                Get.toNamed(
                                  RouteHelper.getStoreRoute(
                                    id: data.id,
                                    page:
                                        widget.isFeatured ? 'module' : 'banner',
                                  ),
                                  arguments: StoreScreen(
                                      store: data,
                                      fromModule: widget.isFeatured),
                                );
                              } else if (data is BasicCampaignModel) {
                                Get.toNamed(
                                    RouteHelper.getBasicCampaignRoute(data));
                              } else {
                                String url = data;
                                if (await canLaunchUrlString(url)) {
                                  await launchUrlString(url,
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  showCustomSnackBar('unable_to_found_url'.tr);
                                }
                              }
                            },
                            child: SizedBox(
                              width: screenWidth,
                              height: bannerHeight,
                              child: GetBuilder<SplashController>(
                                builder: (splashController) {
                                  return CustomImage(
                                    image: '${bannerList[index]}',
                                    fit: BoxFit.fill,
                                    width: screenWidth,
                                    height: bannerHeight,
                                    placeholder: Images.placeholder,
                                    // fadeInDuration: const Duration(milliseconds: 500),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child:
                            GetBuilder<BannerController>(builder: (controller) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(bannerList.length, (index) {
                              return Container(
                                width: 8,
                                height: 8,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: controller.currentIndex == index
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                ),
                              );
                            }),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              )
            : Shimmer(
                duration: const Duration(seconds: 2),
                enabled: bannerList == null,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    color: Colors.grey[300],
                  ),
                  height: bannerHeight,
                ),
              ),
      );
    });
  }
}

/*
class BannerView extends StatefulWidget {
  final bool isFeatured;
  const BannerView({super.key, required this.isFeatured});

  @override
  State<BannerView> createState() => _BannerViewState();
}

class _BannerViewState extends State<BannerView> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBanners();
    });
  }

  void _loadBanners() {
    final bannerController = Get.find<BannerController>();
    if (widget.isFeatured) {
      if (bannerController.featuredBannerList == null) { // Fetch only if not already loaded
        bannerController.getFeaturedBanner(contextForPrecache: context);
      }
    } else {
      if (bannerController.bannerImageList == null) { // Fetch only if not already loaded
        bannerController.getBannerList(false, contextForPrecache: context);
      }
      // You might also have logic for taxi banners here if BannerView handles them
      // if (bannerController.taxiBannerImageList == null) {
      //   bannerController.getTaxiBannerList(false, contextForPrecache: context);
      // }
    }
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    double bannerHeight = screenWidth * (450 / 550); // نسبة الأبعاد 550x450

    return GetBuilder<BannerController>(builder: (bannerController) {
      List<String?>? bannerList = widget.isFeatured
          ? bannerController.featuredBannerList
          : bannerController.bannerImageList;
      List<dynamic>? bannerDataList = widget.isFeatured
          ? bannerController.featuredBannerDataList
          : bannerController.bannerDataList;

      return (bannerList != null && bannerList.isEmpty)
          ? const SizedBox()
          : Container(
        width: screenWidth,
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
        child: bannerList != null
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                CarouselSlider.builder(
                  options: CarouselOptions(
                    autoPlay: true,
                    enlargeCenterPage: false,
                    viewportFraction: 1.0,
                    autoPlayInterval: const Duration(seconds: 3),
                    onPageChanged: (index, reason) {
                      bannerController.setCurrentIndex(index, true);
                    },
                    height: bannerHeight,
                  ),
                  itemCount: bannerList.length,
                  itemBuilder: (context, index, _) {
                    return InkWell(
                      onTap: () async {
                        var data = bannerDataList![index];
                        if (data is Item) {
                          Get.find<ItemController>().navigateToItemPage(data, context);
                        } else if (data is Store) {
                          if (widget.isFeatured &&
                              (AddressHelper.getUserAddressFromSharedPref()?.zoneData?.isNotEmpty ?? false)) {
                            for (ModuleModel module in Get.find<SplashController>().moduleList!) {
                              if (module.id == data.moduleId) {
                                Get.find<SplashController>().setModule(module);
                                break;
                              }
                            }
                            ZoneData zoneData = AddressHelper.getUserAddressFromSharedPref()!.zoneData!
                                .firstWhere((z) => z.id == data.zoneId);
                            Modules module = zoneData.modules!.firstWhere((m) => m.id == data.moduleId);
                            Get.find<SplashController>().setModule(
                              ModuleModel(
                                id: module.id,
                                moduleName: module.moduleName,
                                moduleType: module.moduleType,
                                themeId: module.themeId,
                                storesCount: module.storesCount,
                              ),
                            );
                          }
                          Get.toNamed(
                            RouteHelper.getStoreRoute(
                              id: data.id,
                              page: widget.isFeatured ? 'module' : 'banner',
                            ),
                            arguments: StoreScreen(store: data, fromModule: widget.isFeatured),
                          );
                        } else if (data is BasicCampaignModel) {
                          Get.toNamed(RouteHelper.getBasicCampaignRoute(data));
                        } else {
                          String url = data;
                          if (await canLaunchUrlString(url)) {
                            await launchUrlString(url, mode: LaunchMode.externalApplication);
                          } else {
                            showCustomSnackBar('unable_to_found_url'.tr);
                          }
                        }
                      },
                      child: SizedBox(
                        width: screenWidth,
                        height: bannerHeight,
                        child: GetBuilder<SplashController>(
                          builder: (splashController) {
                            return CustomImage(
                              image: '${bannerList[index]}',
                              fit: BoxFit.fill ,
                              width: screenWidth,
                              height: bannerHeight,
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: GetBuilder<BannerController>(builder: (controller) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(bannerList.length, (index) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: controller.currentIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                          ),
                        );
                      }),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        )
            : Shimmer(
          duration: const Duration(seconds: 2),
          enabled: bannerList == null,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              color: Colors.grey[300],
            ),
          ),
        ),
      );
    });
  }
}*/
