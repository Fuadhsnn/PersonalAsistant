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

