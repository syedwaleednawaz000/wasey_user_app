import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/hover/text_hover.dart';
import 'package:sixam_mart/common/widgets/not_available_widget.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';

class VisitAgainCard extends StatelessWidget {
  final Store store;
  final bool fromFood;
  const VisitAgainCard({super.key, required this.store, required this.fromFood});

  @override
  Widget build(BuildContext context) {
    bool isAvailable = store.open == 1 && store.active == 1;

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          RouteHelper.getStoreRoute(id: store.id, page: 'store'),
          arguments: StoreScreen(store: store, fromModule: false),
        );
      },
      child: Stack(
        children: [
          // صورة الشعار كخلفية كاملة للبطاقة
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: Stack(
              children: [
                CustomImage(
                  image: store.logoFullUrl ?? '',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.0),
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: Dimensions.paddingSizeSmall,
                  right: Dimensions.paddingSizeSmall,
                  bottom: Dimensions.paddingSizeDefault,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name ?? '',
                        style: STCBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black54,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.yellow[700]),
                          const SizedBox(width: 4),
                          Text(
                            '${store.avgRating?.toStringAsFixed(1) ?? '0.0'} (${store.ratingCount})',
                            style: STCRegular.copyWith(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (!isAvailable)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Center(
                  child: Text(
                    'not_available_now'.tr,
                    style: STCBold.copyWith(
                      color: Colors.white,
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                  ),
                ),
              ),
            ),

          // أيقونة المفضلة
          Positioned(
            top: 10,
            right: 10,
            child: GetBuilder<FavouriteController>(builder: (favouriteController) {
              bool isWished = favouriteController.wishStoreIdList.contains(store.id);
              return InkWell(
                onTap: () {
                  if (AuthHelper.isLoggedIn()) {
                    isWished
                        ? favouriteController.removeFromFavouriteList(store.id, true)
                        : favouriteController.addToFavouriteList(null, store.id, true);
                  } else {
                    showCustomSnackBar('you_are_not_logged_in'.tr);
                  }
                },
                child: Icon(
                  isWished ? Icons.favorite : Icons.favorite_border,
                  size: 24,
                  color: Colors.white,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
