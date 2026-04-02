import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AveroThemeStyle { neoBrutalist, calming, oled, glassmorphic, neumorphic, appleLike }

final ValueNotifier<AveroThemeStyle> appThemeNotifier = ValueNotifier(AveroThemeStyle.neoBrutalist);

TextStyle getThemeTextStyle({double? fontSize, FontWeight? fontWeight, Color? color, double? height, double? letterSpacing}) {
  switch (appThemeNotifier.value) {
    case AveroThemeStyle.calming:
      return GoogleFonts.quicksand(fontSize: fontSize, fontWeight: fontWeight, color: color, height: height, letterSpacing: letterSpacing);
    case AveroThemeStyle.oled:
    case AveroThemeStyle.appleLike:
    case AveroThemeStyle.glassmorphic:
      return GoogleFonts.inter(fontSize: fontSize, fontWeight: fontWeight, color: color, height: height, letterSpacing: letterSpacing);
    case AveroThemeStyle.neumorphic:
      return GoogleFonts.nunito(fontSize: fontSize, fontWeight: fontWeight, color: color, height: height, letterSpacing: letterSpacing);
    case AveroThemeStyle.neoBrutalist:
    default:
      return GoogleFonts.spaceMono(fontSize: fontSize, fontWeight: fontWeight, color: color, height: height, letterSpacing: letterSpacing);
  }
}

class AppTheme {
  static ThemeData getThemeData(AveroThemeStyle style) {
    switch (style) {
      case AveroThemeStyle.calming:
        return ThemeData(
          brightness: Brightness.light,
          primaryColor: const Color(0xFF6DA28F),
          scaffoldBackgroundColor: const Color(0xFFF0F4F2),
          cardColor: Colors.white,
          textTheme: GoogleFonts.quicksandTextTheme(),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF6DA28F),
            secondary: Color(0xFFD4A373),
            surface: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFE8EFEA),
            foregroundColor: Color(0xFF4A6B5D),
            elevation: 0,
            centerTitle: true,
          ),
        );
      case AveroThemeStyle.oled:
        return ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.white,
          scaffoldBackgroundColor: Colors.black,
          cardColor: Colors.grey.shade900,
          textTheme: GoogleFonts.interTextTheme().apply(bodyColor: Colors.white, displayColor: Colors.white),
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            secondary: Colors.grey,
            surface: Colors.black,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
        );
      case AveroThemeStyle.glassmorphic:
        return ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.white,
          scaffoldBackgroundColor: const Color(0xFF1E1E2C), // Deep vibrant background base
          cardColor: Colors.white.withOpacity(0.1),
          textTheme: GoogleFonts.interTextTheme().apply(bodyColor: Colors.white, displayColor: Colors.white),
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            secondary: Color(0xFF8B5CF6),
            surface: Color(0xFF2D2D44),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
        );
      case AveroThemeStyle.neumorphic:
        return ThemeData(
          brightness: Brightness.light,
          primaryColor: const Color(0xFF5A6B8C),
          scaffoldBackgroundColor: const Color(0xFFE0E5EC),
          cardColor: const Color(0xFFE0E5EC),
          textTheme: GoogleFonts.nunitoTextTheme(),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF5A6B8C),
            secondary: Color(0xFF4A90E2),
            surface: Color(0xFFE0E5EC),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFE0E5EC),
            foregroundColor: Color(0xFF5A6B8C),
            elevation: 0,
            centerTitle: true,
          ),
        );
      case AveroThemeStyle.appleLike:
        return ThemeData(
          brightness: Brightness.light,
          primaryColor: const Color(0xFF007AFF),
          scaffoldBackgroundColor: const Color(0xFFF2F2F7),
          cardColor: Colors.white,
          textTheme: GoogleFonts.interTextTheme(),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF007AFF),
            secondary: Color(0xFF34C759),
            surface: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF2F2F7),
            foregroundColor: Colors.black,
            elevation: 0,
            centerTitle: true,
          ),
        );
      case AveroThemeStyle.neoBrutalist:
      default:
        return ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.black,
          scaffoldBackgroundColor: const Color(0xFFFACC15),
          cardColor: Colors.white,
          textTheme: GoogleFonts.spaceMonoTextTheme(),
          colorScheme: const ColorScheme.light(
            primary: Colors.black,
            secondary: Color(0xFFEF4444),
            surface: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
        );
    }
  }
}
