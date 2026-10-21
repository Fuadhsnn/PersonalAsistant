import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../state/dashboard_state.dart';
import '../theme/apple_colors.dart';
import 'apple_note_icon.dart';

class AppleDrawer extends StatelessWidget {
  final DashboardState state;
  final VoidCallback onOpenSettings;

  const AppleDrawer({
    super.key,
    required this.state,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = state.isDarkMode;
    final currentFeature = state.currentFeature;
    final pendingCount = state.allCount;

    return Drawer(
      backgroundColor: AppleColors.card(isDark),
      elevation: 16,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Profile Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      state.userName.isNotEmpty ? state.userName[0].toUpperCase() : 'H',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.userName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                            color: AppleColors.textPrimary(isDark),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Personal Assistant ',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppleColors.textSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: AppleColors.separator(isDark),
            ),
            const SizedBox(height: 12),

            // Navigation Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'FITUR APLIKASI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: AppleColors.textSecondary(isDark),
                ),
              ),
            ),

            // Item 1: Beranda (Home)
            _DrawerItem(
              icon: CupertinoIcons.home,
              iconColor: AppleColors.systemBlue,
              label: 'Beranda (Home)',
              isSelected: currentFeature == AppFeature.home,
              onTap: () {
                state.setFeature(AppFeature.home);
                Navigator.of(context).pop();
              },
              isDark: isDark,
            ),

            // Item 2: To-Do List
            _DrawerItem(
              icon: CupertinoIcons.check_mark_circled_solid,
              iconColor: AppleColors.systemOrange,
              label: 'To-Do List & Pengingat',
              badgeText: pendingCount > 0 ? '$pendingCount' : null,
              isSelected: currentFeature == AppFeature.todo,
              onTap: () {
                state.setFeature(AppFeature.todo);
                Navigator.of(context).pop();
              },
              isDark: isDark,
            ),

            // Item 3: Catatan Cepat (Notes)
            _DrawerItem(
              iconWidget: const AppleNoteIcon(color: CupertinoColors.white, size: 18),
              iconColor: AppleColors.systemYellow,
              label: 'Catatan Cepat',
              isSelected: currentFeature == AppFeature.notes,
              onTap: () {
                state.setFeature(AppFeature.notes);
                Navigator.of(context).pop();
              },
              isDark: isDark,
            ),

            const SizedBox(height: 12),
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: AppleColors.separator(isDark),
            ),
            const SizedBox(height: 12),

            // Section: Pengaturan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'PENGATURAN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: AppleColors.textSecondary(isDark),
                ),
              ),
            ),

            _DrawerItem(
              icon: CupertinoIcons.gear_alt_fill,
              iconColor: const Color(0xFF8E8E93),
              label: 'Pengaturan & Cadangan',
              isSelected: false,
              onTap: () {
                Navigator.of(context).pop();
                onOpenSettings();
              },
              isDark: isDark,
            ),

            // Dark Mode Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppleColors.cardSecondary(isDark),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: AppleColors.systemIndigo,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(CupertinoIcons.moon_fill, size: 16, color: CupertinoColors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Mode Gelap (OLED)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppleColors.textPrimary(isDark),
                        ),
                      ),
                    ),
                    CupertinoSwitch(
                      value: isDark,
                      activeTrackColor: AppleColors.systemBlue,
                      onChanged: (_) => state.toggleDarkMode(),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Footer
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'iPhone 13 Edition • Apple HIG',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppleColors.textSecondary(isDark),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Personal Assistant v1.1',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppleColors.textTertiary(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final Color iconColor;
  final String label;
  final String? badgeText;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _DrawerItem({
    this.icon,
    this.iconWidget,
    required this.iconColor,
    required this.label,
    this.badgeText,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isSelected
                ? AppleColors.systemBlue.withValues(alpha: isDark ? 0.25 : 0.12)
                : CupertinoColors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: iconWidget ?? Icon(icon, size: 18, color: CupertinoColors.white),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppleColors.systemBlue
                        : AppleColors.textPrimary(isDark),
                  ),
                ),
              ),
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppleColors.systemOrange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badgeText!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
