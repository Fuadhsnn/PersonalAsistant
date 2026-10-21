import 'package:flutter/cupertino.dart';

class AppleColors {
  // Brand / Accents
  static const Color systemBlue = Color(0xFF007AFF);
  static const Color systemOrange = Color(0xFFFF9500);
  static const Color systemGreen = Color(0xFF34C759);
  static const Color systemRed = Color(0xFFFF3B30);
  static const Color systemPurple = Color(0xFFAF52DE);
  static const Color systemIndigo = Color(0xFF5856D6);
  static const Color systemPink = Color(0xFFFF2D55);
  static const Color systemTeal = Color(0xFF30B0C7);
  static const Color systemYellow = Color(0xFFFFCC00);

  // Backgrounds - Light
  static const Color lightBg = Color(0xFFF2F2F7);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardSecondary = Color(0xFFF7F7F9);
  static const Color lightSeparator = Color(0x1F000000);
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xFF8E8E93);
  static const Color lightTextTertiary = Color(0xFFC7C7CC);

  // Backgrounds - Dark (Pure OLED Black & Rich Space Gray for iPhone 13)
  static const Color darkBg = Color(0xFF000000);
  static const Color darkCard = Color(0xFF1C1C1E);
  static const Color darkCardSecondary = Color(0xFF2C2C2E);
  static const Color darkSeparator = Color(0x38545458);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF8E8E93);
  static const Color darkTextTertiary = Color(0xFF48484A);

  // Dynamic getters based on brightness
  static Color bg(bool isDark) => isDark ? darkBg : lightBg;
  static Color card(bool isDark) => isDark ? darkCard : lightCard;
  static Color cardSecondary(bool isDark) => isDark ? darkCardSecondary : lightCardSecondary;
  static Color separator(bool isDark) => isDark ? darkSeparator : lightSeparator;
  static Color textPrimary(bool isDark) => isDark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondary(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;
  static Color textTertiary(bool isDark) => isDark ? darkTextTertiary : lightTextTertiary;

  // Convenient HIG aliases
  static Color cardBg(bool isDark) => card(isDark);
  static Color label(bool isDark) => textPrimary(isDark);
  static Color secondaryLabel(bool isDark) => textSecondary(isDark);
  static Color tertiaryLabel(bool isDark) => textTertiary(isDark);
}
