import 'package:flutter/foundation.dart';
import '../models/task_item.dart';
import '../models/job_application.dart';
import '../models/calorie_habit_item.dart';
import '../models/running_shoe_item.dart';
import '../models/finance_item.dart';
import '../models/shortcut_item.dart';
import '../services/storage_service.dart';
import '../services/strava_service.dart';

enum AppFeature {
  home,
  todo,
  jobCrm,
  running,
  calories,
  finance,
  quickLinks,
  notes;

  String get title {
    switch (this) {
      case AppFeature.home:
        return 'Beranda';
      case AppFeature.todo:
        return 'To-Do List';
      case AppFeature.jobCrm:
        return 'Job Hunt CRM';
      case AppFeature.running:
        return 'Running & Sepatu';
      case AppFeature.calories:
        return 'Kalori & Kebiasaan';
      case AppFeature.finance:
        return 'Keuangan & Runway';
      case AppFeature.quickLinks:
        return 'Pintasan Safari';
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
  
  // Tasks State
  List<TaskItem> _tasks = [];
  TaskFilter _selectedFilter = TaskFilter.all;
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  // Job CRM State
  List<JobApplication> _jobs = [];
  String _selectedJobStatusFilter = 'Semua';

  // Calorie & Habit State
  List<CalorieLog> _calorieLogs = [];
  List<HabitItem> _habits = [];
  int _calorieGoal = 2100;

  // Running State
  List<ShoeItem> _shoes = [];
  List<RunLog> _runLogs = [];
  List<PersonalBest> _personalBests = [];

  // Finance State
  List<FinanceTransaction> _finances = [];
  List<WishlistItem> _wishlists = [];
  final double _initialCashReserve = 8500000; // Base cash reserve in IDR

  // Shortcuts State
  List<ShortcutItem> _shortcuts = [];

  // Strava State
  final StravaService _stravaService = StravaService();
  bool _isStravaConnected = false;
  String _stravaAthleteName = '';
  bool _isSyncingStrava = false;
  DateTime? _stravaLastSync;

  // Global Settings State
  String _userName = 'Hasan';
  String _quickNote = '';
  bool _isDarkMode = false;
  bool _isLoading = true;

  DashboardState() {
    _init();
  }

  // --- Getters ---
  AppFeature get currentFeature => _currentFeature;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  String get userName => _userName;
  String get quickNote => _quickNote;

  // Strava Getters
  bool get isStravaConnected => _isStravaConnected;
  String get stravaAthleteName => _stravaAthleteName;
  bool get isSyncingStrava => _isSyncingStrava;
  DateTime? get stravaLastSync => _stravaLastSync;

  // Tasks
  List<TaskItem> get tasks => _tasks;
  TaskFilter get selectedFilter => _selectedFilter;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  // Job CRM
  List<JobApplication> get jobs => _jobs;
  String get selectedJobStatusFilter => _selectedJobStatusFilter;

  // Calorie & Habits
  List<CalorieLog> get calorieLogs => _calorieLogs;
  List<HabitItem> get habits => _habits;
  int get calorieGoal => _calorieGoal;

  // Running
  List<ShoeItem> get shoes => _shoes;
  List<RunLog> get runLogs => _runLogs;
  List<PersonalBest> get personalBests => _personalBests;

  // Finance
  List<FinanceTransaction> get finances => _finances;
  List<WishlistItem> get wishlists => _wishlists;

  // Shortcuts
  List<ShortcutItem> get shortcuts => _shortcuts;

  // --- Initialization ---
  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    _tasks = await _storageService.loadTasks();
    _jobs = await _storageService.loadJobApplications();
    _calorieLogs = await _storageService.loadCalorieLogs();
    _habits = await _storageService.loadHabits();
    _shoes = await _storageService.loadShoes();
    _runLogs = await _storageService.loadRunLogs();
    _personalBests = await _storageService.loadPersonalBests();
    _finances = await _storageService.loadFinanceTransactions();
    _wishlists = await _storageService.loadWishlists();
    _shortcuts = await _storageService.loadShortcuts();
    _calorieGoal = await _storageService.loadCalorieGoal();

    // Check Strava Connection
    final stravaToken = await _stravaService.getSavedToken();
    if (stravaToken != null) {
      _isStravaConnected = true;
      _stravaAthleteName = (await _stravaService.getSavedAthleteName()) ?? 'Strava Athlete';
      _stravaLastSync = await _stravaService.getLastSyncTime();
    }

    _userName = await _storageService.loadUserName();
    _quickNote = await _storageService.loadQuickNote();
    final savedDark = await _storageService.loadIsDarkMode();
    if (savedDark != null) {
      _isDarkMode = savedDark;
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- Navigation & Core Settings ---
  void setFeature(AppFeature feature) {
    _currentFeature = feature;
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

  Future<void> setQuickNote(String note) async {
    _quickNote = note;
    notifyListeners();
    await _storageService.saveQuickNote(note);
  }

  // ==========================================
  // --- MODULE 1: TO-DO & REMINDERS ---
  // ==========================================
  List<TaskItem> get filteredTasks {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _tasks.where((task) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitle = task.title.toLowerCase().contains(query);
        final matchNotes = task.notes?.toLowerCase().contains(query) ?? false;
        final matchCat = task.category.toLowerCase().contains(query);
        if (!matchTitle && !matchNotes && !matchCat) return false;
      }

      if (_selectedCategory != 'Semua') {
        if (_selectedCategory == 'Mendesak') {
          if (task.priority != TaskPriority.high) return false;
        } else if (task.category != _selectedCategory) {
          return false;
        }
      }

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
        if (a.priority != b.priority) {
          return b.priority.index.compareTo(a.priority.index);
        }
        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!);
        }
        return b.createdAt.compareTo(a.createdAt);
      });
  }

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

  // ==========================================
  // --- MODULE 2: JOB HUNT CRM ---
  // ==========================================
  List<JobApplication> get filteredJobs {
    if (_selectedJobStatusFilter == 'Semua') {
      return List.from(_jobs);
    }
    return _jobs.where((j) => j.status.label == _selectedJobStatusFilter).toList();
  }

  int get totalJobsCount => _jobs.length;

  int get activeInterviewsCount => _jobs.where((j) =>
      j.status == JobStatus.screening ||
      j.status == JobStatus.technical ||
      j.status == JobStatus.interview).length;

  int get offeringCount => _jobs.where((j) => j.status == JobStatus.offering).length;

  void setJobStatusFilter(String statusLabel) {
    _selectedJobStatusFilter = statusLabel;
    notifyListeners();
  }

  Future<void> addJobApplication(JobApplication job) async {
    _jobs.insert(0, job);
    notifyListeners();
    await _storageService.saveJobApplications(_jobs);
  }

  Future<void> updateJobApplication(JobApplication updated) async {
    final index = _jobs.indexWhere((j) => j.id == updated.id);
    if (index != -1) {
      _jobs[index] = updated;
      notifyListeners();
      await _storageService.saveJobApplications(_jobs);
    }
  }

  Future<void> updateJobStatus(String id, JobStatus newStatus) async {
    final index = _jobs.indexWhere((j) => j.id == id);
    if (index != -1) {
      _jobs[index] = _jobs[index].copyWith(status: newStatus);
      notifyListeners();
      await _storageService.saveJobApplications(_jobs);
    }
  }

  Future<void> deleteJobApplication(String id) async {
    _jobs.removeWhere((j) => j.id == id);
    notifyListeners();
    await _storageService.saveJobApplications(_jobs);
  }

  // ==========================================
  // --- MODULE 3: CALORIES & HABITS ---
  // ==========================================
  List<CalorieLog> get todayCalorieLogs {
    final now = DateTime.now();
    return _calorieLogs.where((log) {
      return log.dateTime.year == now.year &&
          log.dateTime.month == now.month &&
          log.dateTime.day == now.day;
    }).toList();
  }

  int get todayCalorieTotal {
    return todayCalorieLogs.fold(0, (sum, item) => sum + item.calories);
  }

  int get remainingCalories => (_calorieGoal - todayCalorieTotal).clamp(0, 99999);

  double get calorieProgress {
    if (_calorieGoal <= 0) return 0.0;
    return (todayCalorieTotal / _calorieGoal).clamp(0.0, 1.0);
  }

  int get habitsCompletedTodayCount =>
      _habits.where((h) => h.isCompletedToday()).length;

  double get habitProgressToday {
    if (_habits.isEmpty) return 0.0;
    return (habitsCompletedTodayCount / _habits.length).clamp(0.0, 1.0);
  }

  Future<void> addCalorieLog(CalorieLog log) async {
    _calorieLogs.insert(0, log);
    notifyListeners();
    await _storageService.saveCalorieLogs(_calorieLogs);
  }

  Future<void> deleteCalorieLog(String id) async {
    _calorieLogs.removeWhere((l) => l.id == id);
    notifyListeners();
    await _storageService.saveCalorieLogs(_calorieLogs);
  }

  Future<void> setCalorieGoal(int goal) async {
    _calorieGoal = goal;
    notifyListeners();
    await _storageService.saveCalorieGoal(goal);
  }

  Future<void> toggleHabitToday(String id) async {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      _habits[index] = _habits[index].toggleToday();
      notifyListeners();
      await _storageService.saveHabits(_habits);
    }
  }

  Future<void> addHabit(HabitItem habit) async {
    _habits.add(habit);
    notifyListeners();
    await _storageService.saveHabits(_habits);
  }

  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
    notifyListeners();
    await _storageService.saveHabits(_habits);
  }

  // ==========================================
  // --- MODULE 4: RUNNING & SHOE TRACKER ---
  // ==========================================
  double get weeklyKm {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    return _runLogs
        .where((r) => r.date.isAfter(sevenDaysAgo))
        .fold(0.0, (sum, item) => sum + item.distanceKm);
  }

  List<ShoeItem> get activeShoes => _shoes.where((s) => !s.isRetired).toList();

  Future<void> addShoe(ShoeItem shoe) async {
    _shoes.add(shoe);
    notifyListeners();
    await _storageService.saveShoes(_shoes);
  }

  Future<void> addKmToShoe(String shoeId, double km) async {
    final index = _shoes.indexWhere((s) => s.id == shoeId);
    if (index != -1) {
      _shoes[index] = _shoes[index].addKm(km);
      notifyListeners();
      await _storageService.saveShoes(_shoes);
    }
  }

  Future<void> toggleRetireShoe(String shoeId) async {
    final index = _shoes.indexWhere((s) => s.id == shoeId);
    if (index != -1) {
      final current = _shoes[index];
      _shoes[index] = ShoeItem(
        id: current.id,
        name: current.name,
        brand: current.brand,
        currentKm: current.currentKm,
        targetMaxKm: current.targetMaxKm,
        colorValue: current.colorValue,
        isRetired: !current.isRetired,
      );
      notifyListeners();
      await _storageService.saveShoes(_shoes);
    }
  }

  Future<void> deleteShoe(String shoeId) async {
    _shoes.removeWhere((s) => s.id == shoeId);
    notifyListeners();
    await _storageService.saveShoes(_shoes);
  }

  Future<void> addRunLog(RunLog run) async {
    _runLogs.insert(0, run);
    if (run.shoeId.isNotEmpty) {
      addKmToShoe(run.shoeId, run.distanceKm);
    }
    notifyListeners();
    await _storageService.saveRunLogs(_runLogs);
  }

  Future<void> deleteRunLog(String runId) async {
    _runLogs.removeWhere((r) => r.id == runId);
    notifyListeners();
    await _storageService.saveRunLogs(_runLogs);
  }

  // --- Strava Integration Actions ---
  Future<bool> connectStrava(String token) async {
    final cleanToken = token.trim();
    if (cleanToken.isEmpty) return false;

    _isSyncingStrava = true;
    notifyListeners();

    try {
      final profile = await _stravaService.fetchAthleteProfile(cleanToken);
      if (profile != null) {
        await _stravaService.saveToken(cleanToken);
        _isStravaConnected = true;
        final firstname = profile['firstname'] ?? '';
        final lastname = profile['lastname'] ?? '';
        final fullName = '$firstname $lastname'.trim();
        _stravaAthleteName = fullName.isNotEmpty ? fullName : 'Strava Athlete';
        _isSyncingStrava = false;
        notifyListeners();

        // Automatically sync recent runs upon connecting
        await syncStravaActivities();
        return true;
      }
    } catch (_) {}

    _isSyncingStrava = false;
    notifyListeners();
    return false;
  }

  Future<void> disconnectStrava() async {
    await _stravaService.disconnect();
    _isStravaConnected = false;
    _stravaAthleteName = '';
    _stravaLastSync = null;
    notifyListeners();
  }

  Future<int> syncStravaActivities() async {
    if (_isSyncingStrava) return 0;

    final token = await _stravaService.getSavedToken();
    if (token == null) return 0;

    _isSyncingStrava = true;
    notifyListeners();

    int newRunsCount = 0;
    try {
      // Find a default active shoe if available
      final defaultShoe = _shoes.firstWhere(
        (s) => !s.isRetired,
        orElse: () => _shoes.isNotEmpty
            ? _shoes.first
            : ShoeItem(
                id: '',
                name: 'Strava Gear',
                brand: 'Strava',
                currentKm: 0,
                targetMaxKm: 600,
                colorValue: 0xFFFC4C02,
              ),
      );

      final stravaRuns = await _stravaService.fetchRecentRuns(
        token,
        defaultShoeId: defaultShoe.id,
        defaultShoeName: defaultShoe.name,
      );

      for (final run in stravaRuns) {
        final alreadyExists = _runLogs.any((r) => r.id == run.id);
        if (!alreadyExists) {
          _runLogs.insert(0, run);
          if (run.shoeId.isNotEmpty) {
            final sIndex = _shoes.indexWhere((s) => s.id == run.shoeId);
            if (sIndex != -1) {
              _shoes[sIndex] = _shoes[sIndex].addKm(run.distanceKm);
            }
          }
          newRunsCount++;
        }
      }

      if (newRunsCount > 0) {
        _runLogs.sort((a, b) => b.date.compareTo(a.date));
        await _storageService.saveRunLogs(_runLogs);
        await _storageService.saveShoes(_shoes);
      }

      _stravaLastSync = DateTime.now();
      await _stravaService.saveLastSyncTime(_stravaLastSync!);
    } catch (_) {}

    _isSyncingStrava = false;
    notifyListeners();
    return newRunsCount;
  }

  // ==========================================
  // --- MODULE 5: FINANCE & RUNWAY ---
  // ==========================================
  double get totalExpenseThisMonth {
    final now = DateTime.now();
    return _finances
        .where((f) => f.isExpense && f.date.month == now.month && f.date.year == now.year)
        .fold(0.0, (sum, f) => sum + f.amount);
  }

  double get currentNetBalance {
    double balance = _initialCashReserve;
    for (final f in _finances) {
      if (f.isExpense) {
        balance -= f.amount;
      } else {
        balance += f.amount;
      }
    }
    return balance;
  }

  double get estimatedRunwayMonths {
    final monthlyBurn = totalExpenseThisMonth > 500000 ? totalExpenseThisMonth : 2500000.0;
    final balance = currentNetBalance;
    if (balance <= 0) return 0.0;
    return (balance / monthlyBurn);
  }

  Future<void> addFinanceTransaction(FinanceTransaction transaction) async {
    _finances.insert(0, transaction);
    notifyListeners();
    await _storageService.saveFinanceTransactions(_finances);
  }

  Future<void> deleteFinanceTransaction(String id) async {
    _finances.removeWhere((f) => f.id == id);
    notifyListeners();
    await _storageService.saveFinanceTransactions(_finances);
  }

  Future<void> addWishlistItem(WishlistItem item) async {
    _wishlists.add(item);
    notifyListeners();
    await _storageService.saveWishlists(_wishlists);
  }

  Future<void> updateWishlistSavings(String id, double deltaAmount) async {
    final index = _wishlists.indexWhere((w) => w.id == id);
    if (index != -1) {
      final current = _wishlists[index];
      final newSaved = (current.savedAmount + deltaAmount).clamp(0.0, current.targetPrice * 2);
      _wishlists[index] = WishlistItem(
        id: current.id,
        name: current.name,
        targetPrice: current.targetPrice,
        savedAmount: newSaved,
        iconCode: current.iconCode,
      );
      notifyListeners();
      await _storageService.saveWishlists(_wishlists);
    }
  }

  Future<void> deleteWishlistItem(String id) async {
    _wishlists.removeWhere((w) => w.id == id);
    notifyListeners();
    await _storageService.saveWishlists(_wishlists);
  }

  // ==========================================
  // --- MODULE 6: QUICK LINKS / SHORTCUTS ---
  // ==========================================
  Future<void> addShortcut(ShortcutItem shortcut) async {
    _shortcuts.add(shortcut);
    notifyListeners();
    await _storageService.saveShortcuts(_shortcuts);
  }

  Future<void> deleteShortcut(String id) async {
    _shortcuts.removeWhere((s) => s.id == id);
    notifyListeners();
    await _storageService.saveShortcuts(_shortcuts);
  }

  // ==========================================
  // --- BACKUP & RESTORE ---
  // ==========================================
  Future<String> exportBackup() async {
    return _storageService.exportBackupJson();
  }

  Future<bool> importBackup(String jsonString) async {
    final success = await _storageService.importBackupJson(jsonString);
    if (success) {
      await _init();
      return true;
    }
    return false;
  }
}
