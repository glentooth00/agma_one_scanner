
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // AGMA ONE BRAND COLORS
  static const Color primary = Color(0xFF172B3A);
  static const Color primaryLight = Color(0xFF243F52);

  static const Color sage = Color(0xFF789A60);
  static const Color sageLight = Color(0xFFEEF3E9);

  static const Color background = Color(0xFFF7F8F6);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF172B3A);
  static const Color textSecondary = Color(0xFF64748B);

  static const Color border = Color(0xFFE6EBE3);
  static const Color success = Color(0xFF32845B);
  static const Color warning = Color(0xFFD69B36);
  static const Color error = Color(0xFFCF5353);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      secondary: sage,
      surface: surface,
      error: error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,

      // TYPOGRAPHY
      textTheme: ThemeData.light().textTheme.apply(
        fontFamily: GoogleFonts.inter().fontFamily,
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),

      // APP BAR
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: primary,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),

      // CARDS
      cardColor: surface,

      // INPUT FIELDS
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF9AA4AF),
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: sage,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: error),
        ),
      ),

      // ELEVATED BUTTONS
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // OUTLINED BUTTONS
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // NAVIGATION BAR
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        height: 72,
        indicatorColor: sageLight,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: sage,
              size: 23,
            );
          }

          return const IconThemeData(
            color: textSecondary,
            size: 22,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? primary
                : textSecondary,
          );
        }),
      ),

      // DIVIDERS
      dividerColor: border,

      // ICONS
      iconTheme: const IconThemeData(
        color: primary,
      ),
    );
  }
}
