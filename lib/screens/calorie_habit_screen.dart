import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/calorie_habit_item.dart';
import '../state/dashboard_state.dart';
import '../theme/apple_colors.dart';
import '../widgets/apple_burger_icon.dart';

class CalorieHabitScreen extends StatefulWidget {
  final DashboardState state;
  final VoidCallback onOpenDrawer;
  final VoidCallback onBackToHome;

  const CalorieHabitScreen({
    super.key,
    required this.state,
    required this.onOpenDrawer,
    required this.onBackToHome,
  });

  @override
  State<CalorieHabitScreen> createState() => _CalorieHabitScreenState();
}

class _CalorieHabitScreenState extends State<CalorieHabitScreen> {
  String _presetCategory = 'Kopi & Minuman';
  String? _feedbackMessage;

  void _showFeedback(String message) {
    setState(() => _feedbackMessage = message);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _feedbackMessage = null);
    });
  }

  void _quickAddPreset(FoodPreset preset) {
    final log = CalorieLog(
      id: 'cal_${DateTime.now().millisecondsSinceEpoch}',
      foodName: preset.name,
      calories: preset.calories,
      mealType: preset.category == 'Kopi & Minuman' ? 'Camilan/Kopi' : 'Makan Siang',
      dateTime: DateTime.now(),
    );
    widget.state.addCalorieLog(log);
    _showFeedback('+ ${preset.calories} kcal dicatat: ${preset.name}');
  }

  void _openManualCalorieSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _AddCalorieModalSheet(state: widget.state),
    );
  }

  void _openAddHabitSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _AddHabitModalSheet(state: widget.state),
    );
  }

  void _editCalorieGoal(BuildContext context) {
    final controller = TextEditingController(text: '${widget.state.calorieGoal}');
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Target Kalori Harian'),
        content: Column(
          children: [
            const SizedBox(height: 10),
            const Text('Atur target kalori (kcal) harian sesuai kebutuhan diet/energi Anda:'),
            const SizedBox(height: 12),
            CupertinoTextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 500) {
                widget.state.setCalorieGoal(val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;
    final totalCalories = widget.state.todayCalorieTotal;
    final calorieGoal = widget.state.calorieGoal;
    final progress = widget.state.calorieProgress;
    final remaining = widget.state.remainingCalories;
    final todayLogs = widget.state.todayCalorieLogs;
    final habits = widget.state.habits;

    final presets = FoodPreset.indonesianPresets
        .where((p) => p.category == _presetCategory)
        .toList();

    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            // Navigation Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 36,
                      onPressed: widget.onBackToHome,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.chevron_back,
                            size: 22,
                            color: AppleColors.systemBlue,
                          ),
                          Text(
                            'Beranda',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppleColors.systemBlue,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 36,
                      onPressed: widget.onOpenDrawer,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppleColors.cardBg(isDark),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppleColors.separator(isDark)),
                        ),
                        alignment: Alignment.center,
                        child: AppleBurgerIcon(
                          size: 18,
                          color: isDark ? CupertinoColors.white : CupertinoColors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 36,
                      onPressed: () => _openManualCalorieSheet(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: AppleColors.systemOrange,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          CupertinoIcons.plus,
                          size: 20,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Header Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kalori & Kebiasaan',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppleColors.label(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Target asupan harian, preset makanan nusantara, & rutinitas harian',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppleColors.secondaryLabel(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Calorie Target Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF2A1C08), const Color(0xFF161618)]
                          : [const Color(0xFFFFF7ED), const Color(0xFFFFFFFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppleColors.systemOrange.withOpacity(0.35)),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.black.withOpacity(isDark ? 0.35 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppleColors.systemOrange.withOpacity(0.18),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  CupertinoIcons.flame_fill,
                                  color: AppleColors.systemOrange,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ASUPAN KALORI HARI INI',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                      color: AppleColors.systemOrange,
                                    ),
                                  ),
                                  Text(
                                    '$totalCalories / $calorieGoal kcal',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppleColors.label(isDark),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            minSize: 28,
                            onPressed: () => _editCalorieGoal(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppleColors.cardBg(isDark),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppleColors.separator(isDark)),
                              ),
                              child: Text(
                                'Target: $calorieGoal',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppleColors.label(isDark),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppleColors.systemOrange),
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}% dari target',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppleColors.secondaryLabel(isDark),
                            ),
                          ),
                          Text(
                            remaining > 0 ? 'Sisa $remaining kcal' : 'Target tercapai! 🎯',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: remaining > 0 ? AppleColors.systemOrange : AppleColors.systemGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Section: 1-Tap Indonesian Presets
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Text(
                      'PRESET 1-TAP MAKANAN & KOPI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppleColors.secondaryLabel(isDark),
                      ),
                    ),
                    const Spacer(),
                    const Text('⚡ Instan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppleColors.systemBlue)),
                  ],
                ),
              ),
            ),

            // Preset Category Switcher
            SliverToBoxAdapter(
              child: Container(
                height: 34,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildPresetPill('Kopi & Minuman', isDark),
                    _buildPresetPill('Makanan Harian', isDark),
                    _buildPresetPill('Camilan & Protein', isDark),
                  ],
                ),
              ),
            ),

            // Preset Items List
            SliverToBoxAdapter(
              child: SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: presets.length,
                  itemBuilder: (context, index) {
                    final item = presets[index];
                    return GestureDetector(
                      onTap: () => _quickAddPreset(item),
                      child: Container(
                        width: 175,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppleColors.cardBg(isDark),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppleColors.separator(isDark)),
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.black.withOpacity(isDark ? 0.3 : 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppleColors.label(isDark),
                              ),
                            ),
                            Text(
                              item.portionDesc,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppleColors.secondaryLabel(isDark),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '+${item.calories} kcal',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppleColors.systemOrange,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppleColors.systemOrange,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.plus,
                                    size: 10,
                                    color: CupertinoColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Section: Daily Habit Streaks
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  children: [
                    Text(
                      'KEBIASAAN & RUTINITAS HARIAN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppleColors.secondaryLabel(isDark),
                      ),
                    ),
                    const Spacer(),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 24,
                      onPressed: () => _openAddHabitSheet(context),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.plus_circle_fill, size: 14, color: AppleColors.systemBlue),
                          const SizedBox(width: 4),
                          Text(
                            'Tambah Habit',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppleColors.systemBlue),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final habit = habits[index];
                    return _buildHabitCard(habit, isDark);
                  },
                  childCount: habits.length,
                ),
              ),
            ),

            // Section: Today's Logged Meals
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  children: [
                    Text(
                      'CATATAN ASUPAN HARI INI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppleColors.secondaryLabel(isDark),
                      ),
                    ),
                    const Spacer(),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 24,
                      onPressed: () => _openManualCalorieSheet(context),
                      child: Text(
                        '+ Catat Manual',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppleColors.systemBlue),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (todayLogs.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                  child: Center(
                    child: Text(
                      'Belum ada makanan/minuman yang dicatat hari ini.',
                      style: TextStyle(fontSize: 13, color: AppleColors.secondaryLabel(isDark)),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final log = todayLogs[index];
                      return _buildCalorieLogTile(log, isDark);
                    },
                    childCount: todayLogs.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        ),

        // Floating feedback banner
        if (_feedbackMessage != null)
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _feedbackMessage != null ? 1.0 : 0.0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.checkmark_circle_fill, color: AppleColors.systemGreen, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _feedbackMessage!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPresetPill(String category, bool isDark) {
    final isSelected = _presetCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _presetCategory = category),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppleColors.systemOrange : AppleColors.cardBg(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppleColors.systemOrange : AppleColors.separator(isDark),
          ),
        ),
        child: Text(
          category,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? CupertinoColors.white : AppleColors.label(isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildHabitCard(HabitItem habit, bool isDark) {
    final isDone = habit.isCompletedToday();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppleColors.cardBg(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? Color(habit.colorValue).withOpacity(0.4) : AppleColors.separator(isDark),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => widget.state.toggleHabitToday(habit.id),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDone ? Color(habit.colorValue) : CupertinoColors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone ? Color(habit.colorValue) : AppleColors.secondaryLabel(isDark),
                  width: 2,
                ),
              ),
              child: isDone
                  ? const Icon(CupertinoIcons.checkmark, size: 16, color: CupertinoColors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone ? AppleColors.secondaryLabel(isDark) : AppleColors.label(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Text('🔥 ', style: TextStyle(fontSize: 12)),
                    Text(
                      '${habit.currentStreak} Hari Beruntun',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(habit.colorValue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 28,
            onPressed: () => widget.state.deleteHabit(habit.id),
            child: const Icon(CupertinoIcons.trash, size: 14, color: AppleColors.systemRed),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieLogTile(CalorieLog log, bool isDark) {
    final timeFormat = DateFormat('HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppleColors.cardBg(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppleColors.separator(isDark)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppleColors.systemOrange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              log.mealType,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppleColors.systemOrange,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.foodName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppleColors.label(isDark),
                  ),
                ),
                Text(
                  timeFormat.format(log.dateTime),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppleColors.tertiaryLabel(isDark),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+${log.calories} kcal',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppleColors.label(isDark),
            ),
          ),
          const SizedBox(width: 8),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 24,
            onPressed: () => widget.state.deleteCalorieLog(log.id),
            child: const Icon(CupertinoIcons.xmark_circle_fill, size: 16, color: Color(0xFF8E8E93)),
          ),
        ],
      ),
    );
  }
}

class _AddCalorieModalSheet extends StatefulWidget {
  final DashboardState state;

  const _AddCalorieModalSheet({required this.state});

  @override
  State<_AddCalorieModalSheet> createState() => _AddCalorieModalSheetState();
}

class _AddCalorieModalSheetState extends State<_AddCalorieModalSheet> {
  final _foodController = TextEditingController();
  final _calController = TextEditingController();
  String _mealType = 'Makan Siang';

  @override
  void dispose() {
    _foodController.dispose();
    _calController.dispose();
    super.dispose();
  }

  void _save() {
    final food = _foodController.text.trim();
    final cal = int.tryParse(_calController.text);
    if (food.isEmpty || cal == null || cal <= 0) return;

    final log = CalorieLog(
      id: 'cal_${DateTime.now().millisecondsSinceEpoch}',
      foodName: food,
      calories: cal,
      mealType: _mealType,
      dateTime: DateTime.now(),
    );

    widget.state.addCalorieLog(log);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: AppleColors.cardBg(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                Text(
                  'Catat Makanan / Minuman',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppleColors.label(isDark),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _save,
                  child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold, color: AppleColors.systemOrange)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildFieldLabel('Nama Makanan / Minuman *', isDark),
                CupertinoTextField(
                  controller: _foodController,
                  placeholder: 'Contoh: Es Kopi Susu Aren, Nasi Campur, Telur Dada',
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: _inputDecoration(isDark),
                  style: TextStyle(color: AppleColors.label(isDark)),
                ),
                const SizedBox(height: 16),

                _buildFieldLabel('Jumlah Kalori (kcal) *', isDark),
                CupertinoTextField(
                  controller: _calController,
                  placeholder: 'Contoh: 350',
                  keyboardType: TextInputType.number,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: _inputDecoration(isDark),
                  style: TextStyle(color: AppleColors.label(isDark)),
                ),
                const SizedBox(height: 16),

                _buildFieldLabel('Waktu Makan', isDark),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoSegmentedControl<String>(
                    groupValue: _mealType,
                    children: const {
                      'Sarapan': Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Sarapan')),
                      'Makan Siang': Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Siang')),
                      'Makan Malam': Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Malam')),
                      'Camilan/Kopi': Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Camilan')),
                    },
                    onValueChanged: (val) => setState(() => _mealType = val),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppleColors.secondaryLabel(isDark),
        ),
      ),
    );
  }

  BoxDecoration _inputDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppleColors.separator(isDark)),
    );
  }
}

class _AddHabitModalSheet extends StatefulWidget {
  final DashboardState state;

  const _AddHabitModalSheet({required this.state});

  @override
  State<_AddHabitModalSheet> createState() => _AddHabitModalSheetState();
}

class _AddHabitModalSheetState extends State<_AddHabitModalSheet> {
  final _titleController = TextEditingController();
  int _selectedColor = 0xFF007AFF;

  final List<int> _colors = [
    0xFF007AFF, // Blue
    0xFFFF9500, // Orange
    0xFFFF2D55, // Red/Pink
    0xFF5856D6, // Indigo
    0xFF34C759, // Green
    0xFFAF52DE, // Purple
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final habit = HabitItem(
      id: 'h_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      iconCode: 'star',
      colorValue: _selectedColor,
    );

    widget.state.addHabit(habit);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;

    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: BoxDecoration(
        color: AppleColors.cardBg(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                Text(
                  'Tambah Habit Baru',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppleColors.label(isDark),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _save,
                  child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildFieldLabel('Nama Kebiasaan *', isDark),
                CupertinoTextField(
                  controller: _titleController,
                  placeholder: 'Contoh: Baca Buku 15 Menit, Minum Air 2L',
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: _inputDecoration(isDark),
                  style: TextStyle(color: AppleColors.label(isDark)),
                ),
                const SizedBox(height: 20),

                _buildFieldLabel('Pilih Warna Tema', isDark),
                Row(
                  children: _colors.map((c) {
                    final isSel = _selectedColor == c;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = c),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(c),
                          shape: BoxShape.circle,
                          border: isSel
                              ? Border.all(color: CupertinoColors.white, width: 3)
                              : null,
                          boxShadow: [
                            if (isSel)
                              BoxShadow(color: Color(c).withOpacity(0.6), blurRadius: 8),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppleColors.secondaryLabel(isDark),
        ),
      ),
    );
  }

  BoxDecoration _inputDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppleColors.separator(isDark)),
    );
  }
}
