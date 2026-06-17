import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF004AAD);
  static const Color secondaryColor = Color(0xFFA1D7E8);
  static const Color backgroundColor = Color(0xFFF5F9FF);
  static const Color surfaceColor = Color(0xFFF5F4F2);
  static const Color errorColor = Color(0xFFD32F2F);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Colors.white;

  // Text Styles
  static TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    fontFamily: 'Gloock',
  );

  static TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    fontFamily: 'Gloock',
  );

  static TextStyle headingSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    fontFamily: 'Gloock',
  );

  static TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    fontFamily: 'Inter',
  );

  static TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    fontFamily: 'Inter',
  );

  static TextStyle captionStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    fontFamily: 'Inter',
  );

  // Card Decoration
  static BoxDecoration cardDecoration = BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Primary Button Style
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: textLight,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: 32,
      vertical: 14,
    ),
  );

  // Tombol generate bulat besar di home
  static BoxDecoration fabDecoration = BoxDecoration(
    color: primaryColor,
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.4),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );

  // Theme Data untuk MaterialApp
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: backgroundColor,
      error: errorColor,
    ),

    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: headingSmall,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: primaryButtonStyle,
    ),

    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}