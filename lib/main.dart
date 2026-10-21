import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'models/task_item.dart';
import 'state/dashboard_state.dart';
import 'theme/apple_colors.dart';
import 'theme/apple_theme.dart';
import 'widgets/activity_rings_card.dart';
import 'widgets/add_task_sheet.dart';
import 'widgets/apple_header.dart';
import 'widgets/category_pills.dart';
import 'widgets/empty_tasks_view.dart';
import 'widgets/reminder_summary_grid.dart';
import 'widgets/settings_sheet.dart';
import 'widgets/task_list_tile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const PersonalAssistantApp());
}

class PersonalAssistantApp extends StatefulWidget {
  const PersonalAssistantApp({super.key});

  @override
  State<PersonalAssistantApp> createState() => _PersonalAssistantAppState();
}

class _PersonalAssistantAppState extends State<PersonalAssistantApp> {
  final DashboardState _dashboardState = DashboardState();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _dashboardState,
      builder: (context, _) {
        final isDark = _dashboardState.isDarkMode;

        return MaterialApp(
          title: 'Personal Assistant',
          debugShowCheckedModeBanner: false,
          theme: AppleTheme.materialTheme(isDark),
          home: CupertinoTheme(
            data: AppleTheme.cupertinoTheme(isDark),
            child: DashboardScreen(state: _dashboardState),
          ),
        );
      },
    );
  }
}

class DashboardScreen extends StatelessWidget {
  final DashboardState state;

  const DashboardScreen({super.key, required this.state});

  void _openAddTaskModal(BuildContext context, {TaskItem? existing}) {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AddTaskSheet(
        initialTask: existing,
        isDark: state.isDarkMode,
        onSave: (task) {
          if (existing != null) {
            state.updateTask(task);
          } else {
            state.addTask(task);
          }
        },
        onDelete: existing != null ? () => state.deleteTask(existing.id) : null,
      ),
    );
  }

  void _openSettingsModal(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => SettingsSheet(state: state),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = state.isDarkMode;
    final filteredTasks = state.filteredTasks;

    return Scaffold(
      backgroundColor: AppleColors.bg(isDark),
      body: SafeArea(
        top: true,
        bottom: true,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: state.isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Header & Widgets
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // Apple Header (Greeting & Search)
                            AppleHeader(
                              userName: state.userName,
                              isDark: isDark,
                              onOpenSettings: () => _openSettingsModal(context),
                              onAddTask: () => _openAddTaskModal(context),
                              onSearchChanged: state.setSearchQuery,
                            ),
                            const SizedBox(height: 18),

                            // Apple Fitness/Watch Concentric Rings
                            ActivityRingsCard(
                              todayProgress: state.todayProgress,
                              highPriorityProgress: state.highPriorityProgress,
                              overallProgress: state.overallProgress,
                              todayCount: state.todayCount,
                              completedToday: state.completedCount,
                              isDark: isDark,
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

                            // Task Section Header
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 3),
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

                      // Task List or Empty State
                      if (filteredTasks.isEmpty)
                        SliverToBoxAdapter(
                          child: EmptyTasksView(
                            isCompletedFilter:
                                state.selectedFilter == TaskFilter.completed,
                            isDark: isDark,
                            onAddTask: () => _openAddTaskModal(context),
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
                                  onEdit: () => _openAddTaskModal(context,
                                      existing: task),
                                );
                              },
                              childCount: filteredTasks.length,
                            ),
                          ),
                        ),

                      // Extra spacing at the bottom for smooth iPhone scrolling
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 40),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
