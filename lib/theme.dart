import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

// Global Theme Data for professional look
ThemeData getLightThemeProvider(bool isModern) {
  final primaryColor = isModern ? AppColors.primaryButton : const Color(0xFF2196F3);
  final scaffoldColor = isModern ? const Color(0xFFFBFBFD) : Colors.white;
  final appBarColor = isModern ? AppColors.primaryBg : const Color(0xFF1976D2);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    textTheme: GoogleFonts.outfitTextTheme(),
    primaryColor: primaryColor,
    scaffoldBackgroundColor: scaffoldColor,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: isModern ? appBarColor : Colors.black87),
      titleTextStyle: TextStyle(color: isModern ? appBarColor : Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: isModern ? AppColors.primaryBg : const Color(0xFF1E88E5),
      surface: Colors.white,
      onSurface: isModern ? AppColors.primaryBg : Colors.black87,
    ),
    cardTheme: CardTheme(
      elevation: isModern ? 0 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isModern ? 24 : 12)),
      color: Colors.white,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

ThemeData getDarkThemeProvider(bool isModern) {
  final primaryColor = isModern ? AppColors.primaryButton : const Color(0xFF64B5F6);
  final scaffoldColor = isModern ? AppColors.darkBg : const Color(0xFF121212);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    primaryColor: primaryColor,
    scaffoldBackgroundColor: scaffoldColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    ),
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: isModern ? AppColors.accent : const Color(0xFF42A5F5),
      surface: isModern ? const Color(0xFF162D2E) : const Color(0xFF1E1E1E),
      onSurface: Colors.white,
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isModern ? 24 : 12)),
      color: Colors.white.withValues(alpha: 0.05),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
