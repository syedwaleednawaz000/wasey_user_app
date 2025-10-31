import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/hover/text_hover.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/discount_tag.dart';
import 'package:sixam_mart/common/widgets/hover/on_hover.dart';
import 'package:sixam_mart/common/widgets/not_available_widget.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';

import '../../../../../helper/date_converter.dart';

class StoreCardWidget extends StatelessWidget {
  final Store? store;

  const StoreCardWidget({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    double? discount = store!.discount != null ? store!.discount!.discount : 0;
    String? discountType =
        store!.discount != null ? store!.discount!.discountType : 'percent';
    bool isAvailable =
        store!.storeOpeningTime != 'closed' && store!.active == 1;
    return OnHover(
      isItem: true,
      child: TextHover(builder: (hovered) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            border: Border.all(
                color: Theme.of(context)
                    .disabledColor
                    .withAlpha((0.1 * 255).toInt())),
            boxShadow: ResponsiveHelper.isDesktop(context)
                ? []
                : const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      spreadRadius: .5,
                    )
                  ],
          ),
          child: CustomInkWell(
            onTap: () {
              if (store != null) {
                log("I am in store is not null...........");
                if (Get.find<SplashController>().moduleList != null) {
                  log("I am in store module list is not null...........");

                  for (ModuleModel module
                      in Get.find<SplashController>().moduleList!) {
                    if (module.id == store!.moduleId) {
                      log("i am in for if statement ...........");

                      Get.find<SplashController>().setModule(module);
                      break;
                    }
                  }
                }
                log("Store Id is: ${store!.id.toString()}");
                Get.toNamed(
                  RouteHelper.getStoreRoute(id: store!.id, page: 'item'),
                  arguments: StoreScreen(
                    store: store,
                    fromModule: false,
                    isNewSuperMarket: store!.moduleId == 1 ? true : false,
                  ),
                );
              }
            },
            radius: Dimensions.radiusSmall,
            padding: const EdgeInsets.all(1),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(clipBehavior: Clip.none, children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(
                          Dimensions.radiusSmall,
                        ),
                      ),
                      child: CustomImage(
                        isHovered: hovered,
                        image: '${store!.coverPhotoFullUrl}',
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    DiscountTag(
                      discount: discount,
                      discountType: discountType,
                    ),
                    isAvailable
                        ? const SizedBox()
                        : NotAvailableWidget(
                            isStore: true,
                            store: store,
                            fontSize: Dimensions.fontSizeExtraSmall,
                            isAllSideRound: false),
                    Positioned(
                      top: Dimensions.paddingSizeSmall,
                      right: Dimensions.paddingSizeSmall,
                      child: GetBuilder<FavouriteController>(
                          builder: (favouriteController) {
                        bool isWished = favouriteController.wishStoreIdList
                            .contains(store!.id);
                        return InkWell(
                          onTap: () {
                            if (AuthHelper.isLoggedIn()) {
                              isWished
                                  ? favouriteController.removeFromFavouriteList(
                                      store!.id, true)
                                  : favouriteController.addToFavouriteList(
                                      null, store?.id, true);
                            } else {
                              showCustomSnackBar('you_are_not_logged_in'.tr);
                            }
                          },
                          child: Icon(
                            isWished ? Icons.favorite : Icons.favorite_border,
                            size: 24,
                            color: isWished
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).disabledColor,
                          ),
                        );
                      }),
                    ),
                    // store!.logoFullUrl != ""
                    //     ? Positioned(
                    //         bottom: -40,
                    //         left: Get.find<LocalizationController>().isLtr
                    //             ? null
                    //             : 10,
                    //         right: Get.find<LocalizationController>().isLtr
                    //             ? 10
                    //             : null,
                    //         child: Container(
                    //           width: 80,
                    //           height: 80,
                    //           decoration: BoxDecoration(
                    //             borderRadius: BorderRadius.circular(
                    //                 Dimensions.radiusLarge),
                    //             boxShadow: [
                    //               BoxShadow(
                    //                 color: Colors.black.withOpacity(0.3),
                    //                 spreadRadius: 1,
                    //                 blurRadius: 5,
                    //                 offset: const Offset(
                    //                   0,
                    //                   2,
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //           child: ClipRRect(
                    //             borderRadius: BorderRadius.circular(
                    //                 Dimensions.radiusLarge),
                    //             child: CachedNetworkImage(
                    //               imageUrl: store!.logoFullUrl.toString(),
                    //               fit: BoxFit.fill,
                    //               errorWidget: (context, url, error) =>
                    //                   const Icon(
                    //                 Icons.storefront,
                    //                 color: Colors.grey,
                    //               ), // Optional: good for UX
                    //             ),
                    //           ),
                    //         ),
                    //       )
                    //     : const SizedBox(),
                  ]),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall,
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              store!.name ?? '',
                              style: STCMedium.copyWith(
                                  fontSize: Dimensions.fontSizeDefault),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(
                              height: Dimensions.paddingSizeExtraSmall,
                            ),
                            Text(
                              store!.address ?? '',
                              style: STCMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).disabledColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Divider(),
                            // const SizedBox(
                            //   height: Dimensions.paddingSizeExtraSmall,
                            // ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 12,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  store!.avgRating.toString() ?? '',
                                  style: STCMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    // color: Theme.of(context).disabledColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  "(${store!.ratings!.first > 200 ? "200+" : store!.ratings?.first.toString() ?? ''})",
                                  style: STCMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: Dimensions.paddingSizeExtraSmall,
                            ),
                            // Text("open:${store!.open} and active: ${store!.active}"),
                            // Text(
                            //   store != null
                            //       ? store!.storeOpeningTime ==
                            //               'closed'
                            //           ? 'closed_now'.tr // "مغلق الآن"
                            //           : store!.active !=
                            //                   1 // ثم نتحقق إذا مغلق مؤقتاً
                            //               ? 'temporarily_closed'
                            //                   .tr // "مغلق مؤقتًا"
                            //               : '${'closed_now'.tr} ${'(${'open_at'.tr} ${DateConverter.convertRestaurantOpenTime(store!.storeOpeningTime!)})'}'
                            //       : 'closed_now'.tr,
                            //   // : 'not_available_now_break'.tr,
                            //   style: STCMedium.copyWith(
                            //     fontSize: Dimensions.fontSizeExtraSmall,
                            //     color: Theme.of(context).disabledColor,
                            //   ),
                            //   maxLines: 2,
                            //   overflow: TextOverflow.ellipsis,
                            // ),
                            Text(
                              store != null
                                  ? store!.storeOpeningTime ==
                                          'closed' // أولاً نتحقق إذا خارج ساعات العمل
                                      ? 'closed_now'.tr
                                      : store!.active == 0
                                          ? 'temporarily_closed'.tr
                                          : store!.active == -1
                                              ? 'busy'.tr
                                              : store!.active == 1
                                                  ? 'open'.tr
                                                  : '${'closed_now'.tr} ${'(${'open_at'.tr} ${DateConverter.convertRestaurantOpenTime(store!.storeOpeningTime!)})'}'
                                  : 'closed_now'.tr,
                              // : 'not_available_now_break'.tr,
                              style: STCMedium.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: store!.storeOpeningTime == 'closed'
                                    ? Colors.red
                                    : store!.active == 0
                                        ? Colors.red
                                        : store!.active == -1
                                            ? Colors.blue
                                            : store!.active == 1
                                                ? Colors.green
                                                : Theme.of(context)
                                                    .disabledColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(
                              height: Dimensions.paddingSizeExtraSmall,
                            ),
                            // Row(children: [
                            //   store!.freeDelivery!
                            //       ? Row(children: [
                            //           Image.asset(Images.deliveryIcon,
                            //               height: 15,
                            //               width: 15,
                            //               color: Theme.of(context)
                            //                   .primaryColor),
                            //           const SizedBox(
                            //               width: Dimensions
                            //                   .paddingSizeExtraSmall),
                            //           Text(
                            //             'free_delivery'.tr,
                            //             style: STCMedium.copyWith(
                            //                 fontSize:
                            //                     Dimensions.fontSizeSmall,
                            //                 color: Theme.of(context)
                            //                     .disabledColor),
                            //           ),
                            //         ])
                            //       : const SizedBox(),
                            //   SizedBox(
                            //       width: store!.freeDelivery!
                            //           ? Dimensions.paddingSizeSmall
                            //           : 0),
                            //   Row(children: [
                            //     Icon(Icons.timer,
                            //         size: 15,
                            //         color: Theme.of(context).primaryColor),
                            //     const SizedBox(
                            //         width:
                            //             Dimensions.paddingSizeExtraSmall),
                            //     Text(
                            //       '${store!.deliveryTime}',
                            //       style: STCMedium.copyWith(
                            //           fontSize: Dimensions.fontSizeSmall,
                            //           color:
                            //               Theme.of(context).disabledColor),
                            //     ),
                            //   ]),
                            // ]),
                          ]),
                    ),
                  ),
                ]),
          ),
        );
      }),
    );
  }
}
// class StoreCardWidget extends StatelessWidget {
//   final Store? store;
//
//   const StoreCardWidget({super.key, required this.store});
//
//   @override
//   Widget build(BuildContext context) {
//     double? discount = store!.discount != null ? store!.discount!.discount : 0;
//     String? discountType =
//         store!.discount != null ? store!.discount!.discountType : 'percent';
//     bool isAvailable = store!.open == 1 && store!.active == 1;
//     return OnHover(
//       isItem: true,
//       child: TextHover(builder: (hovered) {
//         return Container(
//           width: double.infinity,
//           decoration: BoxDecoration(
//             color: Theme.of(context).cardColor,
//             borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
//             border: Border.all(
//                 color: Theme.of(context)
//                     .disabledColor
//                     .withAlpha((0.1 * 255).toInt())),
//             boxShadow: ResponsiveHelper.isDesktop(context)
//                 ? []
//                 : const [
//                     BoxShadow(
//                         color: Colors.black12, blurRadius: 5, spreadRadius: 1)
//                   ],
//           ),
//           child: CustomInkWell(
//             onTap: () {
//               if (store != null) {
//                 log("I am in store is not null...........");
//                 if (Get.find<SplashController>().moduleList != null) {
//                   log("I am in store module list is not null...........");
//
//                   for (ModuleModel module
//                       in Get.find<SplashController>().moduleList!) {
//                     if (module.id == store!.moduleId) {
//                       log("i am in for if statement ...........");
//
//                       Get.find<SplashController>().setModule(module);
//                       break;
//                     }
//                   }
//                 }
//                 log("Store Id is: ${store!.id.toString()}");
//                 Get.toNamed(
//                   RouteHelper.getStoreRoute(id: store!.id, page: 'item'),
//                   arguments: StoreScreen(
//                     store: store,
//                     fromModule: false,
//                     isNewSuperMarket: store!.moduleId == 1 ? true : false,
//                   ),
//                 );
//               }
//             },
//             radius: Dimensions.radiusDefault,
//             padding: const EdgeInsets.all(1),
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Stack(clipBehavior: Clip.none, children: [
//                     ClipRRect(
//                       borderRadius: const BorderRadius.vertical(
//                           top: Radius.circular(Dimensions.radiusDefault)),
//                       child: CustomImage(
//                         isHovered: hovered,
//                         image: '${store!.coverPhotoFullUrl}',
//                         height: 120,
//                         width: double.infinity,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     DiscountTag(
//                       discount: discount,
//                       discountType: discountType,
//                     ),
//                     isAvailable
//                         ? const SizedBox()
//                         : NotAvailableWidget(
//                             isStore: true,
//                             store: store,
//                             fontSize: Dimensions.fontSizeExtraSmall,
//                             isAllSideRound: false),
//                     Positioned(
//                       top: Dimensions.paddingSizeSmall,
//                       right: Dimensions.paddingSizeSmall,
//                       child: GetBuilder<FavouriteController>(
//                           builder: (favouriteController) {
//                         bool isWished = favouriteController.wishStoreIdList
//                             .contains(store!.id);
//                         return InkWell(
//                           onTap: () {
//                             if (AuthHelper.isLoggedIn()) {
//                               isWished
//                                   ? favouriteController.removeFromFavouriteList(
//                                       store!.id, true)
//                                   : favouriteController.addToFavouriteList(
//                                       null, store?.id, true);
//                             } else {
//                               showCustomSnackBar('you_are_not_logged_in'.tr);
//                             }
//                           },
//                           child: Icon(
//                             isWished ? Icons.favorite : Icons.favorite_border,
//                             size: 24,
//                             color: isWished
//                                 ? Theme.of(context).primaryColor
//                                 : Theme.of(context).disabledColor,
//                           ),
//                         );
//                       }),
//                     ),
//                     store!.logoFullUrl != ""
//                         ? Positioned(
//                             bottom: -40,
//                             left: Get.find<LocalizationController>().isLtr
//                                 ? null
//                                 : 10,
//                             right: Get.find<LocalizationController>().isLtr
//                                 ? 10
//                                 : null,
//                             child: Container(
//                               width: 80,
//                               height: 80,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(
//                                     Dimensions.radiusLarge),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.3),
//                                     spreadRadius: 1,
//                                     blurRadius: 5,
//                                     offset: const Offset(
//                                       0,
//                                       2,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(
//                                     Dimensions.radiusLarge),
//                                 child: CachedNetworkImage(
//                                   imageUrl: store!.logoFullUrl.toString(),
//                                   fit: BoxFit.fill,
//                                   errorWidget: (context, url, error) =>
//                                       const Icon(
//                                     Icons.storefront,
//                                     color: Colors.grey,
//                                   ), // Optional: good for UX
//                                 ),
//                               ),
//                             ),
//                           )
//                         : const SizedBox(),
//                   ]),
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: Dimensions.paddingSizeSmall),
//                       child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             SizedBox(
//                               width: context.width * 0.6,
//                               child: Text(
//                                 store!.name ?? '',
//                                 style: STCMedium.copyWith(
//                                     fontSize: Dimensions.fontSizeDefault),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                             const SizedBox(
//                               height: Dimensions.paddingSizeExtraSmall,
//                             ),
//                             SizedBox(
//                               width: Get.size.width * 0.6,
//                               child: Text(
//                                 store!.address ?? '',
//                                 style: STCMedium.copyWith(
//                                   fontSize: Dimensions.fontSizeSmall,
//                                   color: Theme.of(context).disabledColor,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                             // const SizedBox(
//                             //     height: Dimensions.paddingSizeExtraSmall,),
//                             // Row(children: [
//                             //   store!.freeDelivery!
//                             //       ? Row(children: [
//                             //           Image.asset(Images.deliveryIcon,
//                             //               height: 15,
//                             //               width: 15,
//                             //               color: Theme.of(context)
//                             //                   .primaryColor),
//                             //           const SizedBox(
//                             //               width: Dimensions
//                             //                   .paddingSizeExtraSmall),
//                             //           Text(
//                             //             'free_delivery'.tr,
//                             //             style: STCMedium.copyWith(
//                             //                 fontSize:
//                             //                     Dimensions.fontSizeSmall,
//                             //                 color: Theme.of(context)
//                             //                     .disabledColor),
//                             //           ),
//                             //         ])
//                             //       : const SizedBox(),
//                             //   SizedBox(
//                             //       width: store!.freeDelivery!
//                             //           ? Dimensions.paddingSizeSmall
//                             //           : 0),
//                             //   Row(children: [
//                             //     Icon(Icons.timer,
//                             //         size: 15,
//                             //         color: Theme.of(context).primaryColor),
//                             //     const SizedBox(
//                             //         width:
//                             //             Dimensions.paddingSizeExtraSmall),
//                             //     Text(
//                             //       '${store!.deliveryTime}',
//                             //       style: STCMedium.copyWith(
//                             //           fontSize: Dimensions.fontSizeSmall,
//                             //           color:
//                             //               Theme.of(context).disabledColor),
//                             //     ),
//                             //   ]),
//                             // ]),
//                           ]),
//                     ),
//                   ),
//                 ]),
//           ),
//         );
//       }),
//     );
//   }
// }

class StoreCardShimmer extends StatelessWidget {
  const StoreCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      width: 500,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(Dimensions.radiusSmall)),
              color: Theme.of(context).shadowColor,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        height: 15,
                        width: 200,
                        color: Theme.of(context).shadowColor),
                    const SizedBox(height: 5),
                    Container(
                        height: 10,
                        width: 130,
                        color: Theme.of(context).shadowColor),
                    const SizedBox(height: 5),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(Icons.star,
                            color: Theme.of(context).shadowColor, size: 15);
                      }),
                    ),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }
}
