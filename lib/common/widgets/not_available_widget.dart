import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotAvailableWidget extends StatelessWidget {
  final double fontSize;
  final bool isStore;
  final bool isAllSideRound;
  final double? radius;
  final Store? store;
  const NotAvailableWidget(
      {super.key,
      this.fontSize = 12,
      this.isStore = false,
      this.isAllSideRound = true,
      this.radius = Dimensions.radiusSmall,
      this.store});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      bottom: 0,
      right: 0,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: isAllSideRound
                ? BorderRadius.circular(radius!)
                : BorderRadius.vertical(top: Radius.circular(radius!)),
            color: Colors.black.withAlpha((0.6 * 255).toInt())),
       child: Text(
  isStore
      ? store != null
          ? store!.storeOpeningTime == 'closed' // أولاً نتحقق إذا خارج ساعات العمل
              ? 'closed_now'.tr // "مغلق الآن"
              : !store!.active! // ثم نتحقق إذا مغلق مؤقتاً
                  ? 'temporarily_closed'.tr // "مغلق مؤقتًا"
                  : '${'closed_now'.tr} ${'(${'open_at'.tr} ${DateConverter.convertRestaurantOpenTime(store!.storeOpeningTime!)})'}'
          : 'closed_now'.tr
      : 'not_available_now_break'.tr,
  textAlign: TextAlign.center,
  style: STCMedium.copyWith(color: Colors.white, fontSize: fontSize),
),

      ),
    );
  }
}
