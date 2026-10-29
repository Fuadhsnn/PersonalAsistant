import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class GeminiReceiptService {
  static const List<String> _candidateModels = [
    'gemini-3.5-flash',
    'gemini-3.8-flash',
    'gemini-2.5-flash',
    'gemini-1.5-flash',
  ];

  static const String _systemPrompt = '''
Kamu adalah asisten ekstraksi struk belanja/restoran. Ekstrak seluruh item pesanan, pajak (PB1/Tax/PPN), biaya layanan (service charge), diskon, subtotal, dan grand total dari gambar struk ini. Kembalikan HANYA dalam format JSON valid tanpa markdown block sesuai skema berikut:
{
  "merchant_name": "string",
  "items": [
    {
      "name": "string",
      "qty": number,
      "unit_price": number,
      "total_price": number
    }
  ],
  "subtotal": number,
  "tax_amount": number,
  "service_amount": number,
  "discount_amount": number,
  "grand_total": number
}
Jika ada nilai yang tidak ditemukan di struk, isi dengan 0.
''';

  /// Extracts structured receipt data from image bytes with automatic model fallback.
  Future<Map<String, dynamic>> parseReceiptImage({
    required Uint8List imageBytes,
    required String apiKey,
    String mimeType = 'image/jpeg',
    String? preferredModel,
  }) async {
    final cleanKey = apiKey.trim();
    if (cleanKey.isEmpty) {
      throw Exception('Gemini API Key belum dimasukkan. Masukkan API Key Anda di Pengaturan.');
    }

    final modelsToTry = [
      if (preferredModel != null && preferredModel.isNotEmpty) preferredModel,
      ..._candidateModels.where((m) => m != preferredModel),
    ];

    String lastError = '';

    for (final model in modelsToTry) {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$cleanKey',
      );

      final base64Image = base64Encode(imageBytes);

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': _systemPrompt},
              {
                'inline_data': {
                  'mime_type': mimeType,
                  'data': base64Image,
                }
              }
            ]
          }
        ],
        'generationConfig': {
          'response_mime_type': 'application/json',
          'temperature': 0.1,
        }
      };

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
          final candidates = jsonResponse['candidates'] as List<dynamic>?;
          if (candidates == null || candidates.isEmpty) {
            throw Exception('Gemini tidak memberikan respon ekstraksi.');
          }

          final candidate = candidates[0] as Map<String, dynamic>;
          final content = candidate['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List<dynamic>?;
          if (parts == null || parts.isEmpty) {
            throw Exception('Tidak ada teks hasil ekstraksi struk dari Gemini.');
          }

          final rawText = parts[0]['text'] as String? ?? '';
          return _cleanAndParseJson(rawText);
        } else if (response.statusCode == 404) {
          // Model not found or deprecated, try next model in candidate list
          lastError = 'Model $model tidak tersedia (404).';
          continue;
        } else {
          final errJson = jsonDecode(response.body);
          final errMsg = errJson['error']?['message'] ?? response.body;
          throw Exception('Gemini API Error (${response.statusCode}): $errMsg');
        }
      } catch (e) {
        if (e is Exception && e.toString().contains('Gemini API Error')) rethrow;
        lastError = e.toString();
      }
    }

    throw Exception('Gagal mengekstrak struk: $lastError');
  }

  Map<String, dynamic> _cleanAndParseJson(String rawText) {
    String cleaned = rawText.trim();

    // Remove markdown code fences if present
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    cleaned = cleaned.trim();

    // Find the first '{' and last '}'
    final firstBrace = cleaned.indexOf('{');
    final lastBrace = cleaned.lastIndexOf('}');
    if (firstBrace != -1 && lastBrace != -1 && lastBrace >= firstBrace) {
      cleaned = cleaned.substring(firstBrace, lastBrace + 1);
    }

    final parsed = jsonDecode(cleaned) as Map<String, dynamic>;
    return parsed;
  }
}
