import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/home/widgets/filter_view.dart';
import 'package:sixam_mart/features/home/widgets/store_filter_button_widget.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

import '../../../helper/module_helper.dart';
import '../../../util/app_constants.dart';

class AllStoreFilterWidget extends StatelessWidget {
  const AllStoreFilterWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool? showRestaurantText = ModuleHelper.getModule()?.id.toString() ==
        AppConstants.restaurantModuleId;
    return GetBuilder<StoreController>(builder: (storeController) {
      return Center(
        child: Container(
          width: Dimensions.webMaxWidth,
          transform: Matrix4.translationValues(0, -2, 0),
          color: Theme.of(context).colorScheme.surface,
          // color: Theme.of(context).disabledColor,
          padding: const EdgeInsets.only(
            left: Dimensions.paddingSizeDefault,
            right: Dimensions.paddingSizeDefault,
            // top: Dimensions.paddingSizeSmall
          ),
          child: ResponsiveHelper.isDesktop(context)
              ? Row(children: [
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            showRestaurantText ? 'restaurants'.tr : 'stores'.tr,
                            style: STCBold.copyWith(
                                fontSize: Dimensions.fontSizeLarge),
                          ),
                          Text(
                            '${storeController.storeModel?.totalSize ?? 0} ${showRestaurantText ? 'restaurants_near_you'.tr : 'stores_near_you'.tr}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: STCRegular.copyWith(
                                color: Theme.of(context).disabledColor,
                                fontSize: Dimensions.fontSizeSmall),
                          ),
                        ]),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  filter(context, storeController),
                ])
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              showRestaurantText
                                  ? 'restaurants'.tr
                                  : 'stores'.tr,
                              style: STCBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge),
                            ),
                            Text(
                              '${storeController.storeModel?.totalSize ?? 0} ${showRestaurantText ? 'restaurants_near_you'.tr : 'stores_near_you'.tr}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: STCRegular.copyWith(
                                  color: Theme.of(context).disabledColor,
                                  fontSize: Dimensions.fontSizeSmall),
                            ),

                            // Flexible(
                            //   child: Text(
                            //     '${storeController.storeModel?.totalSize ?? 0} ${Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! ? 'restaurants_near_you'.tr : 'stores_near_you'.tr}',
                            //     maxLines: 1,
                            //     overflow: TextOverflow.ellipsis,
                            //     style: STCRegular.copyWith(
                            //         color: Theme.of(context).disabledColor,
                            //         fontSize: Dimensions.fontSizeSmall),
                            //   ),
                            // ),
                          ]),
                      // const SizedBox(height: Dimensions.paddingSizeSmall),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: StoreFilterButtonWidget(
                            buttonText: 'see_all'.tr,
                            onTap: () => Get.toNamed(RouteHelper.allStores),
                            isSelected: true,
                            isSeeAll: true,
                            // isSelected: storeController.storeType == 'all',
                          ),
                        ),
                      )
                      // filter(context, storeController),
                    ]),
        ),
      );
    });
  }

  Widget filter(BuildContext context, StoreController storeController) {
    return SizedBox(
      height: ResponsiveHelper.isDesktop(context) ? 40 : 30,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ListView(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: [
            ResponsiveHelper.isDesktop(context)
                ? const SizedBox()
                : FilterView(storeController: storeController),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            // StoreFilterButtonWidget(
            //   buttonText: 'see_all'.tr,
            //   onTap: () => Get.toNamed(RouteHelper.allStores),
            //   isSelected: true,
            //   isSeeAll: true,
            //   // isSelected: storeController.storeType == 'all',
            // ),
            // const SizedBox(width: Dimensions.paddingSizeSmall),

            StoreFilterButtonWidget(
              buttonText: 'all'.tr,
              onTap: () => storeController.setStoreType('all'),
              isSelected: storeController.storeType == 'all',
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            StoreFilterButtonWidget(
              buttonText: 'newly_joined'.tr,
              onTap: () => storeController.setStoreType('newly_joined'),
              isSelected: storeController.storeType == 'newly_joined',
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            StoreFilterButtonWidget(
              buttonText: 'popular'.tr,
              onTap: () => storeController.setStoreType('popular'),
              isSelected: storeController.storeType == 'popular',
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            StoreFilterButtonWidget(
              buttonText: 'top_rated'.tr,
              onTap: () => storeController.setStoreType('top_rated'),
              isSelected: storeController.storeType == 'top_rated',
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            ResponsiveHelper.isDesktop(context)
                ? FilterView(storeController: storeController)
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
