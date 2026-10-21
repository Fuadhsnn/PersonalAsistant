import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../models/task_item.dart';
import '../theme/apple_colors.dart';

class TaskListTile extends StatelessWidget {
  final TaskItem task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final bool isDark;

  const TaskListTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
    required this.isDark,
  });

  String _formatDueDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDay = DateTime(date.year, date.month, date.day);

    final timeStr = DateFormat('HH:mm').format(date);

    if (taskDay == today) {
      return 'Hari ini $timeStr';
    } else if (taskDay == today.add(const Duration(days: 1))) {
      return 'Besok $timeStr';
    } else if (taskDay == today.subtract(const Duration(days: 1))) {
      return 'Kemarin $timeStr';
    } else {
      return DateFormat('d MMM', 'id_ID').format(date);
    }
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'Kuliah':
        return AppleColors.systemBlue;
      case 'Project':
        return AppleColors.systemIndigo;
      case 'Pribadi':
        return AppleColors.systemGreen;
      case 'Mendesak':
        return AppleColors.systemRed;
      default:
        return AppleColors.systemOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dueDateText = _formatDueDate(task.dueDate);
    final isOverdue = !task.isCompleted &&
        task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now());

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppleColors.systemRed,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          CupertinoIcons.trash_fill,
          color: CupertinoColors.white,
          size: 22,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppleColors.card(isDark),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isDark ? const Color(0x22000000) : const Color(0x06000000),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isDark ? const Color(0x1AFFFFFF) : const Color(0x0A000000),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circular iOS Checkbox
            CupertinoButton(
              padding: const EdgeInsets.only(top: 2, right: 10),
              minimumSize: Size.zero,
              onPressed: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted
                      ? AppleColors.systemBlue
                      : CupertinoColors.transparent,
                  border: Border.all(
                    color: task.isCompleted
                        ? AppleColors.systemBlue
                        : (isDark
                            ? AppleColors.darkTextTertiary
                            : const Color(0xFFC7C7CC)),
                    width: 2,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(
                        CupertinoIcons.checkmark,
                        size: 14,
                        color: CupertinoColors.white,
                      )
                    : null,
              ),
            ),

            // Content
            Expanded(
              child: GestureDetector(
                onTap: onEdit,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + Priority flag
                    Row(
                      children: [
                        if (task.priority != TaskPriority.low) ...[
                          Text(
                            task.priority.symbol,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: task.priority == TaskPriority.high
                                  ? AppleColors.systemRed
                                  : AppleColors.systemOrange,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: task.isCompleted
                                  ? AppleColors.textSecondary(isDark)
                                  : AppleColors.textPrimary(isDark),
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (task.notes != null && task.notes!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        task.notes!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppleColors.textSecondary(isDark),
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Badges (Category & Due Date)
                    Row(
                      children: [
                        // Category Chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(task.category)
                                .withValues(alpha: isDark ? 0.25 : 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            task.category,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _getCategoryColor(task.category),
                            ),
                          ),
                        ),

                        if (dueDateText.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.clock,
                                size: 12,
                                color: isOverdue
                                    ? AppleColors.systemRed
                                    : AppleColors.textSecondary(isDark),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                dueDateText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isOverdue
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isOverdue
                                      ? AppleColors.systemRed
                                      : AppleColors.textSecondary(isDark),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // More Options (Edit / Delete)
            CupertinoButton(
              padding: const EdgeInsets.only(left: 8),
              minimumSize: Size.zero,
              onPressed: onEdit,
              child: Icon(
                CupertinoIcons.ellipsis_circle,
                size: 20,
                color: AppleColors.textSecondary(isDark).withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
