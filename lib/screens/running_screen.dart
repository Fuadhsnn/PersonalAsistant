import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/running_shoe_item.dart';
import '../state/dashboard_state.dart';
import '../theme/apple_colors.dart';
import '../widgets/tactile_top_bar.dart';

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

  Future<void> _openHuaweiHealthApp(BuildContext context) async {
    final uri = Uri.parse('huaweihealth://');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        final storeUri = Uri.parse('https://apps.apple.com/id/app/huawei-health/id1329999978');
        await launchUrl(storeUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      final storeUri = Uri.parse('https://apps.apple.com/id/app/huawei-health/id1329999978');
      await launchUrl(storeUri, mode: LaunchMode.externalApplication);
    }
  }

  void _openHuaweiHealthSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _HuaweiHealthModalSheet(
        state: state,
        onOpenStravaModal: () {
          Navigator.pop(ctx);
          _openConnectStravaSheet(context);
        },
      ),
    );
  }

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

  void _openEditPbSheet(BuildContext context, PersonalBest pb) {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _EditPersonalBestModalSheet(state: state, personalBest: pb),
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

  void _openConnectStravaSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _ConnectStravaModalSheet(state: state),
    );
  }

  void _confirmDisconnectStrava(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Putuskan Tautan Strava?'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'Aktivitas lari yang telah tersimpan tidak akan terhapus, namun sinkronisasi otomatis akan dimatikan.',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              state.disconnectStrava();
              Navigator.pop(ctx);
            },
            child: const Text('Putuskan'),
          ),
        ],
      ),
    );
  }

  void _showSyncResult(BuildContext context, int count) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sync_rounded, size: 20, color: Color(0xFFFC4C02)),
            SizedBox(width: 6),
            Text('Sinkronisasi Strava'),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            count > 0
                ? 'Berhasil menarik $count aktivitas lari baru dari Strava!'
                : 'Semua aktivitas Strava sudah tersinkronkan. Tidak ada lari baru yang ditemukan.',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
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
        // Top Navigation Bar (Option B: iOS Large Title Standard)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: TactileTopBar(
              title: 'Strava & Running',
              subtitle: 'Tracking performa lari mingguan & mileage sepatu.',
              useLargeTitle: true,
              onOpenDrawer: onOpenDrawer,
              isDark: isDark,
              rightAction: TactileTopBar.actionButton(
                icon: const Icon(
                  CupertinoIcons.plus,
                  size: 20,
                  color: AppleColors.stravaOrange,
                ),
                onPressed: () => _openAddRunSheet(context),
                isDark: isDark,
              ),
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

        // Strava & Huawei Health Ecosystem Cards
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                _buildStravaCard(context, state, isDark),
                const SizedBox(height: 12),
                _buildHuaweiHealthCard(context, state, isDark),
              ],
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.pencil, size: 12, color: const Color(0xFFFF9500)),
                    const SizedBox(width: 4),
                    const Text(
                      'Tap kartu untuk edit',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFFF9500)),
                    ),
                  ],
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
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openEditPbSheet(context, pb),
                  child: Container(
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
                            const Icon(CupertinoIcons.pencil, size: 12, color: Color(0xFFFF9500)),
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

  Widget _buildStravaCard(BuildContext context, DashboardState state, bool isDark) {
    if (!state.isStravaConnected) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFC4C02), Color(0xFFD63E00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFC4C02).withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions_run_rounded, size: 14, color: CupertinoColors.white),
                      SizedBox(width: 4),
                      Text(
                        'STRAVA SYNC',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: CupertinoColors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Text(
                  '⚡ Auto Sync',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: CupertinoColors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Tautkan Akun Strava',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: CupertinoColors.white,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tarik otomatis catatan lari, jarak mingguan, pace, serta hitung odometer sepatu tanpa repot input manual.',
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                color: CupertinoColors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(14),
                  onPressed: () => _openConnectStravaSheet(context),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.link_rounded, size: 16, color: Color(0xFFFC4C02)),
                      SizedBox(width: 6),
                      Text(
                        'Hubungkan Strava',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFC4C02),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final lastSync = state.stravaLastSync;
    final lastSyncText = lastSync != null
        ? DateFormat('d MMM, HH:mm').format(lastSync)
        : 'Belum pernah';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppleColors.cardBg(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFC4C02).withOpacity(0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(isDark ? 0.3 : 0.03),
            blurRadius: 10,
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFC4C02).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFFFC4C02)),
                    SizedBox(width: 4),
                    Text(
                      'STRAVA TERHUBUNG',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFC4C02),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 22,
                onPressed: () => _confirmDisconnectStrava(context),
                child: Text(
                  'Putuskan Tautan',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppleColors.secondaryLabel(isDark),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFC4C02),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.directions_run_rounded,
                  color: CupertinoColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.stravaAthleteName.isNotEmpty
                          ? state.stravaAthleteName
                          : 'Strava Runner',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppleColors.label(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sync terakhir: $lastSyncText',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppleColors.secondaryLabel(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                color: const Color(0xFFFC4C02),
                borderRadius: BorderRadius.circular(14),
                onPressed: state.isSyncingStrava
                    ? null
                    : () async {
                        final count = await state.syncStravaActivities();
                        if (context.mounted) {
                          _showSyncResult(context, count);
                        }
                      },
                child: state.isSyncingStrava
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CupertinoActivityIndicator(color: CupertinoColors.white),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sync_rounded, size: 16, color: CupertinoColors.white),
                          SizedBox(width: 6),
                          Text(
                            'Sinkronkan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHuaweiHealthCard(BuildContext context, DashboardState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppleColors.cardBg(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE60012).withOpacity(0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(isDark ? 0.3 : 0.03),
            blurRadius: 10,
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE60012).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.watch_rounded, size: 12, color: Color(0xFFE60012)),
                    SizedBox(width: 4),
                    Text(
                      'HUAWEI HEALTH & WATCH',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFE60012),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                '⌚ Huawei GT/Band',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE60012),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Huawei Health Hub',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppleColors.label(isDark),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Buka aplikasi Huawei Health langsung di iPhone atau hubungkan otomatis ke Strava tanpa biaya langganan.',
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: AppleColors.secondaryLabel(isDark),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                color: const Color(0xFFE60012),
                borderRadius: BorderRadius.circular(12),
                onPressed: () => _openHuaweiHealthApp(context),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.open_in_browser_rounded, size: 15, color: CupertinoColors.white),
                    SizedBox(width: 6),
                    Text(
                      'Buka Huawei Health',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(12),
                onPressed: () => _openHuaweiHealthSheet(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.help_outline_rounded,
                      size: 15,
                      color: AppleColors.label(isDark),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Panduan Sync Gratis',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppleColors.label(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
    final isStravaRun = run.id.startsWith('strava_');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppleColors.cardBg(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isStravaRun
              ? const Color(0xFFFC4C02).withOpacity(0.3)
              : AppleColors.separator(isDark),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isStravaRun
                  ? const Color(0xFFFC4C02).withOpacity(0.14)
                  : const Color(0xFFFF2D55).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isStravaRun ? Icons.directions_run_rounded : Icons.speed_rounded,
              size: 22,
              color: isStravaRun ? const Color(0xFFFC4C02) : const Color(0xFFFF2D55),
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
                    if (isStravaRun) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFC4C02).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.directions_run_rounded, size: 10, color: Color(0xFFFC4C02)),
                            SizedBox(width: 2),
                            Text(
                              'STRAVA',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFFC4C02),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
    final viewInsets = MediaQuery.of(context).viewInsets;
    final screenHeight = MediaQuery.of(context).size.height;
    final targetHeight = (screenHeight * 0.82).clamp(280.0, screenHeight - viewInsets.bottom - 44);

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: Material(
        type: MaterialType.transparency,
        child: DefaultTextStyle(
          style: TextStyle(
            decoration: TextDecoration.none,
            color: AppleColors.label(isDark),
            fontSize: 14,
          ),
          child: Container(
            height: targetHeight,
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
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
    ),
  ),
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
          decoration: TextDecoration.none,
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
    final viewInsets = MediaQuery.of(context).viewInsets;
    final screenHeight = MediaQuery.of(context).size.height;
    final targetHeight = (screenHeight * 0.82).clamp(280.0, screenHeight - viewInsets.bottom - 44);

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: Material(
        type: MaterialType.transparency,
        child: DefaultTextStyle(
          style: TextStyle(
            decoration: TextDecoration.none,
            color: AppleColors.label(isDark),
            fontSize: 14,
          ),
          child: Container(
            height: targetHeight,
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
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                      behavior: HitTestBehavior.opaque,
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
    ),
  ),
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
          decoration: TextDecoration.none,
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

class _ConnectStravaModalSheet extends StatefulWidget {
  final DashboardState state;

  const _ConnectStravaModalSheet({required this.state});

  @override
  State<_ConnectStravaModalSheet> createState() => _ConnectStravaModalSheetState();
}

class _ConnectStravaModalSheetState extends State<_ConnectStravaModalSheet> {
  final _tokenController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _handleConnect() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      setState(() => _errorMessage = 'Silakan masukkan Personal Access Token Strava Anda.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await widget.state.connectStrava(token);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memverifikasi token Strava. Pastikan token aktif dan memiliki izin membaca aktivitas.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final screenHeight = MediaQuery.of(context).size.height;
    final targetHeight = (screenHeight * 0.82).clamp(280.0, screenHeight - viewInsets.bottom - 44);

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: Material(
        type: MaterialType.transparency,
        child: DefaultTextStyle(
          style: TextStyle(
            decoration: TextDecoration.none,
            color: AppleColors.label(isDark),
            fontSize: 14,
          ),
          child: Container(
            height: targetHeight,
            decoration: BoxDecoration(
              color: AppleColors.cardBg(isDark),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: Text('Batal', style: TextStyle(color: AppleColors.secondaryLabel(isDark))),
                  ),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions_run_rounded, size: 18, color: Color(0xFFFC4C02)),
                      SizedBox(width: 6),
                      Text(
                        'Tautkan Strava',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _isLoading ? null : _handleConnect,
                    child: _isLoading
                        ? const CupertinoActivityIndicator()
                        : const Text(
                            'Simpan',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFC4C02),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: ListView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(20),
              children: [
                // Strava Brand Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFC4C02).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFC4C02).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFC4C02),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.speed_rounded,
                          color: CupertinoColors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Strava API v3 Integration',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFFC4C02),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Tarik otomatis jarak lari, pace, moving time, dan waktu latihan dari akun Strava Anda.',
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.3,
                                color: AppleColors.secondaryLabel(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Free guarantee banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34C759).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF34C759).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.checkmark_shield_fill, color: Color(0xFF34C759), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '100% GRATIS: Tidak perlu berlangganan Strava Summit / Premium (Rp 80rb+/bln). Abaikan penawaran berbayar di web Strava; akun gratis dapat membuat Personal Access Token tanpa biaya.',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF30D158) : const Color(0xFF248A3D),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tutorial Steps
                Text(
                  'CARA MENDAPATKAN TOKEN:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppleColors.secondaryLabel(isDark),
                  ),
                ),
                const SizedBox(height: 10),

                _buildStepItem(
                  number: '1',
                  title: 'Buka Pengaturan API Strava',
                  desc: 'Buka browser dan login ke strava.com/settings/api. Abaikan jika ada iklan langganan berbayar.',
                  isDark: isDark,
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
                    borderRadius: BorderRadius.circular(8),
                    onPressed: () => launchUrl(
                      Uri.parse('https://www.strava.com/settings/api'),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.open_in_new_rounded, size: 13, color: Color(0xFFFC4C02)),
                        const SizedBox(width: 6),
                        Text(
                          'Buka strava.com/settings/api',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppleColors.label(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _buildStepItem(
                  number: '2',
                  title: 'Salin "Your API Access Token"',
                  desc: 'Di halaman API Application Strava, salin teks pada bagian "Your API Access Token".',
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                _buildStepItem(
                  number: '3',
                  title: 'Tempelkan Token di Bawah Ini',
                  desc: 'Paste token ke kolom teks di bawah lalu tekan tombol Verifikasi & Hubungkan.',
                  isDark: isDark,
                ),
                const SizedBox(height: 20),

                Text(
                  'PERSONAL ACCESS TOKEN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppleColors.secondaryLabel(isDark),
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _errorMessage != null
                          ? AppleColors.systemRed
                          : AppleColors.separator(isDark),
                    ),
                  ),
                  child: CupertinoTextField(
                    controller: _tokenController,
                    placeholder: 'Tempelkan token Strava Anda di sini (misal: 8f9b2c...)',
                    placeholderStyle: TextStyle(
                      fontSize: 13,
                      color: AppleColors.tertiaryLabel(isDark),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppleColors.label(isDark),
                    ),
                    decoration: const BoxDecoration(),
                    clearButtonMode: OverlayVisibilityMode.editing,
                    maxLines: 1,
                  ),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(CupertinoIcons.exclamationmark_circle_fill, size: 14, color: AppleColors.systemRed),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppleColors.systemRed,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                CupertinoButton(
                  color: const Color(0xFFFC4C02),
                  borderRadius: BorderRadius.circular(16),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  onPressed: _isLoading ? null : _handleConnect,
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CupertinoActivityIndicator(color: CupertinoColors.white),
                            SizedBox(width: 8),
                            Text(
                              'Menghubungkan & Menarik Lari...',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: CupertinoColors.white,
                              ),
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bolt_rounded, color: CupertinoColors.white, size: 20),
                            SizedBox(width: 6),
                            Text(
                              'Verifikasi & Hubungkan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: CupertinoColors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
),
);
  }

  Widget _buildStepItem({
    required String number,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppleColors.cardBg(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppleColors.separator(isDark)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFFC4C02).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFFFC4C02),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppleColors.label(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.3,
                    color: AppleColors.secondaryLabel(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HuaweiHealthModalSheet extends StatelessWidget {
  final DashboardState state;
  final VoidCallback onOpenStravaModal;

  const _HuaweiHealthModalSheet({
    required this.state,
    required this.onOpenStravaModal,
  });

  Future<void> _openHuaweiApp() async {
    final uri = Uri.parse('huaweihealth://');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        final storeUri = Uri.parse('https://apps.apple.com/id/app/huawei-health/id1329999978');
        await launchUrl(storeUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      final storeUri = Uri.parse('https://apps.apple.com/id/app/huawei-health/id1329999978');
      await launchUrl(storeUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openStravaApiUrl() async {
    final uri = Uri.parse('https://www.strava.com/settings/api');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = state.isDarkMode;

    return Material(
      type: MaterialType.transparency,
      child: DefaultTextStyle(
        style: TextStyle(
          fontFamily: '.SF Pro Display',
          decoration: TextDecoration.none,
          color: AppleColors.label(isDark),
          fontSize: 14,
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
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
                      child: const Text('Tutup'),
                    ),
                    Text(
                      'Huawei Health & Strava Sync',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.none,
                        color: AppleColors.label(isDark),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const Divider(height: 1),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Free clarification highlight
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF34C759).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF34C759).withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(CupertinoIcons.checkmark_seal_fill, color: Color(0xFF34C759), size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Kabar Baik: Strava API 100% Gratis!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    decoration: TextDecoration.none,
                                    color: Color(0xFF34C759),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Anda TIDAK perlu berlangganan Strava Summit / Premium (Rp 80rb+/bln). Iklan langganan di website Strava bisa diabaikan. Akun gratis tetap bebas membuat Personal Access Token untuk menarik data lari pribadi.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.35,
                                    decoration: TextDecoration.none,
                                    color: AppleColors.label(isDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Architecture Flow Diagram
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppleColors.separator(isDark)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ALUR SINKRONISASI OTOMATIS:',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              decoration: TextDecoration.none,
                              color: AppleColors.secondaryLabel(isDark),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildFlowNode(
                                icon: Icons.watch_rounded,
                                label: 'Huawei Watch',
                                color: const Color(0xFFE60012),
                                isDark: isDark,
                              ),
                              Icon(Icons.arrow_forward_rounded, size: 16, color: AppleColors.secondaryLabel(isDark)),
                              _buildFlowNode(
                                icon: Icons.phone_iphone_rounded,
                                label: 'Huawei Health',
                                color: const Color(0xFFE60012),
                                isDark: isDark,
                              ),
                              Icon(Icons.arrow_forward_rounded, size: 16, color: AppleColors.secondaryLabel(isDark)),
                              _buildFlowNode(
                                icon: Icons.speed_rounded,
                                label: 'Strava Free',
                                color: const Color(0xFFFC4C02),
                                isDark: isDark,
                              ),
                              Icon(Icons.arrow_forward_rounded, size: 16, color: AppleColors.secondaryLabel(isDark)),
                              _buildFlowNode(
                                icon: Icons.dashboard_rounded,
                                label: 'Dashboard',
                                color: const Color(0xFF007AFF),
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    Text(
                      'PANDUAN LANGKAH INTEGRASI:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        decoration: TextDecoration.none,
                        color: AppleColors.secondaryLabel(isDark),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Step 1
                    _buildStepCard(
                      stepNumber: '1',
                      title: 'Hubungkan Huawei Health ke Strava',
                      description: 'Buka app Huawei Health di iPhone > tab "Saya" (Me) > "Manajemen Privasi" (Privacy Management) > "Layanan Pihak Ketiga" > pilih "Strava" lalu tekan "Tautkan".',
                      actionButton: CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        color: const Color(0xFFE60012),
                        borderRadius: BorderRadius.circular(10),
                        onPressed: _openHuaweiApp,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.open_in_browser_rounded, size: 14, color: CupertinoColors.white),
                            SizedBox(width: 6),
                            Text(
                              'Buka App Huawei Health',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: CupertinoColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),

                    // Step 2
                    _buildStepCard(
                      stepNumber: '2',
                      title: 'Dapatkan Token Strava Gratis',
                      description: 'Buka strava.com/settings/api di browser. Login, isi form app gratis jika diminta (nama: Personal Assistant, website: https://localhost). Gulir ke bawah lalu salin "Your API Access Token".',
                      actionButton: CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        color: const Color(0xFFFC4C02),
                        borderRadius: BorderRadius.circular(10),
                        onPressed: _openStravaApiUrl,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.open_in_new_rounded, size: 14, color: CupertinoColors.white),
                            SizedBox(width: 6),
                            Text(
                              'Buka strava.com/settings/api',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: CupertinoColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),

                    // Step 3
                    _buildStepCard(
                      stepNumber: '3',
                      title: 'Tautkan Token ke Dashboard',
                      description: 'Buka form "Tautkan Strava" di Personal Assistant ini lalu tempelkan token yang Anda salin. Setiap kali selesai lari pakai jam Huawei, cukup tap "Tarik Lari Terbaru"!',
                      actionButton: CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        color: const Color(0xFF007AFF),
                        borderRadius: BorderRadius.circular(10),
                        onPressed: onOpenStravaModal,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.link_rounded, size: 14, color: CupertinoColors.white),
                            SizedBox(width: 6),
                            Text(
                              'Buka Form Tautkan Strava',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: CupertinoColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlowNode({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.none,
            color: AppleColors.label(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required String title,
    required String description,
    required Widget actionButton,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppleColors.cardBg(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppleColors.separator(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFF007AFF),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  stepNumber,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.none,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                    color: AppleColors.label(isDark),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              decoration: TextDecoration.none,
              color: AppleColors.secondaryLabel(isDark),
            ),
          ),
          const SizedBox(height: 10),
          actionButton,
        ],
      ),
    );
  }
}

class _EditPersonalBestModalSheet extends StatefulWidget {
  final DashboardState state;
  final PersonalBest personalBest;

  const _EditPersonalBestModalSheet({
    required this.state,
    required this.personalBest,
  });

  @override
  State<_EditPersonalBestModalSheet> createState() => _EditPersonalBestModalSheetState();
}

class _EditPersonalBestModalSheetState extends State<_EditPersonalBestModalSheet> {
  late final TextEditingController _timeController;
  late final TextEditingController _paceController;
  late final TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _timeController = TextEditingController(
      text: widget.personalBest.time == '--:--' ? '' : widget.personalBest.time,
    );
    _paceController = TextEditingController(
      text: widget.personalBest.pace == '-- /km'
          ? ''
          : widget.personalBest.pace.replaceAll(' /km', ''),
    );
    _dateController = TextEditingController(
      text: widget.personalBest.dateStr == '-' ? '' : widget.personalBest.dateStr,
    );
  }

  @override
  void dispose() {
    _timeController.dispose();
    _paceController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _save() {
    final time = _timeController.text.trim();
    String pace = _paceController.text.trim();
    final date = _dateController.text.trim();

    if (pace.isNotEmpty && !pace.contains('/km')) {
      pace = '$pace /km';
    }

    final updated = PersonalBest(
      distanceLabel: widget.personalBest.distanceLabel,
      time: time.isEmpty ? '--:--' : time,
      pace: pace.isEmpty ? '-- /km' : pace,
      dateStr: date.isEmpty ? '-' : date,
    );

    widget.state.updatePersonalBest(updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final screenHeight = MediaQuery.of(context).size.height;
    final targetHeight = (screenHeight * 0.82).clamp(280.0, screenHeight - viewInsets.bottom - 44);

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: Material(
        type: MaterialType.transparency,
        child: DefaultTextStyle(
          style: TextStyle(
            fontFamily: '.SF Pro Display',
            decoration: TextDecoration.none,
            color: AppleColors.label(isDark),
            fontSize: 14,
          ),
          child: Container(
            height: targetHeight,
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
                        'Edit PB: ${widget.personalBest.distanceLabel}',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.none,
                          color: AppleColors.label(isDark),
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _save,
                        child: const Text(
                          'Simpan',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF9500)),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                Expanded(
                  child: ListView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildFieldLabel('Waktu Tempuh (Contoh: 24:12 atau 1:58:30)', isDark),
                      CupertinoTextField(
                        controller: _timeController,
                        placeholder: 'Contoh: 24:12',
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: _inputDecoration(isDark),
                        style: TextStyle(color: AppleColors.label(isDark)),
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLabel('Pace Rata-Rata (Contoh: 4:50)', isDark),
                      CupertinoTextField(
                        controller: _paceController,
                        placeholder: 'Contoh: 4:50',
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: _inputDecoration(isDark),
                        style: TextStyle(color: AppleColors.label(isDark)),
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLabel('Tanggal / Event / Lokasi (Opsional)', isDark),
                      CupertinoTextField(
                        controller: _dateController,
                        placeholder: 'Contoh: Jan 2026 (GBK) atau Maybank Marathon',
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: _inputDecoration(isDark),
                        style: TextStyle(color: AppleColors.label(isDark)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
          decoration: TextDecoration.none,
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
