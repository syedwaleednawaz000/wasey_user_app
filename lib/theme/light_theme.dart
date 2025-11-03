import 'package:flutter/material.dart';
import 'package:sixam_mart/util/app_constants.dart';


// Light Theme
ThemeData light(
    {Color color = const Color(0xFF10B981)}) => ThemeData(
  // fontFamily: AppConstants.fontFamilyIBMPlexSansArabic,
  fontFamily: AppConstants.fontFamilyAlmarai,
  primaryColor: color,
  secondaryHeaderColor: const Color(0xFF06B6D4),
  disabledColor: const Color(0xFF9CA3AF),
  brightness: Brightness.light,
  hintColor: const Color(0xFF6B7280),
  cardColor: Colors.white,
  shadowColor: Colors.black.withOpacity(0.05),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: color)),
  colorScheme: ColorScheme.light(
    primary: color,
    secondary: const Color(0xFF06B6D4),
    surface: const Color(0xFFF9FAFB),
    error: const Color(0xFFEF4444),
  ),
  popupMenuTheme: const PopupMenuThemeData(color: Colors.white, surfaceTintColor: Colors.white),
  dialogTheme: const DialogThemeData(surfaceTintColor: Colors.white),
  floatingActionButtonTheme: FloatingActionButtonThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500))),
  bottomAppBarTheme: const BottomAppBarTheme(
    surfaceTintColor: Colors.white, height: 60,
    padding: EdgeInsets.symmetric(vertical: 5),
  ),
  dividerTheme: const DividerThemeData(thickness: 0.5, color: Color(0xFFE5E7EB)),
  tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent),
);