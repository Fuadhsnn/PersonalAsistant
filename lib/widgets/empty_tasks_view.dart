import 'package:flutter/cupertino.dart';
import '../theme/apple_colors.dart';

class EmptyTasksView extends StatelessWidget {
  final bool isCompletedFilter;
  final bool isDark;
  final VoidCallback onAddTask;

  const EmptyTasksView({
    super.key,
    required this.isCompletedFilter,
    required this.isDark,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark ? AppleColors.darkCardSecondary : const Color(0xFFE5E5EA),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompletedFilter
                    ? CupertinoIcons.checkmark_shield_fill
                    : CupertinoIcons.tray,
                size: 30,
                color: AppleColors.textSecondary(isDark),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isCompletedFilter
                  ? 'Belum ada tugas yang selesai'
                  : 'Tidak ada tugas yang perlu dikerjakan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppleColors.textPrimary(isDark),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isCompletedFilter
                  ? 'Tugas yang telah Anda selesaikan akan muncul di sini.'
                  : 'Nikmati waktu luang Anda atau buat rencana baru.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppleColors.textSecondary(isDark),
              ),
            ),
            if (!isCompletedFilter) ...[
              const SizedBox(height: 18),
              CupertinoButton.filled(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                borderRadius: BorderRadius.circular(20),
                onPressed: onAddTask,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.plus, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Tambah Tugas Baru',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
