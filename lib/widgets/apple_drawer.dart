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
    final activeJobs = state.activeInterviewsCount;
    final weeklyKm = state.weeklyKm;

    return Drawer(
      backgroundColor: AppleColors.card(isDark),
      elevation: 16,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Profile Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
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
                          'Personal Assistant  Life OS',
                          style: TextStyle(
                            fontSize: 12,
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
            const SizedBox(height: 8),

            // Navigation Section
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Text(
                      'FITUR UTAMA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppleColors.textSecondary(isDark),
                      ),
                    ),
                  ),

                  // 1. Beranda
                  _DrawerItem(
                    icon: Icons.home_rounded,
                    iconColor: AppleColors.systemBlue,
                    label: 'Beranda (Home)',
                    isSelected: currentFeature == AppFeature.home,
                    onTap: () {
                      state.setFeature(AppFeature.home);
                      Navigator.of(context).pop();
                    },
                    isDark: isDark,
                  ),

                  // 2. To-Do List
                  _DrawerItem(
                    icon: Icons.check_circle_rounded,
                    iconColor: AppleColors.systemIndigo,
                    label: 'To-Do List & Pengingat',
                    badgeText: pendingCount > 0 ? '$pendingCount' : null,
                    badgeColor: AppleColors.systemIndigo,
                    isSelected: currentFeature == AppFeature.todo,
                    onTap: () {
                      state.setFeature(AppFeature.todo);
                      Navigator.of(context).pop();
                    },
                    isDark: isDark,
                  ),

                  // 3. Job Hunt CRM
                  _DrawerItem(
                    icon: Icons.work_rounded,
                    iconColor: AppleColors.systemBlue,
                    label: 'Job Hunt CRM',
                    badgeText: activeJobs > 0 ? '$activeJobs Aktif' : null,
                    badgeColor: AppleColors.systemBlue,
                    isSelected: currentFeature == AppFeature.jobCrm,
                    onTap: () {
                      state.setFeature(AppFeature.jobCrm);
                      Navigator.of(context).pop();
                    },
                    isDark: isDark,
                  ),

                  // 4. Running & Shoes
                  _DrawerItem(
                    icon: Icons.directions_run_rounded,
                    iconColor: const Color(0xFFFF2D55),
                    label: 'Running & Sepatu',
                    badgeText: weeklyKm > 0 ? '${weeklyKm.toStringAsFixed(1)} KM' : null,
                    badgeColor: const Color(0xFFFF2D55),
                    isSelected: currentFeature == AppFeature.running,
                    onTap: () {
                      state.setFeature(AppFeature.running);
                      Navigator.of(context).pop();
                    },
                    isDark: isDark,
                  ),

                  // 5. Calories & Habits
                  _DrawerItem(
                    icon: Icons.restaurant_rounded,
                    iconColor: AppleColors.systemOrange,
                    label: 'Kalori & Kebiasaan',
                    badgeText: '${state.habitsCompletedTodayCount}/${state.habits.length}',
                    badgeColor: AppleColors.systemOrange,
                    isSelected: currentFeature == AppFeature.calories,
                    onTap: () {
                      state.setFeature(AppFeature.calories);
                      Navigator.of(context).pop();
                    },
                    isDark: isDark,
                  ),

                  // 6. Finance & Runway
                  _DrawerItem(
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: AppleColors.systemGreen,
                    label: 'Keuangan & Runway',
                    badgeText: '${state.estimatedRunwayMonths.toStringAsFixed(1)} Bln',
                    badgeColor: AppleColors.systemGreen,
                    isSelected: currentFeature == AppFeature.finance,
                    onTap: () {
                      state.setFeature(AppFeature.finance);
                      Navigator.of(context).pop();
                    },
                    isDark: isDark,
                  ),

                  // 7. Quick Links
                  _DrawerItem(
                    icon: Icons.explore_rounded,
                    iconColor: AppleColors.systemTeal,
                    label: 'Pintasan Safari',
                    isSelected: currentFeature == AppFeature.quickLinks,
                    onTap: () {
                      state.setFeature(AppFeature.quickLinks);
                      Navigator.of(context).pop();
                    },
                    isDark: isDark,
                  ),

                  // 8. Notes
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

                  const SizedBox(height: 8),
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: AppleColors.separator(isDark),
                  ),
                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Text(
                      'PENGATURAN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
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

                  // Dark Mode Switch
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                ],
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'iPhone 13 Edition • Apple HIG',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppleColors.textSecondary(isDark),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Personal Assistant Life OS v2.0',
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
  final Color? badgeColor;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _DrawerItem({
    this.icon,
    this.iconWidget,
    required this.iconColor,
    required this.label,
    this.badgeText,
    this.badgeColor,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? AppleColors.systemBlue.withOpacity(isDark ? 0.25 : 0.12)
                : CupertinoColors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: iconWidget ?? Icon(icon, size: 16, color: CupertinoColors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
                    color: (badgeColor ?? AppleColors.systemOrange).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: (badgeColor ?? AppleColors.systemOrange).withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    badgeText!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: badgeColor ?? AppleColors.systemOrange,
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
