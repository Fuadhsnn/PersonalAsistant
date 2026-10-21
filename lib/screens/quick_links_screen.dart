import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/shortcut_item.dart';
import '../state/dashboard_state.dart';
import '../theme/apple_colors.dart';
import '../widgets/apple_burger_icon.dart';

class QuickLinksScreen extends StatelessWidget {
  final DashboardState state;
  final VoidCallback onOpenDrawer;
  final VoidCallback onBackToHome;

  const QuickLinksScreen({
    super.key,
    required this.state,
    required this.onOpenDrawer,
    required this.onBackToHome,
  });

  Future<void> _launch(BuildContext context, String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Fallback
    }
  }

  void _openAddShortcutSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _AddShortcutModalSheet(state: state),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = state.isDarkMode;
    final shortcuts = state.shortcuts;

    return CustomScrollView(
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
                  onPressed: () => _openAddShortcutSheet(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppleColors.systemBlue,
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
                Text(
                  'Pintasan Safari',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppleColors.label(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Akses cepat 1-tap ke portal karir, tools coding, & situs favorit',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppleColors.secondaryLabel(isDark),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Favorites Grid
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 14,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = shortcuts[index];
                return _buildShortcutAppIcon(context, item, isDark);
              },
              childCount: shortcuts.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 48)),
      ],
    );
  }

  Widget _buildShortcutAppIcon(BuildContext context, ShortcutItem item, bool isDark) {
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
      onTap: () => _launch(context, item.url),
      onLongPress: () {
        showCupertinoModalPopup(
          context: context,
          builder: (ctx) => CupertinoActionSheet(
            title: Text(item.title),
            message: Text(item.url),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(ctx);
                  _launch(context, item.url);
                },
                child: const Text('Buka di Browser'),
              ),
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.pop(ctx);
                  state.deleteShortcut(item.id);
                },
                child: const Text('Hapus Pintasan'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // iOS Squircle Icon
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Color(item.colorValue),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Color(item.colorValue).withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(
              iconData,
              size: 32,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppleColors.label(isDark),
            ),
          ),
          Text(
            item.category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: AppleColors.secondaryLabel(isDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddShortcutModalSheet extends StatefulWidget {
  final DashboardState state;

  const _AddShortcutModalSheet({required this.state});

  @override
  State<_AddShortcutModalSheet> createState() => _AddShortcutModalSheetState();
}

class _AddShortcutModalSheetState extends State<_AddShortcutModalSheet> {
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  String _category = 'Karir';
  String _iconCode = 'globe';
  int _selectedColor = 0xFF007AFF;

  final List<int> _colors = [
    0xFF007AFF, // Blue
    0xFF0A66C2, // LinkedIn Blue
    0xFF24292E, // GitHub Dark
    0xFFFC4C02, // Strava Orange
    0xFF10A37F, // OpenAI Green
    0xFFFF0000, // YouTube Red
    0xFFFF9500, // System Orange
    0xFF5856D6, // Indigo
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    String url = _urlController.text.trim();
    if (title.isEmpty || url.isEmpty) return;

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final item = ShortcutItem(
      id: 'sc_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      url: url,
      category: _category,
      iconCode: _iconCode,
      colorValue: _selectedColor,
    );

    widget.state.addShortcut(item);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;

    return Material(
      type: MaterialType.transparency,
      child: DefaultTextStyle(
        style: TextStyle(
          decoration: TextDecoration.none,
          color: AppleColors.label(isDark),
          fontSize: 14,
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
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
                      'Tambah Pintasan Baru',
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
                    _buildFieldLabel('Judul Pintasan *', isDark),
                    CupertinoTextField(
                      controller: _titleController,
                      placeholder: 'Contoh: Portal Mandiri Career, Kaggle, Duolingo',
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: _inputDecoration(isDark),
                      style: TextStyle(color: AppleColors.label(isDark)),
                    ),
                    const SizedBox(height: 16),

                    _buildFieldLabel('URL Web *', isDark),
                    CupertinoTextField(
                      controller: _urlController,
                      placeholder: 'Contoh: mandiri.co.id/career',
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: _inputDecoration(isDark),
                      style: TextStyle(color: AppleColors.label(isDark)),
                    ),
                    const SizedBox(height: 16),

                    _buildFieldLabel('Kategori & Icon', isDark),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoSlidingSegmentedControl<String>(
                        groupValue: _iconCode,
                        backgroundColor: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFE5E5EA),
                        thumbColor: isDark ? const Color(0xFF2C2C2E) : CupertinoColors.white,
                        children: {
                          'briefcase': Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Karir',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                                color: AppleColors.label(isDark),
                              ),
                            ),
                          ),
                          'code': Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Code',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                                color: AppleColors.label(isDark),
                              ),
                            ),
                          ),
                          'run': Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Lari',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                                color: AppleColors.label(isDark),
                              ),
                            ),
                          ),
                          'ai': Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'AI',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                                color: AppleColors.label(isDark),
                              ),
                            ),
                          ),
                          'globe': Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Web',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                                color: AppleColors.label(isDark),
                              ),
                            ),
                          ),
                        },
                        onValueChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _iconCode = val;
                              switch (val) {
                                case 'briefcase':
                                  _category = 'Karir';
                                  break;
                                case 'code':
                                  _category = 'Code';
                                  break;
                                case 'run':
                                  _category = 'Running';
                                  break;
                                case 'ai':
                                  _category = 'AI';
                                  break;
                                default:
                                  _category = 'Umum';
                              }
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildFieldLabel('Pilih Warna Ikon', isDark),
                    Row(
                      children: _colors.map((c) {
                        final isSel = _selectedColor == c;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = c),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
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
