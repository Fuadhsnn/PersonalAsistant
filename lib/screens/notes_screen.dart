import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../state/dashboard_state.dart';
import '../theme/apple_colors.dart';
import '../widgets/apple_burger_icon.dart';

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
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        onPressed: widget.onOpenDrawer,
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
                      const SizedBox(width: 8),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        onPressed: widget.onBackToHome,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppleColors.card(isDark),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            children: [
                              Icon(CupertinoIcons.chevron_back, size: 16, color: AppleColors.systemBlue),
                              SizedBox(width: 2),
                              Text(
                                'Beranda',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppleColors.systemBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    onPressed: _copyToClipboard,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppleColors.card(isDark),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.doc_on_clipboard,
                        size: 19,
                        color: AppleColors.systemYellow,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                'Catatan Cepat',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: AppleColors.textPrimary(isDark),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tersimpan otomatis ke memori lokal iPhone Anda.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppleColors.textSecondary(isDark),
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
