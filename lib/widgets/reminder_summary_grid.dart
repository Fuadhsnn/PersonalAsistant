import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../state/dashboard_state.dart';
import '../theme/apple_colors.dart';

class ReminderSummaryGrid extends StatelessWidget {
  final int todayCount;
  final int scheduledCount;
  final int allCount;
  final int completedCount;
  final TaskFilter currentFilter;
  final Function(TaskFilter) onSelectFilter;
  final bool isDark;

  const ReminderSummaryGrid({
    super.key,
    required this.todayCount,
    required this.scheduledCount,
    required this.allCount,
    required this.completedCount,
    required this.currentFilter,
    required this.onSelectFilter,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Column (Hari Ini & Semua)
        Expanded(
          child: Column(
            children: [
              _RemindersCard(
                icon: Icons.today_rounded,
                iconColor: AppleColors.systemBlue,
                count: todayCount,
                label: 'Hari Ini',
                isSelected: currentFilter == TaskFilter.today,
                onTap: () => onSelectFilter(TaskFilter.today),
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _RemindersCard(
                icon: Icons.inbox_rounded,
                iconColor: AppleColors.systemIndigo,
                count: allCount,
                label: 'Semua',
                isSelected: currentFilter == TaskFilter.all,
                onTap: () => onSelectFilter(TaskFilter.all),
                isDark: isDark,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Right Column (Terjadwal & Selesai)
        Expanded(
          child: Column(
            children: [
              _RemindersCard(
                icon: Icons.schedule_rounded,
                iconColor: AppleColors.systemOrange,
                count: scheduledCount,
                label: 'Terjadwal',
                isSelected: currentFilter == TaskFilter.scheduled,
                onTap: () => onSelectFilter(TaskFilter.scheduled),
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _RemindersCard(
                icon: Icons.check_circle_rounded,
                iconColor: AppleColors.systemGreen,
                count: completedCount,
                label: 'Selesai',
                isSelected: currentFilter == TaskFilter.completed,
                onTap: () => onSelectFilter(TaskFilter.completed),
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RemindersCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final int count;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _RemindersCard({
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppleColors.darkCardSecondary : const Color(0xFFEBF3FF))
              : AppleColors.card(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppleColors.systemBlue
                : (isDark ? const Color(0x22FFFFFF) : const Color(0x0A000000)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? const Color(0x22000000) : const Color(0x08000000),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon circle
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: iconColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: CupertinoColors.white,
                  ),
                ),
                // Count
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: AppleColors.textPrimary(isDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppleColors.systemBlue
                    : AppleColors.textSecondary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
