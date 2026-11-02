import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/calendar_event_item.dart';

class GoogleCalendarService {
  // Multi-model failover order according to GEMINI.md
  static const List<String> _geminiModels = [
    'gemini-3.1-flash-lite',
    'gemini-3.5-flash',
    'gemini-3-flash-preview',
    'gemini-3.8-flash',
  ];

  static const String _gcalBaseUrl = 'https://www.googleapis.com/calendar/v3/calendars/primary/events';
  static const String defaultClientId = '179468744649-1pafrhhlehm3isudft1hsmodesn0j2pk.apps.googleusercontent.com';

  /// Generates Google OAuth 2.0 Implicit Grant URL for client-side authorization
  String getOAuthAuthUrl({String? clientId, String? redirectUri}) {
    final cid = (clientId != null && clientId.isNotEmpty) ? clientId : defaultClientId;
    final rUri = (redirectUri != null && redirectUri.isNotEmpty)
        ? redirectUri
        : 'https://aries-seven-pearl.vercel.app';
    const scope = 'https://www.googleapis.com/auth/calendar.events https://www.googleapis.com/auth/calendar.readonly https://www.googleapis.com/auth/userinfo.email';
    
    return 'https://accounts.google.com/o/oauth2/v2/auth'
        '?client_id=${Uri.encodeComponent(cid)}'
        '&redirect_uri=${Uri.encodeComponent(rUri)}'
        '&response_type=token'
        '&scope=${Uri.encodeComponent(scope)}'
        '&prompt=consent'
        '&include_granted_scopes=true';
  }

  /// Fetches Google User Profile (email, name)
  Future<String?> fetchUserEmail(String accessToken) async {
    try {
      final url = Uri.parse('https://www.googleapis.com/oauth2/v3/userinfo');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['email'] as String?;
      }
    } catch (_) {}
    return null;
  }

  /// Fetch events from Google Calendar API v3
  Future<List<CalendarEventItem>> fetchEventsFromGoogle(
    String accessToken, {
    int daysPast = 7,
    int daysAhead = 60,
  }) async {
    try {
      final now = DateTime.now().toUtc();
      final timeMin = now.subtract(Duration(days: daysPast)).toIso8601String();
      final timeMax = now.add(Duration(days: daysAhead)).toIso8601String();

      final url = Uri.parse(
        '$_gcalBaseUrl?timeMin=${Uri.encodeComponent(timeMin)}&timeMax=${Uri.encodeComponent(timeMax)}&singleEvents=true&orderBy=startTime&maxResults=100',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        return items.map((item) {
          final startMap = item['start'] as Map<String, dynamic>? ?? {};
          final endMap = item['end'] as Map<String, dynamic>? ?? {};

          DateTime start = DateTime.now();
          bool isAllDay = false;
          if (startMap['dateTime'] != null) {
            start = DateTime.tryParse(startMap['dateTime'])?.toLocal() ?? DateTime.now();
          } else if (startMap['date'] != null) {
            start = DateTime.tryParse(startMap['date'])?.toLocal() ?? DateTime.now();
            isAllDay = true;
          }

          DateTime end = start.add(const Duration(hours: 1));
          if (endMap['dateTime'] != null) {
            end = DateTime.tryParse(endMap['dateTime'])?.toLocal() ?? end;
          } else if (endMap['date'] != null) {
            end = DateTime.tryParse(endMap['date'])?.toLocal() ?? end;
          }

          // Check if meeting link exists (Google Meet or Zoom)
          String? meetLink;
          final hangoutLink = item['hangoutLink'] as String?;
          if (hangoutLink != null && hangoutLink.isNotEmpty) {
            meetLink = hangoutLink;
          } else {
            final conf = item['conferenceData'] as Map<String, dynamic>?;
            final entryPoints = conf?['entryPoints'] as List<dynamic>?;
            if (entryPoints != null && entryPoints.isNotEmpty) {
              meetLink = entryPoints.first['uri'] as String?;
            }
          }

          final summary = item['summary'] as String? ?? 'Acara Google Calendar';
          final description = item['description'] as String? ?? '';
          final location = item['location'] as String? ?? '';
          final id = item['id'] as String? ?? 'gcal_${DateTime.now().millisecondsSinceEpoch}';

          return CalendarEventItem(
            id: id,
            title: summary,
            description: description,
            startTime: start,
            endTime: end,
            isAllDay: isAllDay,
            location: location,
            meetLink: meetLink,
            category: 'Teknologi',
            colorHex: '0xFF00A3FF',
            isMilestone: false,
          );
        }).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Parses natural language input using Google Gemini into a CalendarEventItem
  Future<CalendarEventItem?> parseNaturalLanguageEvent({
    required String prompt,
    required String apiKey,
  }) async {
    if (apiKey.trim().isEmpty || prompt.trim().isEmpty) {
      return null;
    }

    final now = DateTime.now();
    final systemPrompt = '''
Kamu adalah asisten penjadwalan cerdas untuk ARIES Life OS.
Waktu lokal saat ini adalah: ${now.toIso8601String()}.
Tugasmu adalah mengekstrak teks jadwal dari pengguna dan menghasilkan JSON murni tanpa markdown/backticks dengan format:
{
  "title": "Judul acara",
  "description": "Deskripsi atau catatan singkat",
  "startTime": "ISO8601 string (contoh: 2026-10-31T09:30:00)",
  "endTime": "ISO8601 string (default 1 jam setelah startTime jika tidak disebutkan)",
  "isAllDay": false,
  "location": "Lokasi atau nama platform (misal: Google Meet, Zoom, Kampus, Kantor)",
  "meetLink": "URL Google Meet atau Zoom jika disebutkan, atau null",
  "category": "Salah satu dari: Teknologi, Karir, Finansial, Akademik, Pribadi",
  "isMilestone": false
}
Jika acara merupakan hal besar dalam 7 hari ke depan (misal: sidang, ujian, penerbangan, wawancara final), set "isMilestone": true.
Output HARUS valid JSON murni saja.
''';

    for (final model in _geminiModels) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
        );

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'role': 'user',
                'parts': [
                  {'text': systemPrompt},
                  {'text': 'Input Pengguna: $prompt'},
                ],
              }
            ],
            'generationConfig': {
              'temperature': 0.1,
              'responseMimeType': 'application/json',
            },
          }),
        );

        // GEMINI.md Rule: On 503, 429, 404 DO NOT throw exception; continue to next model
        if (response.statusCode == 503 ||
            response.statusCode == 429 ||
            response.statusCode == 404) {
          continue;
        }

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final candidate = decoded['candidates']?[0];
          final text = candidate?['content']?['parts']?[0]?['text'] ?? '';
          
          if (text.isNotEmpty) {
            String cleaned = text.trim();
            if (cleaned.startsWith('```json')) {
              cleaned = cleaned.substring(7);
            }
            if (cleaned.startsWith('```')) {
              cleaned = cleaned.substring(3);
            }
            if (cleaned.endsWith('```')) {
              cleaned = cleaned.substring(0, cleaned.length - 3);
            }
            cleaned = cleaned.trim();

            final Map<String, dynamic> data = jsonDecode(cleaned);
            return CalendarEventItem(
              id: 'cal_${DateTime.now().millisecondsSinceEpoch}',
              title: data['title'] ?? prompt,
              description: data['description'] ?? '',
              startTime: DateTime.tryParse(data['startTime'] ?? '') ?? now.add(const Duration(hours: 1)),
              endTime: DateTime.tryParse(data['endTime'] ?? '') ?? now.add(const Duration(hours: 2)),
              isAllDay: data['isAllDay'] ?? false,
              location: data['location'] ?? '',
              meetLink: data['meetLink'],
              category: data['category'] ?? 'Teknologi',
              colorHex: _getCategoryColorHex(data['category'] ?? 'Teknologi'),
              isMilestone: data['isMilestone'] ?? false,
            );
          }
        }
      } catch (_) {
        // Fallback silently to next model in loop
        continue;
      }
    }

    return null;
  }

  static String _getCategoryColorHex(String category) {
    switch (category.toLowerCase()) {
      case 'teknologi':
        return '0xFF00A3FF';
      case 'karir':
        return '0xFFFC4C02';
      case 'finansial':
        return '0xFF34C759';
      case 'akademik':
        return '0xFF5856D6';
      case 'pribadi':
      default:
        return '0xFFFF3B30';
    }
  }

  /// Push an event to Google Calendar API v3
  Future<bool> pushEventToGoogle(CalendarEventItem event, String accessToken) async {
    try {
      final url = Uri.parse(_gcalBaseUrl);
      final body = {
        'summary': event.title,
        'description': event.description,
        'location': event.location,
        'start': {
          'dateTime': event.startTime.toUtc().toIso8601String(),
          'timeZone': 'Asia/Jakarta',
        },
        'end': {
          'dateTime': event.endTime.toUtc().toIso8601String(),
          'timeZone': 'Asia/Jakarta',
        },
      };

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  /// Delete an event from Google Calendar API v3
  Future<bool> deleteEventFromGoogle(String eventId, String accessToken) async {
    try {
      final url = Uri.parse('$_gcalBaseUrl/$eventId');
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }
}

