import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/running_shoe_item.dart';

class StravaService {
  static const String _stravaTokenKey = 'hasan_dashboard_strava_token';
  static const String _stravaAthleteKey = 'hasan_dashboard_strava_athlete';
  static const String _baseUrl = 'https://www.strava.com/api/v3';

  static const String _stravaLastSyncKey = 'hasan_dashboard_strava_last_sync';

  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_stravaLastSyncKey);
    return str != null ? DateTime.tryParse(str) : null;
  }

  Future<void> saveLastSyncTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_stravaLastSyncKey, time.toIso8601String());
  }

  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_stravaTokenKey);
    return (token != null && token.trim().isNotEmpty) ? token.trim() : null;
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_stravaTokenKey, token.trim());
  }

  Future<void> disconnect() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_stravaTokenKey);
    await prefs.remove(_stravaAthleteKey);
    await prefs.remove(_stravaLastSyncKey);
  }

  Future<String?> getSavedAthleteName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_stravaAthleteKey);
  }

  Future<Map<String, dynamic>?> fetchAthleteProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/athlete'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final firstname = data['firstname'] ?? '';
        final lastname = data['lastname'] ?? '';
        final fullName = '$firstname $lastname'.trim();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_stravaAthleteKey, fullName.isNotEmpty ? fullName : 'Strava Athlete');
        return data;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Fetches recent activities from Strava and maps only 'Run' activities to RunLog models
  Future<List<RunLog>> fetchRecentRuns(String token, {String defaultShoeId = '', String defaultShoeName = 'Strava Gear'}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/athlete/activities?per_page=20'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body) as List<dynamic>;
        final List<RunLog> runs = [];

        for (final item in list) {
          final type = item['type'] as String? ?? '';
          final sportType = item['sport_type'] as String? ?? '';
          
          // Filter for running activities only
          if (type.toLowerCase() == 'run' || sportType.toLowerCase() == 'run') {
            final double distanceMeters = (item['distance'] as num?)?.toDouble() ?? 0.0;
            final double distanceKm = distanceMeters / 1000.0;
            final int movingTimeSec = (item['moving_time'] as num?)?.toInt() ?? 0;
            final int durationMinutes = (movingTimeSec / 60).round();
            final double avgSpeed = (item['average_speed'] as num?)?.toDouble() ?? 0.0;

            // Calculate Pace: min:sec /km
            String paceStr = '5:30 /km';
            if (avgSpeed > 0) {
              final double secPerKm = 1000.0 / avgSpeed;
              final int pMin = secPerKm ~/ 60;
              final int pSec = (secPerKm % 60).round();
              paceStr = '$pMin:${pSec.toString().padLeft(2, '0')} /km';
            }

            final String startDateStr = item['start_date_local'] as String? ?? item['start_date'] as String? ?? '';
            final DateTime date = startDateStr.isNotEmpty ? DateTime.tryParse(startDateStr) ?? DateTime.now() : DateTime.now();
            final String name = item['name'] as String? ?? 'Strava Run';

            runs.add(
              RunLog(
                id: 'strava_${item['id']}',
                distanceKm: double.parse(distanceKm.toStringAsFixed(2)),
                durationMinutes: durationMinutes > 0 ? durationMinutes : 1,
                pace: paceStr,
                shoeId: defaultShoeId,
                shoeName: defaultShoeName,
                date: date,
                notes: '⚡ Sinkronisasi Strava: $name',
              ),
            );
          }
        }
        return runs;
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
