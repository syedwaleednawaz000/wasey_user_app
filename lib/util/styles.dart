import 'package:get/get.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:flutter/material.dart';

final STCRegular = TextStyle(
  // fontFamily: AppConstants.fontFamilyIBMPlexSansArabic,
  fontFamily: AppConstants.fontFamilyAlmarai,
  fontWeight: FontWeight.w400,
  fontSize: Dimensions.fontSizeDefault,
);

final STCMedium = TextStyle(
  // fontFamily: AppConstants.fontFamilyIBMPlexSansArabic,
  fontFamily: AppConstants.fontFamilyAlmarai,
  fontWeight: FontWeight.w500,
  fontSize: Dimensions.fontSizeDefault,
);

final STCBold = TextStyle(
  // fontFamily: AppConstants.fontFamilyIBMPlexSansArabic,
  fontFamily: AppConstants.fontFamilyAlmarai,
  fontWeight: FontWeight.w700,
  fontSize: Dimensions.fontSizeDefault,
);

final STCBlack = TextStyle(
  // fontFamily: AppConstants.fontFamilyIBMPlexSansArabic,
  fontFamily: AppConstants.fontFamilyAlmarai,
  fontWeight: FontWeight.w900,
  fontSize: Dimensions.fontSizeDefault,
);

final BoxDecoration riderContainerDecoration = BoxDecoration(
  borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
  color: Theme.of(Get.context!).primaryColor.withAlpha((0.1 * 255).toInt()),
  shape: BoxShape.rectangle,
);

Color CardRed = Color(0xffbf0034);
