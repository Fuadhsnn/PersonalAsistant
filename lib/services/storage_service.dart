import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_item.dart';

class StorageService {
  static const String _tasksKey = 'hasan_dashboard_tasks_v1';
  static const String _userNameKey = 'hasan_dashboard_user_name';
  static const String _themeDarkKey = 'hasan_dashboard_theme_dark';
  static const String _quickNoteKey = 'hasan_dashboard_quick_note';

  Future<List<TaskItem>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_tasksKey);

    if (jsonString == null || jsonString.isEmpty) {
      // First time launch - Seed with helpful starter tasks
      final initialTasks = _getSampleTasks();
      await saveTasks(initialTasks);
      return initialTasks;
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.map((item) => TaskItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return _getSampleTasks();
    }
  }

  Future<void> saveTasks(List<TaskItem> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = tasks.map((task) => task.toJson()).toList();
    await prefs.setString(_tasksKey, jsonEncode(jsonList));
  }

  Future<String> exportBackupJson() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString(_tasksKey) ?? '[]';
    final userName = prefs.getString(_userNameKey) ?? 'Hasan';
    
    final backupData = {
      'app': 'Personal Assistant',
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'userName': userName,
      'tasks': jsonDecode(tasksJson),
    };

    return const JsonEncoder.withIndent('  ').convert(backupData);
  }

  Future<List<TaskItem>?> importBackupJson(String rawJson) async {
    try {
      final Map<String, dynamic> parsed = jsonDecode(rawJson) as Map<String, dynamic>;
      if (!parsed.containsKey('tasks')) return null;
      
      final List<dynamic> taskList = parsed['tasks'] as List<dynamic>;
      final importedTasks = taskList.map((e) => TaskItem.fromJson(e as Map<String, dynamic>)).toList();
      await saveTasks(importedTasks);

      if (parsed.containsKey('userName')) {
        await saveUserName(parsed['userName'] as String);
      }
      return importedTasks;
    } catch (_) {
      return null;
    }
  }

  Future<String> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'Hasan';
  }

  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  Future<bool?> loadIsDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeDarkKey);
  }

  Future<void> saveIsDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeDarkKey, isDark);
  }

  Future<String> loadQuickNote() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_quickNoteKey) ?? '💡 Catatan Cepat:\n- Siapkan bahan presentasi kuliah\n- Ide fitur baru: habit tracker & pomodoro';
  }

  Future<void> saveQuickNote(String note) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_quickNoteKey, note);
  }

  List<TaskItem> _getSampleTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 18, 0);

    return [
      TaskItem(
        id: '1',
        title: 'Review materi kuliah & tugas mingguan',
        notes: 'Cek portal kampus untuk deadline semester',
        dueDate: today,
        priority: TaskPriority.high,
        category: 'Kuliah',
        isCompleted: false,
      ),
      TaskItem(
        id: '2',
        title: 'Setup deployment Vercel untuk Personal Assistant',
        notes: 'Konfigurasi PWA dan uji coba di Safari iPhone 13',
        dueDate: today,
        priority: TaskPriority.high,
        category: 'Project',
        isCompleted: true,
        completedAt: now,
      ),
      TaskItem(
        id: '3',
        title: 'Workout sore / Lari santai 30 menit',
        notes: 'Target 3 km di sekitar kampus',
        dueDate: today,
        priority: TaskPriority.medium,
        category: 'Pribadi',
        isCompleted: false,
      ),
      TaskItem(
        id: '4',
        title: 'Eksplorasi integrasi widget baru ke dashboard',
        notes: 'Siapkan modul Habit Tracker & Quick Notes',
        dueDate: today.add(const Duration(days: 2)),
        priority: TaskPriority.low,
        category: 'Project',
        isCompleted: false,
      ),
    ];
  }
}
