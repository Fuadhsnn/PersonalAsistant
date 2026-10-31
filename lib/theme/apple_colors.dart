import 'package:flutter/cupertino.dart';

class AppleColors {
  // Brand / Accents
  static const Color systemBlue = Color(0xFF007AFF);
  static const Color electricBlue = Color(0xFF00A3FF);
  static const Color systemOrange = Color(0xFFFF9500);
  static const Color stravaOrange = Color(0xFFFC4C02);
  static const Color systemGreen = Color(0xFF34C759);
  static const Color systemRed = Color(0xFFFF3B30);
  static const Color systemPurple = Color(0xFFAF52DE);
  static const Color systemIndigo = Color(0xFF5856D6);
  static const Color systemPink = Color(0xFFFF2D55);
  static const Color systemTeal = Color(0xFF30B0C7);
  static const Color systemYellow = Color(0xFFFFCC00);

  // Backgrounds - Light (Modern Tactile)
  static const Color lightBg = Color(0xFFF4F5F8);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardSecondary = Color(0xFFF7F7F9);
  static const Color lightCardInset = Color(0xFFEBF0F5);
  static const Color lightCardBorder = Color(0xFFE2E5EB);
  static const Color lightSeparator = Color(0x1F000000);
  static const Color lightTextPrimary = Color(0xFF121316);
  static const Color lightTextSecondary = Color(0xFF8E929B);
  static const Color lightTextTertiary = Color(0xFFC7C7CC);

  // Backgrounds - Dark (Pure OLED Black & Modern Tactile OLED for iPhone 13)
  static const Color darkBg = Color(0xFF0B0C0E);
  static const Color darkCard = Color(0xFF16181E);
  static const Color darkCardSecondary = Color(0xFF1F2128);
  static const Color darkCardInset = Color(0xFF0E0F13);
  static const Color darkCardBorder = Color(0xFF2A2D37);
  static const Color darkSeparator = Color(0x38545458);
  static const Color darkTextPrimary = Color(0xFFF5F6F8);
  static const Color darkTextSecondary = Color(0xFF8E929B);
  static const Color darkTextTertiary = Color(0xFF5A5E6B);

  // Floating Island Tab Bar Colors
  static const Color lightFloatingBar = Color(0xFF15161A);
  static const Color darkFloatingBar = Color(0xFF1A1C22);
  static const Color lightFloatingActive = Color(0xFF2C2E35);
  static const Color darkFloatingActive = Color(0xFF2C2F3A);

  // Dynamic getters based on brightness
  static Color bg(bool isDark) => isDark ? darkBg : lightBg;
  static Color card(bool isDark) => isDark ? darkCard : lightCard;
  static Color cardSecondary(bool isDark) => isDark ? darkCardSecondary : lightCardSecondary;
  static Color cardInset(bool isDark) => isDark ? darkCardInset : lightCardInset;
  static Color cardBorder(bool isDark) => isDark ? darkCardBorder : lightCardBorder;
  static Color separator(bool isDark) => isDark ? darkSeparator : lightSeparator;
  static Color textPrimary(bool isDark) => isDark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondary(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;
  static Color textTertiary(bool isDark) => isDark ? darkTextTertiary : lightTextTertiary;

  // Floating Island Getters
  static Color floatingBarBg(bool isDark) => isDark ? darkFloatingBar : lightFloatingBar;
  static Color floatingBarActive(bool isDark) => isDark ? darkFloatingActive : lightFloatingActive;
  static Color floatingBarBorder(bool isDark) => isDark ? const Color(0xFF2E313C) : const Color(0xFF2E3038);

  // Convenient HIG aliases
  static Color cardBg(bool isDark) => card(isDark);
  static Color label(bool isDark) => textPrimary(isDark);
  static Color secondaryLabel(bool isDark) => textSecondary(isDark);
  static Color tertiaryLabel(bool isDark) => textTertiary(isDark);
}
