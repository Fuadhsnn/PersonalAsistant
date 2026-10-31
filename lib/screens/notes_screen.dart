import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../state/dashboard_state.dart';
import '../theme/apple_colors.dart';
import '../widgets/tactile_top_bar.dart';

class NotesScreen extends StatefulWidget {
  final DashboardState state;
  final VoidCallback onOpenDrawer;
  final VoidCallback onBackToHome;

  const NotesScreen({
    super.key,
    required this.state,
    required this.onOpenDrawer,
    required this.onBackToHome,
  });

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late TextEditingController _controller;
  String? _statusNotice;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.quickNote);
  }

  @override
  void didUpdateWidget(covariant NotesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.quickNote != oldWidget.state.quickNote &&
        _controller.text != widget.state.quickNote) {
      _controller.text = widget.state.quickNote;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _controller.text));
    setState(() => _statusNotice = 'Catatan disalin ke clipboard!');
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _statusNotice = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Top Bar (Option B: iOS Large Title Standard)
              TactileTopBar(
                title: 'Catatan Cepat',
                subtitle: 'Tersimpan otomatis ke memori lokal iPhone Anda.',
                useLargeTitle: true,
                onOpenDrawer: widget.onOpenDrawer,
                isDark: isDark,
                rightAction: TactileTopBar.actionButton(
                  icon: const Icon(
                    CupertinoIcons.doc_on_clipboard,
                    size: 19,
                    color: AppleColors.systemYellow,
                  ),
                  onPressed: _copyToClipboard,
                  isDark: isDark,
                ),
              ),
              const SizedBox(height: 16),

              if (_statusNotice != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppleColors.systemGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.checkmark_circle_fill,
                          color: AppleColors.systemGreen, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _statusNotice!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppleColors.systemGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Notes Sheet Container ala Apple Notes
              Container(
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
                child: CupertinoTextField(
                  controller: _controller,
                  placeholder: 'Mulai mengetik catatan kuliah, rumus, draft pesan, atau ide di sini...',
                  placeholderStyle: TextStyle(
                    fontSize: 15,
                    color: AppleColors.textTertiary(isDark),
                  ),
                  style: TextStyle(
                    fontSize: 15,
                    color: AppleColors.textPrimary(isDark),
                    height: 1.5,
                  ),
                  maxLines: 15,
                  padding: EdgeInsets.zero,
                  decoration: null,
                  onChanged: (text) => widget.state.setQuickNote(text),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}
