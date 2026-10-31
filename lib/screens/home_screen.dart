import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/task_item.dart';
import '../models/shortcut_item.dart';
import '../state/dashboard_state.dart';
import '../theme/apple_colors.dart';
import '../widgets/activity_rings_card.dart';
import '../widgets/apple_burger_icon.dart';
import '../widgets/apple_note_icon.dart';

class HomeScreen extends StatelessWidget {
  final DashboardState state;
  final VoidCallback onOpenDrawer;
  final VoidCallback onOpenSettings;
  final Function(TaskItem?) onOpenAddTask;

  const HomeScreen({
    super.key,
    required this.state,
    required this.onOpenDrawer,
    required this.onOpenSettings,
    required this.onOpenAddTask,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) {
      return 'Selamat Pagi';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat Siang';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = state.isDarkMode;
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now).toUpperCase();
    final topTasks = state.tasks.where((t) => !t.isCompleted).take(3).toList();
    final topShortcuts = state.shortcuts.take(6).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    onPressed: onOpenDrawer,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppleColors.card(isDark),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? const Color(0x22000000) : const Color(0x0A000000),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AppleBurgerIcon(
                          color: AppleColors.textPrimary(isDark),
                          size: 18,
                        ),
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      Icon(
                        Icons.apple,
                        size: 18,
                        color: AppleColors.textPrimary(isDark),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'ARIES • LIFE OS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: AppleColors.textSecondary(isDark),
                        ),
                      ),
                    ],
                  ),

                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    onPressed: onOpenSettings,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppleColors.card(isDark),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? const Color(0x22000000) : const Color(0x0A000000),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        CupertinoIcons.gear_alt_fill,
                        size: 19,
                        color: AppleColors.textPrimary(isDark),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Greeting & Date
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppleColors.textSecondary(isDark),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_getGreeting()}, ${state.userName}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: AppleColors.textPrimary(isDark),
                ),
              ),
              const SizedBox(height: 16),

              // Apple Activity Rings Widget (To-Do, Habit, Calorie/Run)
              ActivityRingsCard(
                todayProgress: state.todayProgress,
                highPriorityProgress: state.habitProgressToday,
                overallProgress: state.calorieProgress,
                todayCount: state.todayCount,
                completedToday: state.completedCount,
                isDark: isDark,
              ),
              const SizedBox(height: 20),

              // Quick KPI Glance Grid (2x2)
              Row(
                children: [
                  Expanded(
                    child: _KpiGlanceCard(
                      title: 'JOB HUNT CRM',
                      mainVal: '${state.activeInterviewsCount}',
                      unit: 'Proses Aktif',
                      desc: state.offeringCount > 0 ? '${state.offeringCount} Offering 🏆' : '${state.totalJobsCount} Terkirim',
                      icon: Icons.work_rounded,
                      accentColor: AppleColors.systemBlue,
                      isDark: isDark,
                      onTap: () => state.setFeature(AppFeature.jobCrm),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _KpiGlanceCard(
                      title: 'RUNNING (7 HARI)',
                      mainVal: state.weeklyKm.toStringAsFixed(1),
                      unit: 'KM',
                      desc: '${state.activeShoes.length} Sepatu Rotasi',
                      icon: Icons.directions_run_rounded,
                      accentColor: const Color(0xFFFF2D55),
                      isDark: isDark,
                      onTap: () => state.setFeature(AppFeature.running),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _KpiGlanceCard(
                      title: 'KEUANGAN & RUNWAY',
                      mainVal: state.estimatedRunwayMonths.toStringAsFixed(1),
                      unit: 'Bulan Aman',
                      desc: 'Kas cadangan stabil',
                      icon: Icons.account_balance_wallet_rounded,
                      accentColor: AppleColors.systemGreen,
                      isDark: isDark,
                      onTap: () => state.setFeature(AppFeature.finance),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _KpiGlanceCard(
                      title: 'ASUPAN KALORI',
                      mainVal: '${state.todayCalorieTotal}',
                      unit: 'kcal',
                      desc: '${state.remainingCalories} kcal sisa target',
                      icon: Icons.restaurant_rounded,
                      accentColor: AppleColors.systemOrange,
                      isDark: isDark,
                      onTap: () => state.setFeature(AppFeature.calories),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Google Calendar Agenda Widget (Hari H & H-1)
              _buildCalendarAgendaWidget(context, isDark),
              const SizedBox(height: 12),

              // Milestone H-7 Countdown Card
              if (state.upcomingMilestones.isNotEmpty) ...[
                _buildMilestoneBanner(context, state.upcomingMilestones.first, isDark),
                const SizedBox(height: 20),
              ] else
                const SizedBox(height: 12),

              // Safari Favorites Horizontal Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pintasan Safari',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: AppleColors.textPrimary(isDark),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => state.setFeature(AppFeature.quickLinks),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Semua Pintasan',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppleColors.systemBlue),
                        ),
                        SizedBox(width: 2),
                        Icon(CupertinoIcons.chevron_forward, size: 14, color: AppleColors.systemBlue),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Horizontal Shortcuts
              SizedBox(
                height: 84,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: topShortcuts.length,
                  itemBuilder: (context, index) {
                    final item = topShortcuts[index];
                    return _buildHomeShortcutPill(item, isDark);
                  },
                ),
              ),
              const SizedBox(height: 20),

              // All Features Navigation Launchpad
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Modul Kehidupan (Life OS)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: AppleColors.textPrimary(isDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _LaunchpadTile(
                      title: 'Job Hunt CRM',
                      subtitle: '${state.activeInterviewsCount} interview aktif',
                      icon: Icons.work_rounded,
                      iconBg: AppleColors.systemBlue,
                      isDark: isDark,
                      onTap: () => state.setFeature(AppFeature.jobCrm),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _LaunchpadTile(
                      title: 'Running & Sepatu',
                      subtitle: 'Odometer & rekor PB',
                      icon: Icons.directions_run_rounded,
                      iconBg: const Color(0xFFFF2D55),
                      isDark: isDark,
                      onTap: () => state.setFeature(AppFeature.running),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _LaunchpadTile(
                      title: 'Kalori & Habit',
                      subtitle: 'Preset makanan nusantara',
                      icon: Icons.restaurant_rounded,
                      iconBg: AppleColors.systemOrange,
                      isDark: isDark,
                      onTap: () => state.setFeature(AppFeature.calories),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _LaunchpadTile(
                      title: 'Keuangan & Runway',
                      subtitle: 'Apple card & wishlist',
                      icon: Icons.account_balance_wallet_rounded,
                      iconBg: AppleColors.systemGreen,
                      isDark: isDark,
                      onTap: () => state.setFeature(AppFeature.finance),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _LaunchpadTile(
                      title: 'To-Do List',
                      subtitle: '${state.allCount} tugas pending',
                      icon: Icons.check_circle_rounded,
                      iconBg: AppleColors.systemIndigo,
                      isDark: isDark,
                      onTap: () => state.setFeature(AppFeature.todo),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _LaunchpadTile(
                      title: 'Catatan Cepat',
                      subtitle: 'Scratchpad ide & riset',
                      iconWidget: const AppleNoteIcon(color: CupertinoColors.white, size: 16),
                      iconBg: AppleColors.systemYellow,
                      isDark: isDark,
                      onTap: () => state.setFeature(AppFeature.notes),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _LaunchpadTile(
                      title: 'Kalender & Jadwal',
                      subtitle: 'Two-way sync & Meet',
                      icon: Icons.calendar_month_rounded,
                      iconBg: AppleColors.systemRed,
                      isDark: isDark,
                      onTap: () => state.setFeature(AppFeature.calendar),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _LaunchpadTile(
                      title: 'Split Bill AI',
                      subtitle: 'OCR struk Gemini AI',
                      icon: Icons.receipt_long_rounded,
                      iconBg: AppleColors.electricBlue,
                      isDark: isDark,
                      onTap: () => state.setFeature(AppFeature.splitBill),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Priority Tasks Glance Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Prioritas Segera',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: AppleColors.textPrimary(isDark),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => state.setFeature(AppFeature.todo),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lihat Semua',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppleColors.systemBlue,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(CupertinoIcons.chevron_forward, size: 14, color: AppleColors.systemBlue),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (topTasks.isEmpty)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppleColors.card(isDark),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppleColors.separator(isDark)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0x2034C759),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(CupertinoIcons.checkmark_shield_fill, color: AppleColors.systemGreen, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Semua tugas telah tuntas! 🎉',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppleColors.textPrimary(isDark),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Buka to-do list untuk merencanakan hal baru.',
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
                )
              else
                Column(
                  children: topTasks.map((task) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppleColors.card(isDark),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppleColors.separator(isDark)),
                      ),
                      child: Row(
                        children: [
                          CupertinoButton(
                            padding: const EdgeInsets.only(right: 12),
                            minimumSize: Size.zero,
                            onPressed: () => state.toggleTask(task.id),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? AppleColors.darkTextTertiary : const Color(0xFFC7C7CC),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppleColors.textPrimary(isDark),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppleColors.cardSecondary(isDark),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              task.category,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppleColors.textSecondary(isDark),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 20),

              // Inline Quick Scratchpad Card
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Catatan Cepat (Scratchpad)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: AppleColors.textPrimary(isDark),
                    ),
                  ),
                  Text(
                    'Auto-Save',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppleColors.textSecondary(isDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              _QuickScratchpadWidget(
                note: state.quickNote,
                isDark: isDark,
                onChanged: state.setQuickNote,
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHomeShortcutPill(ShortcutItem item, bool isDark) {
    IconData iconData = Icons.language_rounded;
    switch (item.iconCode) {
      case 'briefcase':
        iconData = Icons.work_rounded;
        break;
      case 'code':
        iconData = Icons.code_rounded;
        break;
      case 'run':
        iconData = Icons.directions_run_rounded;
        break;
      case 'ai':
        iconData = Icons.auto_awesome_rounded;
        break;
      case 'video':
        iconData = Icons.play_arrow_rounded;
        break;
      default:
        iconData = Icons.language_rounded;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _launchUrl(item.url),
      child: Container(
        width: 68,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Color(item.colorValue),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Color(item.colorValue).withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(iconData, color: CupertinoColors.white, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppleColors.label(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarAgendaWidget(BuildContext context, bool isDark) {
    final todayEvents = state.todayEvents;
    final now = DateTime.now();
    final monthStr = DateFormat('MMM', 'id_ID').format(now).toUpperCase();
    final dayStr = '${now.day}';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => state.setFeature(AppFeature.calendar),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppleColors.card(isDark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppleColors.cardBorder(isDark), width: 1),
          boxShadow: [
            BoxShadow(
              color: isDark ? const Color(0x22000000) : const Color(0x06000000),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Date Badge Block
            Container(
              width: 48,
              height: 50,
              decoration: BoxDecoration(
                color: AppleColors.cardInset(isDark),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    monthStr,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppleColors.systemRed,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  Text(
                    dayStr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppleColors.textPrimary(isDark),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Agenda Details
            Expanded(
              child: todayEvents.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todayEvents.first.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppleColors.textPrimary(isDark),
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              todayEvents.first.formattedTimeRange,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppleColors.textSecondary(isDark),
                                decoration: TextDecoration.none,
                              ),
                            ),
                            if (todayEvents.first.meetLink != null &&
                                todayEvents.first.meetLink!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              const Text(
                                '• Google Meet',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppleColors.electricBlue,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Belum ada jadwal hari ini',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppleColors.textPrimary(isDark),
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Buka Kalender untuk menambah acara baru.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppleColors.textSecondary(isDark),
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
            ),

            Icon(
              CupertinoIcons.chevron_forward,
              size: 14,
              color: AppleColors.textSecondary(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneBanner(BuildContext context, dynamic milestone, bool isDark) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => state.setFeature(AppFeature.calendar),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppleColors.card(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppleColors.systemRed.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${milestone.title} • ${milestone.daysUntil} Hari Lagi',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppleColors.textPrimary(isDark),
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${DateFormat('d MMM yyyy • HH:mm', 'id_ID').format(milestone.startTime)} WIB',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppleColors.textSecondary(isDark),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppleColors.systemRed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                milestone.milestoneBadge,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: CupertinoColors.white,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiGlanceCard extends StatelessWidget {
  final String title;
  final String mainVal;
  final String unit;
  final String desc;
  final IconData icon;
  final Color accentColor;
  final bool isDark;
  final VoidCallback onTap;

  const _KpiGlanceCard({
    required this.title,
    required this.mainVal,
    required this.unit,
    required this.desc,
    required this.icon,
    required this.accentColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppleColors.cardBg(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppleColors.separator(isDark)),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(isDark ? 0.3 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: accentColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: AppleColors.secondaryLabel(isDark),
                    ),
                  ),
                ),
                Icon(CupertinoIcons.chevron_forward, size: 12, color: AppleColors.tertiaryLabel(isDark)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  mainVal,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: AppleColors.label(isDark),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    unit,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              desc,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: AppleColors.secondaryLabel(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LaunchpadTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final Widget? iconWidget;
  final Color iconBg;
  final bool isDark;
  final VoidCallback onTap;

  const _LaunchpadTile({
    required this.title,
    required this.subtitle,
    this.icon,
    this.iconWidget,
    required this.iconBg,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppleColors.cardBg(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppleColors.separator(isDark)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: iconWidget ?? Icon(icon, color: CupertinoColors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppleColors.label(isDark),
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppleColors.secondaryLabel(isDark),
                    ),
                  ),
                ],
              ),
            ),
            Icon(CupertinoIcons.chevron_forward, size: 12, color: AppleColors.tertiaryLabel(isDark)),
          ],
        ),
      ),
    );
  }
}

class _QuickScratchpadWidget extends StatefulWidget {
  final String note;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const _QuickScratchpadWidget({
    required this.note,
    required this.isDark,
    required this.onChanged,
  });

  @override
  State<_QuickScratchpadWidget> createState() => _QuickScratchpadWidgetState();
}

class _QuickScratchpadWidgetState extends State<_QuickScratchpadWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.note);
  }

  @override
  void didUpdateWidget(covariant _QuickScratchpadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.note != oldWidget.note && _controller.text != widget.note) {
      _controller.text = widget.note;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppleColors.card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppleColors.separator(isDark)),
      ),
      child: Column(
        children: [
          CupertinoTextField(
            controller: _controller,
            placeholder: 'Tulis catatan cepat, ide kuliah, atau tautan penting di sini...',
            placeholderStyle: TextStyle(
              fontSize: 14,
              color: AppleColors.textTertiary(isDark),
            ),
            style: TextStyle(
              fontSize: 14,
              color: AppleColors.textPrimary(isDark),
              height: 1.4,
            ),
            maxLines: 3,
            padding: EdgeInsets.zero,
            decoration: null,
            onChanged: widget.onChanged,
          ),
        ],
      ),
    );
  }
}
