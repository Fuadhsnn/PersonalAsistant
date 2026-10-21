import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../state/dashboard_state.dart';
import '../theme/apple_colors.dart';

class SettingsSheet extends StatefulWidget {
  final DashboardState state;

  const SettingsSheet({super.key, required this.state});

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late TextEditingController _nameController;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.state.userName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleExport() async {
    final jsonStr = await widget.state.exportBackup();
    await Clipboard.setData(ClipboardData(text: jsonStr));
    setState(() {
      _statusMessage = 'Cadangan JSON disalin ke clipboard! Siap disimpan di Apple Notes / Files.';
    });
  }

  void _showImportDialog() {
    final textController = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Impor Cadangan'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: textController,
            placeholder: 'Tempel teks JSON cadangan di sini...',
            maxLines: 5,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Impor'),
            onPressed: () async {
              final text = textController.text.trim();
              Navigator.of(ctx).pop();
              if (text.isNotEmpty) {
                final success = await widget.state.importBackup(text);
                if (!mounted) return;
                setState(() {
                  _statusMessage = success
                      ? 'Berhasil memulihkan cadangan tugas!'
                      : 'Format JSON tidak valid.';
                });
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmClearAllData() {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Kosongkan Semua Data?'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'Semua data tugas, lamaran, kalori, kebiasaan, sepatu, riwayat lari, keuangan, dan catatan akan dikosongkan bersih. Tindakan ini tidak dapat dibatalkan.',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Kosongkan Semua'),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await widget.state.clearAllData();
              if (!mounted) return;
              setState(() {
                _statusMessage = 'Semua data dummy telah berhasil dikosongkan!';
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight - viewInsets.bottom - 44;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: Material(
        type: MaterialType.transparency,
        child: DefaultTextStyle(
          style: TextStyle(
            decoration: TextDecoration.none,
            color: AppleColors.textPrimary(isDark),
            fontSize: 14,
          ),
          child: Container(
            constraints: BoxConstraints(maxHeight: maxHeight),
            decoration: BoxDecoration(
              color: AppleColors.card(isDark),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.only(
              top: 16,
              left: 20,
              right: 20,
              bottom: 24,
            ),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF48484A) : const Color(0xFFD1D1D6),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                Text(
                  'Pengaturan & Cadangan',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppleColors.textPrimary(isDark),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Text('Selesai', style: TextStyle(fontWeight: FontWeight.w600)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_statusMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppleColors.systemGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.checkmark_circle_fill,
                        color: AppleColors.systemGreen, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _statusMessage!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppleColors.systemGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Section 1: Profil & Tampilan
            _buildSectionHeader('PROFIL & TAMPILAN', isDark),
            Container(
              decoration: BoxDecoration(
                color: AppleColors.cardSecondary(isDark),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.account_circle_rounded,
                            color: AppleColors.systemBlue, size: 22),
                        const SizedBox(width: 12),
                        Text('Nama Panggilan',
                            style: TextStyle(
                                fontSize: 15, color: AppleColors.textPrimary(isDark))),
                        const Spacer(),
                        SizedBox(
                          width: 110,
                          child: CupertinoTextField(
                            controller: _nameController,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppleColors.textPrimary(isDark)),
                            decoration: null,
                            onSubmitted: (val) => widget.state.setUserName(val),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 1, color: AppleColors.separator(isDark)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.moon_fill,
                            color: AppleColors.systemIndigo, size: 22),
                        const SizedBox(width: 12),
                        Text('Mode Gelap (OLED Black)',
                            style: TextStyle(
                                fontSize: 15, color: AppleColors.textPrimary(isDark))),
                        const Spacer(),
                        CupertinoSwitch(
                          value: isDark,
                          activeTrackColor: AppleColors.systemBlue,
                          onChanged: (_) => widget.state.toggleDarkMode(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 2: Cadangan Data (iPhone Local Storage)
            _buildSectionHeader('CADANGAN & SINKRONISASI IPHONE', isDark),
            Container(
              decoration: BoxDecoration(
                color: AppleColors.cardSecondary(isDark),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    onPressed: _handleExport,
                    child: Row(
                      children: [
                        const Icon(Icons.file_upload_outlined,
                            color: AppleColors.systemBlue, size: 22),
                        const SizedBox(width: 12),
                        Text('Ekspor Cadangan (JSON)',
                            style: TextStyle(
                                fontSize: 15, color: AppleColors.textPrimary(isDark))),
                        const Spacer(),
                        Icon(CupertinoIcons.chevron_forward,
                            size: 16, color: AppleColors.textTertiary(isDark)),
                      ],
                    ),
                  ),
                  Container(height: 1, color: AppleColors.separator(isDark)),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    onPressed: _showImportDialog,
                    child: Row(
                      children: [
                        const Icon(Icons.file_download_outlined,
                            color: AppleColors.systemOrange, size: 22),
                        const SizedBox(width: 12),
                        Text('Pulihkan Cadangan (Impor JSON)',
                            style: TextStyle(
                                fontSize: 15, color: AppleColors.textPrimary(isDark))),
                        const Spacer(),
                        Icon(CupertinoIcons.chevron_forward,
                            size: 16, color: AppleColors.textTertiary(isDark)),
                      ],
                    ),
                  ),
                  Container(height: 1, color: AppleColors.separator(isDark)),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    onPressed: () {
                      widget.state.clearCompletedTasks();
                      setState(() {
                        _statusMessage = 'Daftar tugas selesai telah dibersihkan.';
                      });
                    },
                    child: const Row(
                      children: [
                        Icon(CupertinoIcons.clear_circled,
                            color: AppleColors.systemRed, size: 22),
                        SizedBox(width: 12),
                        Text('Bersihkan Tugas yang Sudah Selesai',
                            style: TextStyle(fontSize: 15, color: AppleColors.systemRed)),
                      ],
                    ),
                  ),
                  Container(height: 1, color: AppleColors.separator(isDark)),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    onPressed: _confirmClearAllData,
                    child: const Row(
                      children: [
                        Icon(CupertinoIcons.trash,
                            color: AppleColors.systemRed, size: 22),
                        SizedBox(width: 12),
                        Text('Kosongkan Semua Data (Hapus Dummy)',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppleColors.systemRed)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 3: Info PWA & Vercel
            _buildSectionHeader('TENTANG & DEPLOYMENT', isDark),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppleColors.cardSecondary(isDark),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(CupertinoIcons.device_phone_portrait,
                          color: AppleColors.systemBlue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Dioptimasi untuk iPhone 13 Safari',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppleColors.textPrimary(isDark),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pilih "Add to Home Screen" di Safari untuk menjalankan dashboard dalam mode layar penuh tanpa navigasi browser.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppleColors.textSecondary(isDark),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Siap dideploy ke Vercel dengan konfigurasi static routing otomatis.',
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
    ),
  ),
),
);
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppleColors.textSecondary(isDark),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
