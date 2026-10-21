import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'apple_colors.dart';

class AppleTheme {
  static CupertinoThemeData cupertinoTheme(bool isDark) {
    return CupertinoThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: AppleColors.systemBlue,
      scaffoldBackgroundColor: AppleColors.bg(isDark),
      barBackgroundColor: isDark
          ? const Color(0xCC1C1C1E)
          : const Color(0xCCF2F2F7),
      textTheme: CupertinoTextThemeData(
        textStyle: GoogleFonts.inter(
          color: AppleColors.textPrimary(isDark),
          fontSize: 16,
        ),
        navTitleTextStyle: GoogleFonts.inter(
          color: AppleColors.textPrimary(isDark),
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        navLargeTitleTextStyle: GoogleFonts.inter(
          color: AppleColors.textPrimary(isDark),
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  static ThemeData materialTheme(bool isDark) {
    final interFont = GoogleFonts.inter().fontFamily;

    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      fontFamily: interFont,
      scaffoldBackgroundColor: AppleColors.bg(isDark),
      primaryColor: AppleColors.systemBlue,
      cardColor: AppleColors.card(isDark),
      dividerColor: AppleColors.separator(isDark),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppleColors.systemBlue,
        brightness: isDark ? Brightness.dark : Brightness.light,
        surface: AppleColors.card(isDark),
      ),
    );
  }
}
