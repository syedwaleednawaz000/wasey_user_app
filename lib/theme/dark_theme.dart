import 'package:flutter/material.dart';
import 'package:sixam_mart/util/app_constants.dart';

ThemeData dark({Color color = const Color(0xFF10B981)}) => ThemeData(
  // fontFamily: AppConstants.fontFamilyIBMPlexSansArabic,
  fontFamily: AppConstants.fontFamilyAlmarai,
  primaryColor: color,
  secondaryHeaderColor: const Color(0xFF06B6D4),
  disabledColor: const Color(0xFF6B7280),
  brightness: Brightness.dark,
  hintColor: const Color(0xFF9CA3AF),
  cardColor: const Color(0xFF1F2937),
  shadowColor: Colors.black.withOpacity(0.05),
  textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white70)),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: color)),
  colorScheme: ColorScheme.dark(
    primary: color,
    secondary: const Color(0xFF06B6D4),
    surface: const Color(0xFF111827),
    error: const Color(0xFFEF4444),
  ),
  popupMenuTheme: const PopupMenuThemeData(color: Color(0xFF1F2937), surfaceTintColor: Color(0xFF1F2937)),
  dialogTheme: const DialogThemeData(surfaceTintColor: Colors.white10),
  floatingActionButtonTheme: FloatingActionButtonThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500))),
  // bottomAppBarTheme: const BottomAppBarTheme(
  //   surfaceTintColor: Colors.black, height: 60,
  //   padding: EdgeInsets.symmetric(vertical: 5),
  // ),
  dividerTheme: const DividerThemeData(thickness: 0.5, color: Color(0xFF374151)),
  tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent),
);