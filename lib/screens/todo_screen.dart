import 'package:flutter/cupertino.dart';
import '../models/task_item.dart';
import '../state/dashboard_state.dart';
import '../theme/apple_colors.dart';
import '../widgets/category_pills.dart';
import '../widgets/empty_tasks_view.dart';
import '../widgets/reminder_summary_grid.dart';
import '../widgets/task_list_tile.dart';

class TodoScreen extends StatelessWidget {
  final DashboardState state;
  final VoidCallback onOpenDrawer;
  final VoidCallback onBackToHome;
  final Function(TaskItem?) onOpenAddTask;

  const TodoScreen({
    super.key,
    required this.state,
    required this.onOpenDrawer,
    required this.onBackToHome,
    required this.onOpenAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = state.isDarkMode;
    final filteredTasks = state.filteredTasks;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Top Bar with Burger Menu, Back to Home, and Add Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        onPressed: onOpenDrawer,
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
                          child: Icon(
                            CupertinoIcons.bars,
                            size: 20,
                            color: AppleColors.textPrimary(isDark),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        onPressed: onBackToHome,
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

                  // Add Task (+) button
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    onPressed: () => onOpenAddTask(null),
                    child: Container(
                      width: 40,
                      height: 40,
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
                        size: 22,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Screen Title
              Text(
                'To-Do & Pengingat',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: AppleColors.textPrimary(isDark),
                ),
              ),
              const SizedBox(height: 14),

              // Search Box
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
                onChanged: state.setSearchQuery,
              ),
              const SizedBox(height: 18),

              // 4 Smart Reminder Cards
              ReminderSummaryGrid(
                todayCount: state.todayCount,
                scheduledCount: state.scheduledCount,
                allCount: state.allCount,
                completedCount: state.completedCount,
                currentFilter: state.selectedFilter,
                onSelectFilter: state.setFilter,
                isDark: isDark,
              ),
              const SizedBox(height: 18),

              // Category Pills
              CategoryPills(
                selectedCategory: state.selectedCategory,
                onSelectCategory: state.setCategory,
                isDark: isDark,
              ),
              const SizedBox(height: 20),

              // Task List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.selectedFilter.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: AppleColors.textPrimary(isDark),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppleColors.card(isDark),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${filteredTasks.length} tugas',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppleColors.textSecondary(isDark),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ]),
          ),
        ),

        // List of tasks
        if (filteredTasks.isEmpty)
          SliverToBoxAdapter(
            child: EmptyTasksView(
              isCompletedFilter: state.selectedFilter == TaskFilter.completed,
              isDark: isDark,
              onAddTask: () => onOpenAddTask(null),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final task = filteredTasks[index];
                  return TaskListTile(
                    task: task,
                    isDark: isDark,
                    onToggle: () => state.toggleTask(task.id),
                    onDelete: () => state.deleteTask(task.id),
                    onEdit: () => onOpenAddTask(task),
                  );
                },
                childCount: filteredTasks.length,
              ),
            ),
          ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 40),
        ),
      ],
    );
  }
}
