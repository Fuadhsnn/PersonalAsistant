import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../state/dashboard_state.dart';
import '../theme/apple_colors.dart';

class FloatingIslandTabBar extends StatelessWidget {
  final DashboardState state;
  final Function(AppFeature) onTabSelected;

  const FloatingIslandTabBar({
    super.key,
    required this.state,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = state.isDarkMode;
    final current = state.currentFeature;

    final tabs = [
      (
        feature: AppFeature.home,
        label: 'Home',
        icon: Icons.home_rounded,
        inactiveIcon: Icons.home_outlined,
      ),
      (
        feature: AppFeature.todo,
        label: 'Tugas',
        icon: Icons.check_circle_rounded,
        inactiveIcon: Icons.check_circle_outline_rounded,
      ),
      (
        feature: AppFeature.finance,
        label: 'Dompet',
        icon: Icons.account_balance_wallet_rounded,
        inactiveIcon: Icons.account_balance_wallet_outlined,
      ),
      (
        feature: AppFeature.calendar,
        label: 'Jadwal',
        icon: Icons.calendar_month_rounded,
        inactiveIcon: Icons.calendar_month_outlined,
      ),
      (
        feature: AppFeature.running,
        label: 'Lari',
        icon: Icons.directions_run_rounded,
        inactiveIcon: Icons.directions_run_outlined,
      ),
    ];

    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppleColors.floatingBarBg(isDark),
        borderRadius: BorderRadius.circular(27),
        border: Border.all(
          color: AppleColors.floatingBarBorder(isDark),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x38000000),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: tabs.map((tab) {
          final isActive = current == tab.feature;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              onPressed: () => onTabSelected(tab.feature),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: isActive ? 12 : 8,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppleColors.floatingBarActive(isDark)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive ? tab.icon : tab.inactiveIcon,
                      size: 18,
                      color: isActive
                          ? CupertinoColors.white
                          : const Color(0xFF8E929B),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 5),
                      Text(
                        tab.label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

