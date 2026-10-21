import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../models/task_item.dart';
import '../state/dashboard_state.dart';
import '../theme/apple_colors.dart';
import '../widgets/activity_rings_card.dart';
import '../widgets/apple_burger_icon.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDark = state.isDarkMode;
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM', 'id_ID').format(now).toUpperCase();

    // Priority tasks for today preview
    final topTasks = state.tasks.where((t) => !t.isCompleted).take(3).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Top Bar with Burger Menu & Settings
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

                  Text(
                    'PERSONAL DASHBOARD',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: AppleColors.textSecondary(isDark),
                    ),
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
              const SizedBox(height: 18),

              // Greeting & Date
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
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
              const SizedBox(height: 20),

              // Apple Activity Rings Widget
              ActivityRingsCard(
                todayProgress: state.todayProgress,
                highPriorityProgress: state.highPriorityProgress,
                overallProgress: state.overallProgress,
                todayCount: state.todayCount,
                completedToday: state.completedCount,
                isDark: isDark,
              ),
              const SizedBox(height: 24),

              // Features Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fitur Personal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: AppleColors.textPrimary(isDark),
                    ),
                  ),
                  Text(
                    'Pilih Fitur',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppleColors.textSecondary(isDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Feature Cards Hub
              Row(
                children: [
                  // Feature 1: To-Do List
                  Expanded(
                    child: _FeatureCard(
                      icon: CupertinoIcons.check_mark_circled_solid,
                      iconColor: AppleColors.systemOrange,
                      title: 'To-Do List',
                      subtitle: '${state.allCount} tugas aktif',
                      badgeText: state.todayCount > 0 ? '${state.todayCount} Hari Ini' : null,
                      isDark: isDark,
                      onTap: () => state.setFeature(AppFeature.todo),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Feature 2: Catatan Cepat
                  Expanded(
                    child: _FeatureCard(
                      icon: CupertinoIcons.doc_text_fill,
                      iconColor: AppleColors.systemYellow,
                      title: 'Catatan Cepat',
                      subtitle: 'Memo instan',
                      badgeText: 'Scratchpad',
                      isDark: isDark,
                      onTap: () => state.setFeature(AppFeature.notes),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Tasks Glance Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Prioritas Segera',
                    style: TextStyle(
                      fontSize: 20,
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
                            fontSize: 14,
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

              // Top 3 tasks preview or empty card
              if (topTasks.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppleColors.card(isDark),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0x2034C759),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(CupertinoIcons.checkmark_shield_fill, color: AppleColors.systemGreen, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Semua tugas telah tuntas! 🎉',
                              style: TextStyle(
                                fontSize: 15,
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
                        border: Border.all(
                          color: isDark ? const Color(0x1AFFFFFF) : const Color(0x0A000000),
                        ),
                      ),
                      child: Row(
                        children: [
                          CupertinoButton(
                            padding: const EdgeInsets.only(right: 12),
                            minimumSize: Size.zero,
                            onPressed: () => state.toggleTask(task.id),
                            child: Container(
                              width: 24,
                              height: 24,
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
                                fontSize: 15,
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
                                fontSize: 11,
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
              const SizedBox(height: 24),

              // Inline Quick Scratchpad Card
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Scratchpad Harian',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: AppleColors.textPrimary(isDark),
                    ),
                  ),
                  Text(
                    'Tersimpan Otomatis',
                    style: TextStyle(
                      fontSize: 12,
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
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badgeText;
  final bool isDark;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.badgeText,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppleColors.card(isDark),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark ? const Color(0x22000000) : const Color(0x08000000),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: isDark ? const Color(0x1AFFFFFF) : const Color(0x0A000000),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: CupertinoColors.white, size: 20),
                ),
                const Icon(CupertinoIcons.chevron_forward, size: 16, color: Color(0xFFC7C7CC)),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: AppleColors.textPrimary(isDark),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: AppleColors.textSecondary(isDark),
              ),
            ),
            if (badgeText != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: isDark ? 0.25 : 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
              ),
            ],
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
        border: Border.all(
          color: isDark ? const Color(0x1AFFFFFF) : const Color(0x0A000000),
        ),
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
            maxLines: 4,
            padding: EdgeInsets.zero,
            decoration: null,
            onChanged: widget.onChanged,
          ),
        ],
      ),
    );
  }
}
