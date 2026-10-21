import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'models/task_item.dart';
import 'screens/home_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/todo_screen.dart';
import 'state/dashboard_state.dart';
import 'theme/apple_colors.dart';
import 'theme/apple_theme.dart';
import 'widgets/add_task_sheet.dart';
import 'widgets/apple_drawer.dart';
import 'widgets/settings_sheet.dart';

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
            child: MainAppShell(state: _dashboardState),
          ),
        );
      },
    );
  }
}

class MainAppShell extends StatefulWidget {
  final DashboardState state;

  const MainAppShell({super.key, required this.state});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openAddTaskModal(BuildContext context, {TaskItem? existing}) {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AddTaskSheet(
        initialTask: existing,
        isDark: widget.state.isDarkMode,
        onSave: (task) {
          if (existing != null) {
            widget.state.updateTask(task);
          } else {
            widget.state.addTask(task);
          }
        },
        onDelete: existing != null ? () => widget.state.deleteTask(existing.id) : null,
      ),
    );
  }

  void _openSettingsModal(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => SettingsSheet(state: widget.state),
    );
  }

  Widget _buildActiveFeatureView() {
    switch (widget.state.currentFeature) {
      case AppFeature.home:
        return HomeScreen(
          state: widget.state,
          onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
          onOpenSettings: () => _openSettingsModal(context),
          onOpenAddTask: (task) => _openAddTaskModal(context, existing: task),
        );

      case AppFeature.todo:
        return TodoScreen(
          state: widget.state,
          onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
          onBackToHome: () => widget.state.setFeature(AppFeature.home),
          onOpenAddTask: (task) => _openAddTaskModal(context, existing: task),
        );

      case AppFeature.notes:
        return NotesScreen(
          state: widget.state,
          onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
          onBackToHome: () => widget.state.setFeature(AppFeature.home),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppleColors.bg(isDark),
      drawer: AppleDrawer(
        state: widget.state,
        onOpenSettings: () => _openSettingsModal(context),
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: widget.state.isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildActiveFeatureView(),
                  ),
          ),
        ),
      ),
    );
  }
}
