import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class GeminiReceiptService {
  static const List<String> _candidateModels = [
    'gemini-3.1-flash-lite',
    'gemini-3.5-flash',
    'gemini-3-flash-preview',
    'gemini-3.8-flash',
    'gemini-3.5-flash-lite',
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
            lastError = 'Gemini ($model) tidak memberikan kandidat respon.';
            continue;
          }

          final candidate = candidates[0] as Map<String, dynamic>;
          final content = candidate['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List<dynamic>?;
          if (parts == null || parts.isEmpty) {
            lastError = 'Tidak ada teks hasil ekstraksi struk dari Gemini ($model).';
            continue;
          }

          final rawText = parts[0]['text'] as String? ?? '';
          return _cleanAndParseJson(rawText);
        } else if (response.statusCode == 503 ||
            response.statusCode == 429 ||
            response.statusCode == 404 ||
            response.statusCode == 500) {
          // Model high demand (503), rate limit (429), or deprecated (404).
          // Failover to next candidate model!
          lastError = 'Model $model status (${response.statusCode})';
          await Future.delayed(const Duration(milliseconds: 300));
          continue;
        } else {
          try {
            final errJson = jsonDecode(response.body);
            final errMsg = errJson['error']?['message'] ?? response.body;
            lastError = 'Gemini ($model, ${response.statusCode}): $errMsg';
          } catch (_) {
            lastError = 'Gemini API Error (${response.statusCode}): ${response.reasonPhrase}';
          }
          continue;
        }
      } catch (e) {
        lastError = e.toString();
        continue;
      }
    }

    throw Exception(
      'Semua model Gemini sedang sibuk atau mengalami kendala: $lastError. Silakan coba beberapa saat lagi.',
    );
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
