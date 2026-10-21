import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/running_shoe_item.dart';
import '../state/dashboard_state.dart';
import '../theme/apple_colors.dart';
import '../widgets/apple_burger_icon.dart';

class RunningScreen extends StatelessWidget {
  final DashboardState state;
  final VoidCallback onOpenDrawer;
  final VoidCallback onBackToHome;

  const RunningScreen({
    super.key,
    required this.state,
    required this.onOpenDrawer,
    required this.onBackToHome,
  });

  void _openAddRunSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _AddRunModalSheet(state: state),
    );
  }

  void _openAddShoeSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _AddShoeModalSheet(state: state),
    );
  }

  void _openManualKmSheet(BuildContext context, ShoeItem shoe) {
    final controller = TextEditingController();
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('Tambah KM: ${shoe.name}'),
        content: Column(
          children: [
            const SizedBox(height: 10),
            const Text('Masukkan jarak lari yang ingin ditambahkan ke odometer sepatu:'),
            const SizedBox(height: 12),
            CupertinoTextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              placeholder: 'Contoh: 5.5',
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
              final val = double.tryParse(controller.text.replaceAll(',', '.'));
              if (val != null && val > 0) {
                state.addKmToShoe(shoe.id, val);
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
    final isDark = state.isDarkMode;
    final weeklyKm = state.weeklyKm;
    final shoes = state.shoes;
    final runLogs = state.runLogs;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        // Top Navigation Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 36,
                  onPressed: onBackToHome,
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
                  onPressed: onOpenDrawer,
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
                  onPressed: () => _openAddRunSheet(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF2D55), // Nike / Apple Fitness Pink-Red
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

        // Screen Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Running & Sepatu',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppleColors.label(isDark),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF2D55).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '🏃‍♂️ Runner Hub',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFF2D55),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Odometer sepatu lari, rekor Personal Best (PB), & log latihan',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppleColors.secondaryLabel(isDark),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Weekly Mileage Banner
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF2C151A), const Color(0xFF18181A)]
                      : [const Color(0xFFFFE8EC), const Color(0xFFFFFFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFF2D55).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF2D55).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: Color(0xFFFF2D55),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'JARAK 7 HARI TERAKHIR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: const Color(0xFFFF2D55),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              weeklyKm.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                                color: AppleColors.label(isDark),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'KM',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppleColors.secondaryLabel(isDark),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    color: const Color(0xFFFF2D55),
                    borderRadius: BorderRadius.circular(20),
                    onPressed: () => _openAddRunSheet(context),
                    child: const Text(
                      '+ Catat Lari',
                      style: TextStyle(
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
        ),

        // Section: Personal Best (PB)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text(
                  'PERSONAL BEST (PB)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppleColors.secondaryLabel(isDark),
                  ),
                ),
                const Spacer(),
                const Text(
                  '🏆 Rekor Terbaik',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFFF9500)),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: SizedBox(
            height: 94,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              children: state.personalBests.map((pb) {
                return Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppleColors.cardBg(isDark),
                    borderRadius: BorderRadius.circular(16),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            pb.distanceLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFFF9500),
                            ),
                          ),
                          const Icon(CupertinoIcons.sparkles, size: 12, color: Color(0xFFFF9500)),
                        ],
                      ),
                      Text(
                        pb.time,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: AppleColors.label(isDark),
                        ),
                      ),
                      Text(
                        'Pace ${pb.pace}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppleColors.secondaryLabel(isDark),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Section: Shoe Rotation & Wear
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              children: [
                Text(
                  'ROTASI SEPATU & ODOMETER',
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
                  onPressed: () => _openAddShoeSheet(context),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.plus_circle_fill, size: 14, color: AppleColors.systemBlue),
                      const SizedBox(width: 4),
                      Text(
                        'Tambah Sepatu',
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
                final shoe = shoes[index];
                return _buildShoeCard(context, shoe, isDark);
              },
              childCount: shoes.length,
            ),
          ),
        ),

        // Section: Recent Run Logs
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'LOG LARI TERKINI',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppleColors.secondaryLabel(isDark),
              ),
            ),
          ),
        ),

        if (runLogs.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
              child: Center(
                child: Text(
                  'Belum ada catatan lari. Mulai tap "+ Catat Lari"!',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppleColors.secondaryLabel(isDark),
                  ),
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
                  final run = runLogs[index];
                  return _buildRunLogCard(context, run, isDark);
                },
                childCount: runLogs.length,
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 48)),
      ],
    );
  }

  Widget _buildShoeCard(BuildContext context, ShoeItem shoe, bool isDark) {
    final wearPct = shoe.wearPercentage;
    final pctText = (wearPct * 100).toStringAsFixed(0);

    // Wear level color
    Color wearColor = AppleColors.systemGreen;
    if (wearPct > 0.8) {
      wearColor = AppleColors.systemRed;
    } else if (wearPct > 0.6) {
      wearColor = AppleColors.systemOrange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppleColors.cardBg(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: shoe.isRetired
              ? AppleColors.separator(isDark)
              : Color(shoe.colorValue).withOpacity(0.3),
        ),
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
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Color(shoe.colorValue),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  shoe.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    decoration: shoe.isRetired ? TextDecoration.lineThrough : null,
                    color: shoe.isRetired
                        ? AppleColors.secondaryLabel(isDark)
                        : AppleColors.label(isDark),
                  ),
                ),
              ),
              if (shoe.isRetired)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppleColors.separator(isDark),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Pensiun', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                )
              else
                Text(
                  '$pctText% Aus',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: wearColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: wearPct,
              backgroundColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
              valueColor: AlwaysStoppedAnimation<Color>(shoe.isRetired ? const Color(0xFF8E8E93) : wearColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${shoe.currentKm.toStringAsFixed(1)} / ${shoe.targetMaxKm.toStringAsFixed(0)} KM',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppleColors.secondaryLabel(isDark),
                ),
              ),
              Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 24,
                    onPressed: () => _openManualKmSheet(context, shoe),
                    child: Text(
                      '+ KM',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppleColors.systemBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 24,
                    onPressed: () => state.toggleRetireShoe(shoe.id),
                    child: Icon(
                      shoe.isRetired ? CupertinoIcons.arrow_counterclockwise : CupertinoIcons.archivebox,
                      size: 14,
                      color: AppleColors.secondaryLabel(isDark),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 24,
                    onPressed: () => state.deleteShoe(shoe.id),
                    child: const Icon(
                      CupertinoIcons.trash,
                      size: 14,
                      color: AppleColors.systemRed,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRunLogCard(BuildContext context, RunLog run, bool isDark) {
    final dateFormat = DateFormat('EEE, d MMM yyyy • HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppleColors.cardBg(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppleColors.separator(isDark)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFF2D55).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.speed_rounded,
              size: 22,
              color: Color(0xFFFF2D55),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${run.distanceKm.toStringAsFixed(2)} KM',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppleColors.label(isDark),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppleColors.systemBlue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        run.pace,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppleColors.systemBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${run.durationMinutes} menit • ${run.shoeName}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppleColors.secondaryLabel(isDark),
                  ),
                ),
                if (run.notes != null && run.notes!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    run.notes!,
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: AppleColors.tertiaryLabel(isDark),
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  dateFormat.format(run.date),
                  style: TextStyle(
                    fontSize: 10,
                    color: AppleColors.tertiaryLabel(isDark),
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 28,
            onPressed: () => state.deleteRunLog(run.id),
            child: const Icon(
              CupertinoIcons.trash,
              size: 14,
              color: AppleColors.systemRed,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddRunModalSheet extends StatefulWidget {
  final DashboardState state;

  const _AddRunModalSheet({required this.state});

  @override
  State<_AddRunModalSheet> createState() => _AddRunModalSheetState();
}

class _AddRunModalSheetState extends State<_AddRunModalSheet> {
  final _distController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedShoeId = '';

  @override
  void initState() {
    super.initState();
    final shoes = widget.state.activeShoes;
    if (shoes.isNotEmpty) {
      _selectedShoeId = shoes.first.id;
    }
  }

  @override
  void dispose() {
    _distController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    final dist = double.tryParse(_distController.text.replaceAll(',', '.'));
    final duration = int.tryParse(_durationController.text);
    if (dist == null || dist <= 0 || duration == null || duration <= 0) return;

    // Calculate pace
    final totalSec = (duration * 60) / dist;
    final paceMin = (totalSec / 60).floor();
    final paceSec = (totalSec % 60).round().toString().padLeft(2, '0');
    final paceStr = '$paceMin:$paceSec /km';

    final shoe = widget.state.shoes.firstWhere(
      (s) => s.id == _selectedShoeId,
      orElse: () => ShoeItem(id: '', name: 'Umum', brand: '', colorValue: 0),
    );

    final newRun = RunLog(
      id: 'run_${DateTime.now().millisecondsSinceEpoch}',
      distanceKm: dist,
      durationMinutes: duration,
      pace: paceStr,
      shoeId: shoe.id,
      shoeName: shoe.name,
      date: DateTime.now(),
      notes: _notesController.text.trim(),
    );

    widget.state.addRunLog(newRun);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;
    final shoes = widget.state.activeShoes;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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
                  'Catat Latihan Lari',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppleColors.label(isDark),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _save,
                  child: const Text(
                    'Simpan',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF2D55)),
                  ),
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
                _buildFieldLabel('Jarak (KM) *', isDark),
                CupertinoTextField(
                  controller: _distController,
                  placeholder: 'Contoh: 5.25',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: _inputDecoration(isDark),
                  style: TextStyle(color: AppleColors.label(isDark)),
                ),
                const SizedBox(height: 16),

                _buildFieldLabel('Durasi (Menit) *', isDark),
                CupertinoTextField(
                  controller: _durationController,
                  placeholder: 'Contoh: 28',
                  keyboardType: TextInputType.number,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: _inputDecoration(isDark),
                  style: TextStyle(color: AppleColors.label(isDark)),
                ),
                const SizedBox(height: 16),

                if (shoes.isNotEmpty) ...[
                  _buildFieldLabel('Pilih Sepatu yang Digunakan', isDark),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: _inputDecoration(isDark),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedShoeId.isEmpty ? shoes.first.id : _selectedShoeId,
                        dropdownColor: AppleColors.cardBg(isDark),
                        isExpanded: true,
                        items: shoes.map((s) {
                          return DropdownMenuItem(
                            value: s.id,
                            child: Text(
                              '${s.name} (${s.currentKm.toStringAsFixed(1)} KM)',
                              style: TextStyle(color: AppleColors.label(isDark)),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedShoeId = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                _buildFieldLabel('Catatan Rute / Kondisi Tubuh', isDark),
                CupertinoTextField(
                  controller: _notesController,
                  placeholder: 'Contoh: Rute GBK Senayan, cuaca cerah, cadence nyaman...',
                  maxLines: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: _inputDecoration(isDark),
                  style: TextStyle(color: AppleColors.label(isDark)),
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

class _AddShoeModalSheet extends StatefulWidget {
  final DashboardState state;

  const _AddShoeModalSheet({required this.state});

  @override
  State<_AddShoeModalSheet> createState() => _AddShoeModalSheetState();
}

class _AddShoeModalSheetState extends State<_AddShoeModalSheet> {
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _targetKmController = TextEditingController(text: '650');
  final _initKmController = TextEditingController(text: '0');
  int _selectedColor = 0xFF007AFF;

  final List<int> _colors = [
    0xFF007AFF, // Blue
    0xFFFF9500, // Orange
    0xFFFF2D55, // Pink/Red
    0xFF5856D6, // Indigo
    0xFF34C759, // Green
    0xFFAF52DE, // Purple
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _targetKmController.dispose();
    _initKmController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final targetKm = double.tryParse(_targetKmController.text) ?? 650.0;
    final initKm = double.tryParse(_initKmController.text) ?? 0.0;

    final newShoe = ShoeItem(
      id: 'shoe_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      brand: _brandController.text.trim().isEmpty ? 'Running' : _brandController.text.trim(),
      currentKm: initKm,
      targetMaxKm: targetKm,
      colorValue: _selectedColor,
    );

    widget.state.addShoe(newShoe);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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
                  'Tambah Sepatu Lari',
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
                _buildFieldLabel('Nama Sepatu *', isDark),
                CupertinoTextField(
                  controller: _nameController,
                  placeholder: 'Contoh: Pegasus 41 / Superblast 2',
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: _inputDecoration(isDark),
                  style: TextStyle(color: AppleColors.label(isDark)),
                ),
                const SizedBox(height: 16),

                _buildFieldLabel('Brand', isDark),
                CupertinoTextField(
                  controller: _brandController,
                  placeholder: 'Contoh: Nike, Asics, Adidas, Hoka, Ortuseight',
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: _inputDecoration(isDark),
                  style: TextStyle(color: AppleColors.label(isDark)),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Target Max KM', isDark),
                          CupertinoTextField(
                            controller: _targetKmController,
                            keyboardType: TextInputType.number,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: _inputDecoration(isDark),
                            style: TextStyle(color: AppleColors.label(isDark)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('KM Awal (Jika Ada)', isDark),
                          CupertinoTextField(
                            controller: _initKmController,
                            keyboardType: TextInputType.number,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: _inputDecoration(isDark),
                            style: TextStyle(color: AppleColors.label(isDark)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildFieldLabel('Pilih Warna Tag', isDark),
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
                              BoxShadow(
                                color: Color(c).withOpacity(0.6),
                                blurRadius: 8,
                              ),
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
