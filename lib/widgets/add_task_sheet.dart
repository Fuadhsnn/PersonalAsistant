import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../models/task_item.dart';
import '../theme/apple_colors.dart';

class AddTaskSheet extends StatefulWidget {
  final TaskItem? initialTask;
  final Function(TaskItem) onSave;
  final VoidCallback? onDelete;
  final bool isDark;

  const AddTaskSheet({
    super.key,
    this.initialTask,
    required this.onSave,
    this.onDelete,
    required this.isDark,
  });

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late TaskPriority _priority;
  late String _category;
  DateTime? _dueDate;

  final List<String> _categories = ['Kuliah', 'Project', 'Pribadi', 'Umum'];

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _notesController = TextEditingController(text: task?.notes ?? '');
    _priority = task?.priority ?? TaskPriority.medium;
    _category = task?.category ?? 'Kuliah';
    _dueDate = task?.dueDate ?? DateTime.now().add(const Duration(hours: 4));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final task = TaskItem(
      id: widget.initialTask?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      dueDate: _dueDate,
      priority: _priority,
      category: _category,
      isCompleted: widget.initialTask?.isCompleted ?? false,
      completedAt: widget.initialTask?.completedAt,
    );

    widget.onSave(task);
    Navigator.of(context).pop();
  }

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 280,
        color: AppleColors.card(widget.isDark),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text('Selesai', style: TextStyle(fontWeight: FontWeight.w600)),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                initialDateTime: _dueDate ?? DateTime.now(),
                mode: CupertinoDatePickerMode.dateAndTime,
                use24hFormat: true,
                onDateTimeChanged: (newDate) {
                  setState(() => _dueDate = newDate);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialTask != null;
    final isDark = widget.isDark;

    return Container(
      decoration: BoxDecoration(
        color: AppleColors.card(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Drag Handle
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

            // Header Bar (Batal - Title - Simpan)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Text('Batal', style: TextStyle(color: AppleColors.systemBlue)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text(
                  isEditing ? 'Detail Tugas' : 'Tugas Baru',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppleColors.textPrimary(isDark),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _titleController.text.trim().isNotEmpty ? _submit : null,
                  child: const Text(
                    'Simpan',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppleColors.systemBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Title & Notes Card
            Container(
              decoration: BoxDecoration(
                color: AppleColors.cardSecondary(isDark),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CupertinoTextField(
                    controller: _titleController,
                    placeholder: 'Judul Tugas (misal: Selesaikan Bab 2)',
                    placeholderStyle: TextStyle(color: AppleColors.textTertiary(isDark)),
                    style: TextStyle(color: AppleColors.textPrimary(isDark), fontSize: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: null,
                    onChanged: (_) => setState(() {}),
                  ),
                  Container(
                    height: 1,
                    color: AppleColors.separator(isDark),
                  ),
                  CupertinoTextField(
                    controller: _notesController,
                    placeholder: 'Catatan tambahan...',
                    placeholderStyle: TextStyle(color: AppleColors.textTertiary(isDark)),
                    style: TextStyle(color: AppleColors.textPrimary(isDark), fontSize: 14),
                    padding: const EdgeInsets.all(14),
                    maxLines: 3,
                    decoration: null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Due Date Row
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppleColors.cardSecondary(isDark),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppleColors.systemRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(CupertinoIcons.calendar, color: AppleColors.systemRed, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jatuh Tempo',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppleColors.textPrimary(isDark),
                          ),
                        ),
                        if (_dueDate != null)
                          Text(
                            DateFormat('EEEE, d MMMM yyyy - HH:mm', 'id_ID').format(_dueDate!),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppleColors.systemBlue,
                            ),
                          ),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _showDatePicker,
                    child: const Text('Atur', style: TextStyle(color: AppleColors.systemBlue)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Priority Segmented Control
            Text(
              'PRIORITAS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppleColors.textSecondary(isDark),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<TaskPriority>(
                groupValue: _priority,
                backgroundColor: AppleColors.cardSecondary(isDark),
                thumbColor: AppleColors.card(isDark),
                children: {
                  TaskPriority.low: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Rendah (!)',
                      style: TextStyle(
                        fontSize: 13,
                        color: _priority == TaskPriority.low
                            ? AppleColors.systemBlue
                            : AppleColors.textSecondary(isDark),
                      ),
                    ),
                  ),
                  TaskPriority.medium: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Sedang (!!)',
                      style: TextStyle(
                        fontSize: 13,
                        color: _priority == TaskPriority.medium
                            ? AppleColors.systemOrange
                            : AppleColors.textSecondary(isDark),
                      ),
                    ),
                  ),
                  TaskPriority.high: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Tinggi (!!!)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _priority == TaskPriority.high
                            ? AppleColors.systemRed
                            : AppleColors.textSecondary(isDark),
                      ),
                    ),
                  ),
                },
                onValueChanged: (val) {
                  if (val != null) setState(() => _priority = val);
                },
              ),
            ),
            const SizedBox(height: 18),

            // Category Selection
            Text(
              'KATEGORI',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppleColors.textSecondary(isDark),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _category == cat;
                return CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => setState(() => _category = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppleColors.systemBlue
                          : AppleColors.cardSecondary(isDark),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? CupertinoColors.white : AppleColors.textPrimary(isDark),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            if (isEditing && widget.onDelete != null) ...[
              const SizedBox(height: 24),
              CupertinoButton(
                color: AppleColors.systemRed.withValues(alpha: 0.12),
                padding: const EdgeInsets.symmetric(vertical: 12),
                borderRadius: BorderRadius.circular(14),
                onPressed: () {
                  widget.onDelete!();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Hapus Tugas Ini',
                  style: TextStyle(
                    color: AppleColors.systemRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
