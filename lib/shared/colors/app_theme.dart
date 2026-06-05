import 'package:flutter/material.dart';

class AppTheme {
  /// COLORS
  static const Color primary = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray = Color(0xFFB0B0B0);
  static const Color red = Color(0xFFCC1B1B);
  static const Color background = Color(0xFFF8F9FB);

  /// LIGHT THEME
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    colorScheme: const ColorScheme.light(primary: primary, error: red),

    scaffoldBackgroundColor: const Color.fromARGB(255, 242, 242, 243),

    /// TEXT THEME
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: primary,
      ),
      
      bodyMedium: TextStyle(
        fontSize: 19,
        color: primary,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: white,
      ),
    ),

    /// TEXT BUTTON THEME (Forgot Password, Register, etc.)
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: red,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    ),

    /// ELEVATED BUTTON THEME
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: white,
        minimumSize: Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),

    /// INPUT FIELD THEME
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: white,
      contentPadding: const EdgeInsets.all(16),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide(color: gray.withValues(alpha: 0.4)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: primary, width: 2),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: red),
      ),
    ),
  );
}
