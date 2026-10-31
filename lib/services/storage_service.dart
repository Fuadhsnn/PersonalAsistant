import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_item.dart';
import '../models/job_application.dart';
import '../models/calorie_habit_item.dart';
import '../models/running_shoe_item.dart';
import '../models/finance_item.dart';
import '../models/shortcut_item.dart';
import '../models/split_bill_model.dart';
import '../models/calendar_event_item.dart';

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
  static const String _dummyWipedKey = 'hasan_dashboard_dummy_wiped_v2';
  static const String _walletBalanceKey = 'hasan_dashboard_wallet_balance';
  static const String _splitBillsKey = 'hasan_dashboard_split_bills_v1';
  static const String _geminiApiKeyKey = 'hasan_dashboard_gemini_api_key';
  static const String _calendarEventsKey = 'hasan_dashboard_calendar_events_v1';
  static const String _googleCalendarSyncKey = 'hasan_dashboard_gcal_synced_v1';

  Future<void> _ensureDummyWiped() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_dummyWipedKey) != true) {
      await prefs.setString(_tasksKey, '[]');
      await prefs.setString(_jobAppsKey, '[]');
      await prefs.setString(_caloriesKey, '[]');
      await prefs.setString(_habitsKey, '[]');
      await prefs.setString(_shoesKey, '[]');
      await prefs.setString(_runsKey, '[]');
      await prefs.setString(_financesKey, '[]');
      await prefs.setString(_wishlistsKey, '[]');
      await prefs.setString(_shortcutsKey, '[]');
      await prefs.setString(_quickNoteKey, '');
      await prefs.setDouble(_walletBalanceKey, 0.0);
      final defaultPbs = _getDefaultPersonalBests();
      await prefs.setString(_pbsKey, jsonEncode(defaultPbs.map((p) => p.toJson()).toList()));
      await prefs.setBool(_dummyWipedKey, true);
    }
  }

  List<PersonalBest> _getDefaultPersonalBests() {
    return const [
      PersonalBest(distanceLabel: '5 KM', time: '--:--', pace: '-- /km', dateStr: '-'),
      PersonalBest(distanceLabel: '10 KM', time: '--:--', pace: '-- /km', dateStr: '-'),
      PersonalBest(distanceLabel: '21 KM (Half)', time: '--:--', pace: '-- /km', dateStr: '-'),
    ];
  }

  // --- Tasks ---
  Future<List<TaskItem>> loadTasks() async {
    await _ensureDummyWiped();
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_tasksKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.map((item) => TaskItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
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
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.map((item) => JobApplication.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
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
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.map((item) => CalorieLog.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
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
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.map((item) => HabitItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveHabits(List<HabitItem> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = habits.map((h) => h.toJson()).toList();
    await prefs.setString(_habitsKey, jsonEncode(jsonList));
  }

  // --- Shoes ---
  Future<List<ShoeItem>> loadShoes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_shoesKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.map((item) => ShoeItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
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
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.map((item) => RunLog.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
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
      final defaults = _getDefaultPersonalBests();
      await savePersonalBests(defaults);
      return defaults;
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      final list = decoded.map((item) => PersonalBest.fromJson(item as Map<String, dynamic>)).toList();
      return list.isEmpty ? _getDefaultPersonalBests() : list;
    } catch (_) {
      return _getDefaultPersonalBests();
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
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.map((item) => FinanceTransaction.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
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
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.map((item) => WishlistItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
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
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.map((item) => ShortcutItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveShortcuts(List<ShortcutItem> shortcuts) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = shortcuts.map((s) => s.toJson()).toList();
    await prefs.setString(_shortcutsKey, jsonEncode(jsonList));
  }

  // --- Wallet Starting Balance ---
  Future<double> loadWalletStartingBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_walletBalanceKey) ?? 0.0;
  }

  Future<void> saveWalletStartingBalance(double balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_walletBalanceKey, balance);
  }

  // --- Clear All Data Completely ---
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tasksKey, '[]');
    await prefs.setString(_jobAppsKey, '[]');
    await prefs.setString(_caloriesKey, '[]');
    await prefs.setString(_habitsKey, '[]');
    await prefs.setString(_shoesKey, '[]');
    await prefs.setString(_runsKey, '[]');
    await prefs.setString(_financesKey, '[]');
    await prefs.setString(_wishlistsKey, '[]');
    await prefs.setString(_shortcutsKey, '[]');
    await prefs.setString(_splitBillsKey, '[]');
    await prefs.setString(_quickNoteKey, '');
    await prefs.setDouble(_walletBalanceKey, 0.0);
    final defaultPbs = _getDefaultPersonalBests();
    await prefs.setString(_pbsKey, jsonEncode(defaultPbs.map((p) => p.toJson()).toList()));
    await prefs.setBool(_dummyWipedKey, true);
  }

  // --- Split Bill Sessions ---
  Future<List<SplitBillSession>> loadSplitBills() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_splitBillsKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map((item) => SplitBillSession.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSplitBills(List<SplitBillSession> bills) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = bills.map((b) => b.toJson()).toList();
    await prefs.setString(_splitBillsKey, jsonEncode(jsonList));
  }

  // --- Gemini API Key ---
  Future<String> loadGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_geminiApiKeyKey) ?? '';
  }

  Future<void> saveGeminiApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_geminiApiKeyKey, key.trim());
  }

  // --- Google Calendar & Schedules ---
  Future<List<CalendarEventItem>> loadCalendarEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_calendarEventsKey);
    if (jsonString == null || jsonString.isEmpty) {
      await saveCalendarEvents([]);
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      final list = decoded
          .map((item) => CalendarEventItem.fromJson(item as Map<String, dynamic>))
          .where((item) =>
              item.id != 'cal_1' &&
              item.id != 'cal_2' &&
              item.id != 'cal_3' &&
              item.id != 'cal_milestone_1' &&
              item.id != 'cal_milestone_2')
          .toList();

      // If any dummy items were present, update saved storage cleanly
      if (list.length != decoded.length) {
        await saveCalendarEvents(list);
      }
      return list;
    } catch (_) {
      await saveCalendarEvents([]);
      return [];
    }
  }

  Future<void> saveCalendarEvents(List<CalendarEventItem> events) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = events.map((e) => e.toJson()).toList();
    await prefs.setString(_calendarEventsKey, jsonEncode(jsonList));
  }

  Future<bool> loadIsGoogleCalendarSynced() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_googleCalendarSyncKey) ?? true;
  }

  Future<void> saveIsGoogleCalendarSynced(bool synced) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_googleCalendarSyncKey, synced);
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
      'splitBills': jsonDecode(prefs.getString(_splitBillsKey) ?? '[]'),
      'calendarEvents': jsonDecode(prefs.getString(_calendarEventsKey) ?? '[]'),
      'geminiApiKey': prefs.getString(_geminiApiKeyKey) ?? '',
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
      if (parsed.containsKey('splitBills')) {
        await prefs.setString(_splitBillsKey, jsonEncode(parsed['splitBills']));
      }
      if (parsed.containsKey('calendarEvents')) {
        await prefs.setString(_calendarEventsKey, jsonEncode(parsed['calendarEvents']));
      }
      if (parsed.containsKey('geminiApiKey')) {
        await prefs.setString(_geminiApiKeyKey, parsed['geminiApiKey'] as String);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

}

