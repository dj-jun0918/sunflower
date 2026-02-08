import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// Solar Eye 앱 테마
/// 흰색 배경 + 블루 포인트 + Pretendard 폰트
class AppTheme {
  // Pretendard 폰트 패밀리
  // Pretendard 폰트 패밀리
  // static const String fontFamily = 'Pretendard';
  static const String? fontFamily = null;

  // ============================================================
  // Light Theme (기본)
  // ============================================================

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: fontFamily,

    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.text1,
      error: AppColors.danger,
      onError: Colors.white,
    ),

    // Scaffold
    scaffoldBackgroundColor: AppColors.background,

    // AppBar
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    // Card
    cardTheme: CardThemeData(
      elevation: 2,
      color: AppColors.card,
      shadowColor: AppColors.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // Bottom Navigation
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.text3,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      hintStyle: const TextStyle(
        fontFamily: fontFamily,
        color: AppColors.text3,
      ),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700),
      displayMedium:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700),
      displaySmall:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700),
      headlineLarge:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      headlineMedium:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      headlineSmall:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      titleLarge:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500),
      titleMedium:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500),
      titleSmall:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400),
      bodyMedium:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400),
      labelLarge:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500),
      labelMedium:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500),
      labelSmall:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500),
    ),
  );

  // ============================================================
  // Dark Theme
  // ============================================================

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: fontFamily,

    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryLight,
      onPrimary: AppColors.backgroundDark,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.text1Dark,
      error: AppColors.danger,
      onError: Colors.black,
    ),

    // Scaffold
    scaffoldBackgroundColor: AppColors.backgroundDark,

    // AppBar
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.text1Dark,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.text1Dark,
      ),
    ),

    // Card
    cardTheme: CardThemeData(
      elevation: 4,
      color: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Bottom Navigation
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: AppColors.text3Dark,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
      ),
      hintStyle: const TextStyle(
        fontFamily: fontFamily,
        color: AppColors.text3Dark,
      ),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.borderDark,
      thickness: 1,
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700),
      displayMedium:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700),
      displaySmall:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700),
      headlineLarge:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      headlineMedium:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      headlineSmall:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      titleLarge:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500),
      titleMedium:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500),
      titleSmall:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400),
      bodyMedium:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400),
      labelLarge:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500),
      labelMedium:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500),
      labelSmall:
          TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500),
    ),
  );
}
