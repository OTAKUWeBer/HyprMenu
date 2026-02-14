import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF1E1E2E), // Catppuccin Mocha Base
      cardColor: const Color(0xFF313244), // Surface0
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF89B4FA), // Blue
        secondary: const Color(0xFFF5C2E7), // Pink
        surface: const Color(0xFF313244),
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: const Color(0xFFCDD6F4), // Text
        displayColor: const Color(0xFFCDD6F4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF45475A), // Surface1
          foregroundColor: const Color(0xFFCDD6F4),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
