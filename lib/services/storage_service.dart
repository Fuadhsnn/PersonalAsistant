import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_item.dart';
import '../models/job_application.dart';
import '../models/calorie_habit_item.dart';
import '../models/running_shoe_item.dart';
import '../models/finance_item.dart';
import '../models/shortcut_item.dart';

class StorageService {
  static const String _tasksKey = 'hasan_dashboard_tasks_v1';
  static const String _userNameKey = 'hasan_dashboard_user_name';
  static const String _themeDarkKey = 'hasan_dashboard_theme_dark';
  static const String _quickNoteKey = 'hasan_dashboard_quick_note';
  static const String _jobAppsKey = 'hasan_dashboard_jobs_v1';
  static const String _caloriesKey = 'hasan_dashboard_calories_v1';
  static const String _habitsKey = 'hasan_dashboard_habits_v1';
  static const String _shoesKey = 'hasan_dashboard_shoes_v1';
  static const String _runsKey = 'hasan_dashboard_runs_v1';
  static const String _pbsKey = 'hasan_dashboard_pbs_v1';
  static const String _financesKey = 'hasan_dashboard_finances_v1';
  static const String _wishlistsKey = 'hasan_dashboard_wishlists_v1';
  static const String _shortcutsKey = 'hasan_dashboard_shortcuts_v1';
  static const String _calorieGoalKey = 'hasan_dashboard_calorie_goal';

  // --- Tasks ---
  Future<List<TaskItem>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_tasksKey);

    if (jsonString == null || jsonString.isEmpty) {
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

  // --- Job Applications ---
  Future<List<JobApplication>> loadJobApplications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_jobAppsKey);

    if (jsonString == null || jsonString.isEmpty) {
      final samples = _getSampleJobApplications();
      await saveJobApplications(samples);
      return samples;
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.map((item) => JobApplication.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return _getSampleJobApplications();
    }
  }

  Future<void> saveJobApplications(List<JobApplication> jobs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = jobs.map((j) => j.toJson()).toList();
    await prefs.setString(_jobAppsKey, jsonEncode(jsonList));
  }

  // --- Calorie Logs ---
  Future<List<CalorieLog>> loadCalorieLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_caloriesKey);

    if (jsonString == null || jsonString.isEmpty) {
      final samples = _getSampleCalorieLogs();
      await saveCalorieLogs(samples);
      return samples;
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.map((item) => CalorieLog.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return _getSampleCalorieLogs();
    }
  }

  Future<void> saveCalorieLogs(List<CalorieLog> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = logs.map((l) => l.toJson()).toList();
    await prefs.setString(_caloriesKey, jsonEncode(jsonList));
  }

  // --- Habits ---
  Future<List<HabitItem>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_habitsKey);

    if (jsonString == null || jsonString.isEmpty) {
      final samples = _getSampleHabits();
      await saveHabits(samples);
      return samples;
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.map((item) => HabitItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return _getSampleHabits();
    }
  }

  Future<void> saveHabits(List<HabitItem> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = habits.map((h) => h.toJson()).toList();
    await prefs.setString(_habitsKey, jsonEncode(jsonList));
  }

  // --- Running Shoes ---
  Future<List<ShoeItem>> loadShoes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_shoesKey);

    if (jsonString == null || jsonString.isEmpty) {
      final samples = _getSampleShoes();
      await saveShoes(samples);
      return samples;
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.map((item) => ShoeItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return _getSampleShoes();
    }
  }

  Future<void> saveShoes(List<ShoeItem> shoes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = shoes.map((s) => s.toJson()).toList();
    await prefs.setString(_shoesKey, jsonEncode(jsonList));
  }

  // --- Run Logs ---
  Future<List<RunLog>> loadRunLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_runsKey);

    if (jsonString == null || jsonString.isEmpty) {
      final samples = _getSampleRunLogs();
      await saveRunLogs(samples);
      return samples;
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.map((item) => RunLog.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return _getSampleRunLogs();
    }
  }

  Future<void> saveRunLogs(List<RunLog> runs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = runs.map((r) => r.toJson()).toList();
    await prefs.setString(_runsKey, jsonEncode(jsonList));
  }

  // --- Personal Bests ---
  Future<List<PersonalBest>> loadPersonalBests() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_pbsKey);

    if (jsonString == null || jsonString.isEmpty) {
      final samples = _getSamplePersonalBests();
      await savePersonalBests(samples);
      return samples;
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.map((item) => PersonalBest.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return _getSamplePersonalBests();
    }
  }

  Future<void> savePersonalBests(List<PersonalBest> pbs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = pbs.map((p) => p.toJson()).toList();
    await prefs.setString(_pbsKey, jsonEncode(jsonList));
  }

  // --- Finance Transactions ---
  Future<List<FinanceTransaction>> loadFinanceTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_financesKey);

    if (jsonString == null || jsonString.isEmpty) {
      final samples = _getSampleFinances();
      await saveFinanceTransactions(samples);
      return samples;
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.map((item) => FinanceTransaction.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return _getSampleFinances();
    }
  }

  Future<void> saveFinanceTransactions(List<FinanceTransaction> finances) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = finances.map((f) => f.toJson()).toList();
    await prefs.setString(_financesKey, jsonEncode(jsonList));
  }

  // --- Wishlist Items ---
  Future<List<WishlistItem>> loadWishlists() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_wishlistsKey);

    if (jsonString == null || jsonString.isEmpty) {
      final samples = _getSampleWishlists();
      await saveWishlists(samples);
      return samples;
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.map((item) => WishlistItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return _getSampleWishlists();
    }
  }

  Future<void> saveWishlists(List<WishlistItem> wishlists) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = wishlists.map((w) => w.toJson()).toList();
    await prefs.setString(_wishlistsKey, jsonEncode(jsonList));
  }

  // --- Shortcuts ---
  Future<List<ShortcutItem>> loadShortcuts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_shortcutsKey);

    if (jsonString == null || jsonString.isEmpty) {
      final samples = _getSampleShortcuts();
      await saveShortcuts(samples);
      return samples;
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.map((item) => ShortcutItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return _getSampleShortcuts();
    }
  }

  Future<void> saveShortcuts(List<ShortcutItem> shortcuts) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = shortcuts.map((s) => s.toJson()).toList();
    await prefs.setString(_shortcutsKey, jsonEncode(jsonList));
  }

  // --- Calorie Goal ---
  Future<int> loadCalorieGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_calorieGoalKey) ?? 2100;
  }

  Future<void> saveCalorieGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_calorieGoalKey, goal);
  }

  // --- Settings & Metadata ---
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
    return prefs.getString(_quickNoteKey) ??
        '💡 Catatan Cepat:\n- Follow-up HR Tech Company (hari Kamis)\n- Latihan long run 10 km minggu pagi\n- Review materi System Design & SQL CTE';
  }

  Future<void> saveQuickNote(String note) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_quickNoteKey, note);
  }

  // --- Universal 1-Tap Backup / Restore ---
  Future<String> exportBackupJson() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString(_userNameKey) ?? 'Hasan';
    
    final backupData = {
      'app': 'Personal Assistant Life OS',
      'version': '2.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'userName': userName,
      'tasks': jsonDecode(prefs.getString(_tasksKey) ?? '[]'),
      'jobApplications': jsonDecode(prefs.getString(_jobAppsKey) ?? '[]'),
      'calorieLogs': jsonDecode(prefs.getString(_caloriesKey) ?? '[]'),
      'habits': jsonDecode(prefs.getString(_habitsKey) ?? '[]'),
      'shoes': jsonDecode(prefs.getString(_shoesKey) ?? '[]'),
      'runLogs': jsonDecode(prefs.getString(_runsKey) ?? '[]'),
      'personalBests': jsonDecode(prefs.getString(_pbsKey) ?? '[]'),
      'finances': jsonDecode(prefs.getString(_financesKey) ?? '[]'),
      'wishlists': jsonDecode(prefs.getString(_wishlistsKey) ?? '[]'),
      'shortcuts': jsonDecode(prefs.getString(_shortcutsKey) ?? '[]'),
      'quickNote': prefs.getString(_quickNoteKey) ?? '',
      'calorieGoal': prefs.getInt(_calorieGoalKey) ?? 2100,
    };

    return const JsonEncoder.withIndent('  ').convert(backupData);
  }

  Future<bool> importBackupJson(String rawJson) async {
    try {
      final Map<String, dynamic> parsed = jsonDecode(rawJson) as Map<String, dynamic>;
      final prefs = await SharedPreferences.getInstance();

      if (parsed.containsKey('userName')) {
        await prefs.setString(_userNameKey, parsed['userName'] as String);
      }
      if (parsed.containsKey('quickNote')) {
        await prefs.setString(_quickNoteKey, parsed['quickNote'] as String);
      }
      if (parsed.containsKey('calorieGoal')) {
        await prefs.setInt(_calorieGoalKey, parsed['calorieGoal'] as int);
      }
      if (parsed.containsKey('tasks')) {
        await prefs.setString(_tasksKey, jsonEncode(parsed['tasks']));
      }
      if (parsed.containsKey('jobApplications')) {
        await prefs.setString(_jobAppsKey, jsonEncode(parsed['jobApplications']));
      }
      if (parsed.containsKey('calorieLogs')) {
        await prefs.setString(_caloriesKey, jsonEncode(parsed['calorieLogs']));
      }
      if (parsed.containsKey('habits')) {
        await prefs.setString(_habitsKey, jsonEncode(parsed['habits']));
      }
      if (parsed.containsKey('shoes')) {
        await prefs.setString(_shoesKey, jsonEncode(parsed['shoes']));
      }
      if (parsed.containsKey('runLogs')) {
        await prefs.setString(_runsKey, jsonEncode(parsed['runLogs']));
      }
      if (parsed.containsKey('personalBests')) {
        await prefs.setString(_pbsKey, jsonEncode(parsed['personalBests']));
      }
      if (parsed.containsKey('finances')) {
        await prefs.setString(_financesKey, jsonEncode(parsed['finances']));
      }
      if (parsed.containsKey('wishlists')) {
        await prefs.setString(_wishlistsKey, jsonEncode(parsed['wishlists']));
      }
      if (parsed.containsKey('shortcuts')) {
        await prefs.setString(_shortcutsKey, jsonEncode(parsed['shortcuts']));
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  // --- Seed Samples ---
  List<TaskItem> _getSampleTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 18, 0);

    return [
      TaskItem(
        id: '1',
        title: 'Review portofolio GitHub & update link project',
        notes: 'Pastikan README Personal Assistant rapi dan ada demo Vercel',
        dueDate: today,
        priority: TaskPriority.high,
        category: 'Karir',
        isCompleted: false,
      ),
      TaskItem(
        id: '2',
        title: 'Persiapan Technical Interview PT Telkom / Mandiri',
        notes: 'Review query SQL (Window Functions & CTE) dan REST API',
        dueDate: today,
        priority: TaskPriority.high,
        category: 'Karir',
        isCompleted: true,
        completedAt: now,
      ),
      TaskItem(
        id: '3',
        title: 'Easy Run 5 km (Pace santai 5:45)',
        notes: 'Pakai sepatu Nike Pegasus 40 di rute GBK / komplek',
        dueDate: today,
        priority: TaskPriority.medium,
        category: 'Running',
        isCompleted: false,
      ),
      TaskItem(
        id: '4',
        title: 'Catat pengeluaran mingguan & cek runway dana darurat',
        notes: 'Sinkronisasi kas harian dan target tabungan',
        dueDate: today.add(const Duration(days: 2)),
        priority: TaskPriority.low,
        category: 'Keuangan',
        isCompleted: false,
      ),
    ];
  }

  List<JobApplication> _getSampleJobApplications() {
    final now = DateTime.now();
    return [
      JobApplication(
        id: 'job_1',
        company: 'Traveloka',
        position: 'Associate Software Engineer',
        workSystem: 'Hybrid (Jakarta)',
        salaryExpectation: 'Rp 9.000.000 - 12.000.000',
        cvVersion: 'CV_Software_Hasan_2026.pdf',
        status: JobStatus.interview,
        appliedDate: now.subtract(const Duration(days: 8)),
        followUpDate: now.add(const Duration(days: 2)),
        notes: 'Interview User teknis hari Kamis jam 14:00 WIB via Google Meet.',
        hrContact: 'siti.hr@traveloka.com',
      ),
      JobApplication(
        id: 'job_2',
        company: 'Bank Central Asia (BCA)',
        position: 'IT Trainee / Specialist',
        workSystem: 'On-site (Wisma Asia)',
        salaryExpectation: 'Standar Program Trainee',
        cvVersion: 'CV_General_Hasan_2026.pdf',
        status: JobStatus.technical,
        appliedDate: now.subtract(const Duration(days: 14)),
        followUpDate: now.add(const Duration(days: 1)),
        notes: 'Sedang mengerjakan online assessment Hackerrank (Data Structure).',
        hrContact: 'recruitment@bca.co.id',
      ),
      JobApplication(
        id: 'job_3',
        company: 'Goto Group (Tokopedia)',
        position: 'Data Analyst / BI Associate',
        workSystem: 'Hybrid (BSD)',
        salaryExpectation: 'Rp 8.500.000 - 11.000.000',
        cvVersion: 'CV_Data_Hasan_2026.pdf',
        status: JobStatus.screening,
        appliedDate: now.subtract(const Duration(days: 4)),
        notes: 'Screening profil via LinkedIn Talent.',
        hrContact: 'talent@tokopedia.com',
      ),
      JobApplication(
        id: 'job_4',
        company: 'Agate Game Studio',
        position: 'Junior Unity Developer',
        workSystem: 'Remote',
        salaryExpectation: 'Rp 7.500.000 - 9.500.000',
        cvVersion: 'CV_GameDev_Hasan_2026.pdf',
        status: JobStatus.applied,
        appliedDate: now.subtract(const Duration(days: 2)),
        notes: 'Portofolio game prototype terlampir di CV.',
      ),
    ];
  }

  List<CalorieLog> _getSampleCalorieLogs() {
    final now = DateTime.now();
    return [
      CalorieLog(
        id: 'cal_1',
        foodName: 'Kopi Susu Jago (Aren)',
        calories: 195,
        mealType: 'Camilan/Kopi',
        dateTime: DateTime(now.year, now.month, now.day, 8, 30),
      ),
      CalorieLog(
        id: 'cal_2',
        foodName: 'Warteg (Nasi + Telur Dadar + Orek Tempe)',
        calories: 430,
        mealType: 'Makan Siang',
        dateTime: DateTime(now.year, now.month, now.day, 12, 15),
      ),
      CalorieLog(
        id: 'cal_3',
        foodName: 'Telur Rebus (2 Butir)',
        calories: 140,
        mealType: 'Camilan/Kopi',
        dateTime: DateTime(now.year, now.month, now.day, 16, 0),
      ),
    ];
  }

  List<HabitItem> _getSampleHabits() {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final yesterday = now.subtract(const Duration(days: 1));
    final yestStr = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
    final twoDaysAgo = now.subtract(const Duration(days: 2));
    final twoDaysStr = '${twoDaysAgo.year}-${twoDaysAgo.month.toString().padLeft(2, '0')}-${twoDaysAgo.day.toString().padLeft(2, '0')}';

    return [
      HabitItem(
        id: 'h_1',
        title: 'Minum Air 2.5 Liter',
        iconCode: 'drop',
        colorValue: 0xFF007AFF,
        completedDateStrings: [twoDaysStr, yestStr, todayStr],
      ),
      HabitItem(
        id: 'h_2',
        title: 'Lari / Olahraga 30 Menit',
        iconCode: 'figure.run',
        colorValue: 0xFFFF2D55,
        completedDateStrings: [twoDaysStr, yestStr],
      ),
      HabitItem(
        id: 'h_3',
        title: 'Belajar / Coding 1 Jam',
        iconCode: 'laptopcomputer',
        colorValue: 0xFF5856D6,
        completedDateStrings: [twoDaysStr, yestStr, todayStr],
      ),
      HabitItem(
        id: 'h_4',
        title: 'Tidur Sebelum 23:30',
        iconCode: 'moon.stars',
        colorValue: 0xFFFF9500,
        completedDateStrings: [yestStr],
      ),
    ];
  }

  List<ShoeItem> _getSampleShoes() {
    return [
      ShoeItem(
        id: 'shoe_1',
        name: 'Pegasus 40 (Daily Trainer)',
        brand: 'Nike',
        currentKm: 284.5,
        targetMaxKm: 650.0,
        colorValue: 0xFF007AFF, // Blue
        isRetired: false,
      ),
      ShoeItem(
        id: 'shoe_2',
        name: 'Novablast 4 (Long Run / Tempo)',
        brand: 'Asics',
        currentKm: 142.0,
        targetMaxKm: 700.0,
        colorValue: 0xFFFF9500, // Orange
        isRetired: false,
      ),
      ShoeItem(
        id: 'shoe_3',
        name: 'Vaporfly Next% 2 (Race Day)',
        brand: 'Nike',
        currentKm: 48.0,
        targetMaxKm: 350.0,
        colorValue: 0xFFFF2D55, // Pink/Red
        isRetired: false,
      ),
    ];
  }

  List<RunLog> _getSampleRunLogs() {
    final now = DateTime.now();
    return [
      RunLog(
        id: 'run_1',
        distanceKm: 5.2,
        durationMinutes: 28,
        pace: '5:23 /km',
        shoeId: 'shoe_1',
        shoeName: 'Nike Pegasus 40',
        date: now.subtract(const Duration(days: 1)),
        notes: 'Recovery run sore di komplek, cuaca sejuk.',
      ),
      RunLog(
        id: 'run_2',
        distanceKm: 10.0,
        durationMinutes: 53,
        pace: '5:18 /km',
        shoeId: 'shoe_2',
        shoeName: 'Asics Novablast 4',
        date: now.subtract(const Duration(days: 3)),
        notes: 'Long run pagi di GBK Senayan, cadence stabil.',
      ),
      RunLog(
        id: 'run_3',
        distanceKm: 5.0,
        durationMinutes: 25,
        pace: '5:02 /km',
        shoeId: 'shoe_1',
        shoeName: 'Nike Pegasus 40',
        date: now.subtract(const Duration(days: 6)),
        notes: 'Interval run 5x800m.',
      ),
    ];
  }

  List<PersonalBest> _getSamplePersonalBests() {
    return const [
      PersonalBest(
        distanceLabel: '5 KM',
        time: '24:12',
        pace: '4:50 /km',
        dateStr: 'Jan 2026 (GBK)',
      ),
      PersonalBest(
        distanceLabel: '10 KM',
        time: '52:15',
        pace: '5:13 /km',
        dateStr: 'Feb 2026',
      ),
      PersonalBest(
        distanceLabel: '21 KM (Half)',
        time: '1:58:30',
        pace: '5:37 /km',
        dateStr: 'Target 2026',
      ),
    ];
  }

  List<FinanceTransaction> _getSampleFinances() {
    final now = DateTime.now();
    return [
      FinanceTransaction(
        id: 'f_1',
        title: 'Kopi Susu Jago + Sarapan Roti',
        amount: 28000,
        isExpense: true,
        category: 'Makan & Kopi',
        date: now,
      ),
      FinanceTransaction(
        id: 'f_2',
        title: 'Makan Siang Nasi Padang',
        amount: 32000,
        isExpense: true,
        category: 'Makan & Kopi',
        date: now.subtract(const Duration(days: 1)),
      ),
      FinanceTransaction(
        id: 'f_3',
        title: 'Project Freelance Landing Page',
        amount: 2500000,
        isExpense: false,
        category: 'Pemasukan',
        date: now.subtract(const Duration(days: 5)),
      ),
      FinanceTransaction(
        id: 'f_4',
        title: 'Isi Bensin & Parkir',
        amount: 50000,
        isExpense: true,
        category: 'Transport',
        date: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  List<WishlistItem> _getSampleWishlists() {
    return [
      WishlistItem(
        id: 'w_1',
        name: 'Sepatu Race Day (Asics Metaspeed / Nike Alphafly)',
        targetPrice: 3800000,
        savedAmount: 1900000,
        iconCode: 'flame',
      ),
      WishlistItem(
        id: 'w_2',
        name: 'Garmin Forerunner 265 Music',
        targetPrice: 6500000,
        savedAmount: 2200000,
        iconCode: 'watch',
      ),
    ];
  }

  List<ShortcutItem> _getSampleShortcuts() {
    return const [
      ShortcutItem(
        id: 'sc_1',
        title: 'LinkedIn',
        url: 'https://www.linkedin.com',
        category: 'Karir',
        iconCode: 'briefcase',
        colorValue: 0xFF0A66C2,
      ),
      ShortcutItem(
        id: 'sc_2',
        title: 'Jobstreet',
        url: 'https://www.jobstreet.co.id',
        category: 'Karir',
        iconCode: 'briefcase',
        colorValue: 0xFF1C3F95,
      ),
      ShortcutItem(
        id: 'sc_3',
        title: 'GitHub',
        url: 'https://github.com',
        category: 'Code',
        iconCode: 'code',
        colorValue: 0xFF24292E,
      ),
      ShortcutItem(
        id: 'sc_4',
        title: 'Strava',
        url: 'https://www.strava.com',
        category: 'Running',
        iconCode: 'run',
        colorValue: 0xFFFC4C02,
      ),
      ShortcutItem(
        id: 'sc_5',
        title: 'ChatGPT',
        url: 'https://chatgpt.com',
        category: 'AI',
        iconCode: 'ai',
        colorValue: 0xFF10A37F,
      ),
      ShortcutItem(
        id: 'sc_6',
        title: 'LeetCode',
        url: 'https://leetcode.com',
        category: 'Code',
        iconCode: 'code',
        colorValue: 0xFFFFA116,
      ),
      ShortcutItem(
        id: 'sc_7',
        title: 'YouTube',
        url: 'https://youtube.com',
        category: 'Media',
        iconCode: 'video',
        colorValue: 0xFFFF0000,
      ),
      ShortcutItem(
        id: 'sc_8',
        title: 'Notion',
        url: 'https://notion.so',
        category: 'Produktivitas',
        iconCode: 'globe',
        colorValue: 0xFF000000,
      ),
    ];
  }
}
