import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../theme/apple_colors.dart';

class AppleHeader extends StatelessWidget {
  final String userName;
  final bool isDark;
  final VoidCallback onOpenSettings;
  final VoidCallback onAddTask;
  final ValueChanged<String> onSearchChanged;

  const AppleHeader({
    super.key,
    required this.userName,
    required this.isDark,
    required this.onOpenSettings,
    required this.onAddTask,
    required this.onSearchChanged,
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
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM', 'id_ID').format(now).toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top action icons & Date
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              dateStr,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: AppleColors.textSecondary(isDark),
              ),
            ),
            Row(
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  onPressed: onOpenSettings,
                  child: Container(
                    width: 36,
                    height: 36,
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
                      size: 18,
                      color: AppleColors.textPrimary(isDark),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  onPressed: onAddTask,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppleColors.systemBlue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x40007AFF),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.plus,
                      size: 20,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 4),

        // Large Greeting (Apple iOS Large Title style)
        Text(
          '${_getGreeting()}, $userName',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            color: AppleColors.textPrimary(isDark),
          ),
        ),

        const SizedBox(height: 14),

        // Cupertino Search Bar
        CupertinoSearchTextField(
          placeholder: 'Cari tugas atau catatan...',
          placeholderStyle: TextStyle(
            color: AppleColors.textTertiary(isDark),
            fontSize: 14,
          ),
          style: TextStyle(
            color: AppleColors.textPrimary(isDark),
            fontSize: 14,
          ),
          backgroundColor: AppleColors.card(isDark),
          borderRadius: BorderRadius.circular(14),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          onChanged: onSearchChanged,
        ),
      ],
    );
  }
}
