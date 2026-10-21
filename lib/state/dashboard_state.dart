import 'package:flutter/foundation.dart';
import '../models/task_item.dart';
import '../services/storage_service.dart';

enum AppFeature {
  home,
  todo,
  notes;

  String get title {
    switch (this) {
      case AppFeature.home:
        return 'Beranda';
      case AppFeature.todo:
        return 'To-Do List';
      case AppFeature.notes:
        return 'Catatan Cepat';
    }
  }
}

enum TaskFilter {
  today,
  scheduled,
  all,
  completed;

  String get title {
    switch (this) {
      case TaskFilter.today:
        return 'Hari Ini';
      case TaskFilter.scheduled:
        return 'Terjadwal';
      case TaskFilter.all:
        return 'Semua';
      case TaskFilter.completed:
        return 'Selesai';
    }
  }
}

class DashboardState extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  AppFeature _currentFeature = AppFeature.home;
  List<TaskItem> _tasks = [];
  TaskFilter _selectedFilter = TaskFilter.all;
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  String _userName = 'Hasan';
  String _quickNote = '';
  bool _isDarkMode = false;
  bool _isLoading = true;

  DashboardState() {
    _init();
  }

  // Getters
  AppFeature get currentFeature => _currentFeature;
  List<TaskItem> get tasks => _tasks;
  TaskFilter get selectedFilter => _selectedFilter;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get userName => _userName;
  String get quickNote => _quickNote;
  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    _tasks = await _storageService.loadTasks();
    _userName = await _storageService.loadUserName();
    _quickNote = await _storageService.loadQuickNote();
    final savedDark = await _storageService.loadIsDarkMode();
    if (savedDark != null) {
      _isDarkMode = savedDark;
    }

    _isLoading = false;
    notifyListeners();
  }

  void setFeature(AppFeature feature) {
    _currentFeature = feature;
    notifyListeners();
  }

  Future<void> setQuickNote(String note) async {
    _quickNote = note;
    notifyListeners();
    await _storageService.saveQuickNote(note);
  }

  // Filtered List
  List<TaskItem> get filteredTasks {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _tasks.where((task) {
      // 1. Search Query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitle = task.title.toLowerCase().contains(query);
        final matchNotes = task.notes?.toLowerCase().contains(query) ?? false;
        final matchCat = task.category.toLowerCase().contains(query);
        if (!matchTitle && !matchNotes && !matchCat) return false;
      }

      // 2. Category Filter
      if (_selectedCategory != 'Semua') {
        if (_selectedCategory == 'Mendesak') {
          if (task.priority != TaskPriority.high) return false;
        } else if (task.category != _selectedCategory) {
          return false;
        }
      }

      // 3. Reminders Filter (Today, Scheduled, All, Completed)
      switch (_selectedFilter) {
        case TaskFilter.today:
          if (task.isCompleted) return false;
          if (task.dueDate == null) return false;
          return task.dueDate!.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
              task.dueDate!.isBefore(todayEnd.add(const Duration(seconds: 1)));

        case TaskFilter.scheduled:
          if (task.isCompleted) return false;
          if (task.dueDate == null) return false;
          return task.dueDate!.isAfter(todayEnd);

        case TaskFilter.all:
          return !task.isCompleted;

        case TaskFilter.completed:
          return task.isCompleted;
      }
    }).toList()
      ..sort((a, b) {
        // High priority first
        if (a.priority != b.priority) {
          return b.priority.index.compareTo(a.priority.index);
        }
        // Due date sorting
        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!);
        }
        return b.createdAt.compareTo(a.createdAt);
      });
  }

  // Counts for the 4 Smart Cards
  int get todayCount {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _tasks.where((t) {
      if (t.isCompleted || t.dueDate == null) return false;
      return t.dueDate!.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
          t.dueDate!.isBefore(todayEnd.add(const Duration(seconds: 1)));
    }).length;
  }

  int get scheduledCount {
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _tasks.where((t) {
      if (t.isCompleted || t.dueDate == null) return false;
      return t.dueDate!.isAfter(todayEnd);
    }).length;
  }

  int get allCount => _tasks.where((t) => !t.isCompleted).length;

  int get completedCount => _tasks.where((t) => t.isCompleted).length;

  // Progress metrics for Activity Rings
  double get todayProgress {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final todayTasks = _tasks.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
          t.dueDate!.isBefore(todayEnd.add(const Duration(seconds: 1)));
    }).toList();

    if (todayTasks.isEmpty) {
      // If no today tasks, calculate from total active vs completed
      if (_tasks.isEmpty) return 0.0;
      return completedCount / _tasks.length;
    }

    final completedToday = todayTasks.where((t) => t.isCompleted).length;
    return completedToday / todayTasks.length;
  }

  double get highPriorityProgress {
    final highTasks = _tasks.where((t) => t.priority == TaskPriority.high).toList();
    if (highTasks.isEmpty) return 1.0;
    final doneHigh = highTasks.where((t) => t.isCompleted).length;
    return doneHigh / highTasks.length;
  }

  double get overallProgress {
    if (_tasks.isEmpty) return 0.0;
    return completedCount / _tasks.length;
  }

  // Mutations
  Future<void> addTask(TaskItem task) async {
    _tasks.insert(0, task);
    notifyListeners();
    await _storageService.saveTasks(_tasks);
  }

  Future<void> updateTask(TaskItem updated) async {
    final index = _tasks.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _tasks[index] = updated;
      notifyListeners();
      await _storageService.saveTasks(_tasks);
    }
  }

  Future<void> toggleTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final current = _tasks[index];
      final newStatus = !current.isCompleted;
      _tasks[index] = current.copyWith(
        isCompleted: newStatus,
        completedAt: newStatus ? DateTime.now() : null,
      );
      notifyListeners();
      await _storageService.saveTasks(_tasks);
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
    await _storageService.saveTasks(_tasks);
  }

  Future<void> clearCompletedTasks() async {
    _tasks.removeWhere((t) => t.isCompleted);
    notifyListeners();
    await _storageService.saveTasks(_tasks);
  }

  void setFilter(TaskFilter filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _storageService.saveIsDarkMode(_isDarkMode);
  }

  Future<void> setUserName(String name) async {
    _userName = name.trim();
    notifyListeners();
    await _storageService.saveUserName(_userName);
  }

  Future<String> exportBackup() async {
    return _storageService.exportBackupJson();
  }

  Future<bool> importBackup(String jsonString) async {
    final imported = await _storageService.importBackupJson(jsonString);
    if (imported != null) {
      _tasks = imported;
      _userName = await _storageService.loadUserName();
      notifyListeners();
      return true;
    }
    return false;
  }
}
