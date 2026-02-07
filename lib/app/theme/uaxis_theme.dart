import 'package:flutter/material.dart';

abstract final class UAxisColors {
  static const Color backgroundBase = Color(0xFF000000);
  static const Color backgroundLight = Color(0xFFF5F5F7);
  
  static const Color discoverPremium = Color(0xFF3B82F6);
  static const Color discoverPremiumGlow = Color(0x403B82F6);
  
  static const Color social = Color(0xFFEC4899);
  static const Color socialGlow = Color(0x40EC4899);
  
  static const Color messagesCommerce = Color(0xFF10B981);
  static const Color messagesCommerceGlow = Color(0x4010B981);
  
  static const Color businessAi = Color(0xFF8B5CF6);
  static const Color businessAiGlow = Color(0x408B5CF6);
  
  static const Color aiHub = Color(0xFF06B6D4);
  static const Color aiHubGlow = Color(0x4006B6D4);
  
  static const Color starParticles = Color(0x26615FFF);
  
  static const Color surfaceDark = Color(0xFF0A0A0A);
  static const Color surfaceContainerDark = Color(0xFF121212);
  static const Color onSurfaceDark = Color(0xFFFFFFFF);
  static const Color onSurfaceVariantDark = Color(0xFFB3B3B3);

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceContainerLight = Color(0xFFF0F0F0);
  static const Color onSurfaceLight = Color(0xFF1A1A1A);
  static const Color onSurfaceVariantLight = Color(0xFF666666);
}

abstract final class UAxisTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: UAxisColors.backgroundBase,
      fontFamily: null,
      fontFamilyFallback: const [
        'Segoe UI',
        'SF Arabic', 
        'Segoe UI Arabic',
        'Roboto',
        'sans-serif',
      ],
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 72,
          fontWeight: FontWeight.bold,
          height: 1.2,
          letterSpacing: -1.44,
        ),
        displayMedium: TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.bold,
          height: 1.2,
          letterSpacing: -1.12,
        ),
        displaySmall: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          height: 1.2,
          letterSpacing: -0.8,
        ),
        headlineMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          height: 1.25,
          letterSpacing: -0.64,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.25,
          letterSpacing: -0.48,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.25,
          letterSpacing: -0.4,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          height: 1.5,
          letterSpacing: 0,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: 1.5,
          letterSpacing: 0,
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          height: 1.5,
          letterSpacing: 0,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.2,
          letterSpacing: 0,
        ),
      ).apply(
        bodyColor: UAxisColors.onSurfaceDark,
        displayColor: UAxisColors.onSurfaceDark,
      ),
      colorScheme: const ColorScheme.dark(
        primary: UAxisColors.discoverPremium,
        secondary: UAxisColors.social,
        tertiary: UAxisColors.messagesCommerce,
        surface: UAxisColors.surfaceDark,
        onSurface: UAxisColors.onSurfaceDark,
        onSurfaceVariant: UAxisColors.onSurfaceVariantDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: UAxisColors.backgroundBase,
        foregroundColor: UAxisColors.onSurfaceDark,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: UAxisColors.surfaceContainerDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: UAxisColors.discoverPremium,
          foregroundColor: UAxisColors.onSurfaceDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: UAxisColors.discoverPremium,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: UAxisColors.surfaceContainerDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: UAxisColors.discoverPremium, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: UAxisColors.surfaceDark,
        selectedItemColor: UAxisColors.discoverPremium,
        unselectedItemColor: UAxisColors.onSurfaceVariantDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: UAxisColors.surfaceContainerDark,
        thickness: 1,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: UAxisColors.backgroundLight,
      fontFamily: null,
      fontFamilyFallback: const [
        'Segoe UI',
        'SF Arabic', 
        'Segoe UI Arabic',
        'Roboto',
        'sans-serif',
      ],
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 72,
          fontWeight: FontWeight.bold,
          height: 1.2,
          letterSpacing: -1.44,
        ),
        displayMedium: TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.bold,
          height: 1.2,
          letterSpacing: -1.12,
        ),
        displaySmall: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          height: 1.2,
          letterSpacing: -0.8,
        ),
        headlineMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          height: 1.25,
          letterSpacing: -0.64,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.25,
          letterSpacing: -0.48,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.25,
          letterSpacing: -0.4,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          height: 1.5,
          letterSpacing: 0,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: 1.5,
          letterSpacing: 0,
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          height: 1.5,
          letterSpacing: 0,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.2,
          letterSpacing: 0,
        ),
      ).apply(
        bodyColor: UAxisColors.onSurfaceLight,
        displayColor: UAxisColors.onSurfaceLight,
      ),
      colorScheme: const ColorScheme.light(
        primary: UAxisColors.discoverPremium,
        secondary: UAxisColors.social,
        tertiary: UAxisColors.messagesCommerce,
        surface: UAxisColors.surfaceLight,
        onSurface: UAxisColors.onSurfaceLight,
        onSurfaceVariant: UAxisColors.onSurfaceVariantLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: UAxisColors.backgroundLight,
        foregroundColor: UAxisColors.onSurfaceLight,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: UAxisColors.surfaceContainerLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: UAxisColors.discoverPremium,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: UAxisColors.discoverPremium,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: UAxisColors.surfaceContainerLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: UAxisColors.discoverPremium, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: UAxisColors.surfaceLight,
        selectedItemColor: UAxisColors.discoverPremium,
        unselectedItemColor: UAxisColors.onSurfaceVariantLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: UAxisColors.surfaceContainerLight,
        thickness: 1,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
