import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../model/trip_request.dart';
import '../model/gemini_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

class GeminiService {

  // Instance Dio untuk HTTP request
  final Dio _dio;

  // Base URL Gemini API
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  GeminiService() : _dio = Dio() {
    // Setup interceptor untuk logging
    // Sangat membantu saat debugging — lihat request dan response di console
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  // Method utama untuk generate itinerary
  Future<GeminiItineraryResponse> generateItinerary(
      TripRequest request) async {
    // Ambil API key dari file .env
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Gemini API key tidak ditemukan di file .env');
    }

    // Bangun prompt yang akan dikirim ke Gemini
    final prompt = _buildPrompt(request);

    try {
      final response = await _dio.post(
        // API key dikirim sebagai query parameter
        '$_baseUrl?key=$apiKey',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
        // Body request sesuai format Gemini API
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          // generationConfig untuk mengontrol output Gemini
          'generationConfig': {
            // temperature 0.7 = cukup kreatif tapi tetap konsisten
            // 0.0 = sangat deterministik, 1.0 = sangat random
            'temperature': 0.7,
            // maxOutputTokens — cukup besar untuk itinerary multi-hari
            // dengan 3 opsi akomodasi + aktivitas per hari
            // 8192 sering terpotong untuk 3+ hari, pakai 16384
            'maxOutputTokens': 16384,
          }
        },
      );

      // ── Cek finishReason ──
      // Kalau finishReason == "MAX_TOKENS" berarti response terpotong
      final candidate = response.data['candidates'][0] as Map<String, dynamic>;
      final finishReason = candidate['finishReason'] as String?;
      if (finishReason == 'MAX_TOKENS') {
        throw Exception(
          'Response terlalu panjang. Coba kurangi jumlah hari atau coba lagi.',
        );
      }

      // Ambil teks response dari struktur JSON Gemini
      // Struktur: response.data.candidates[0].content.parts[0].text
      final responseText = candidate['content']['parts'][0]['text'] as String;

      // Parse teks JSON dari response menjadi objek Dart
      return _parseResponse(responseText);

    } on DioException catch (e) {
      // DioException terjadi kalau ada masalah network atau HTTP error
      if (e.response?.statusCode == 429) {
        throw Exception('Batas penggunaan API tercapai. Coba lagi nanti.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Request tidak valid. Periksa input perjalanan.');
      }
      throw Exception('Gagal terhubung ke AI. Periksa koneksi internet.');
    } catch (e) {
      // FormatException dari jsonDecode akan tertangkap di sini
      throw Exception(
        'Gagal memproses response AI. Silakan coba lagi.',
      );
    }
  }

  // Method untuk membangun prompt yang dikirim ke Gemini
  // Ini bagian paling penting — kualitas output sangat bergantung
  // pada kualitas prompt yang dibuat
  String _buildPrompt(TripRequest request) {
    // Format budget ke Rupiah
    final budgetFormatted = 'Rp ${request.budget.toStringAsFixed(0)}';

    // Bangun daftar tema per hari
    final themesPerDay = request.themes
        .asMap()
        .entries
        .map((entry) => 'Day ${entry.key + 1}: ${entry.value}')
        .join('\n');

    return '''
You are an expert Indonesian travel planner. Generate a detailed travel itinerary based on the following information:

TRIP DETAILS:
- Destination: ${request.destination}
- Duration: ${request.totalDays} days
- Start Date: ${request.startDate.toIso8601String().split('T')[0]}
- End Date: ${request.endDate.toIso8601String().split('T')[0]}
- Total Budget: $budgetFormatted
- Trip Type: ${request.tripType}
- Theme per day:
$themesPerDay

IMPORTANT INSTRUCTIONS:
1. All prices MUST be in Indonesian Rupiah (IDR) and MUST be realistic for the destination
2. Total costs (accommodation + food + transport + activities) MUST NOT exceed the budget: $budgetFormatted
3. Accommodation options must have REAL hotel/villa/homestay names in ${request.destination} you can check it via Google Maps or Booking.com
4. Activities must be REAL places that exist in ${request.destination}
5. Respond ONLY with valid JSON — no explanation, no markdown, no code blocks
6. Each day's activities must match the theme specified for that day
7. Each activity MUST have a realistic non-zero estimated_cost (e.g., makan siang 30,000–50,000, tiket masuk 10,000–25,000, transportasi 20,000–50,000, minuman 5,000–15,000)
8. Each activity description MUST be exactly ONE sentence — short and informative

REQUIRED JSON FORMAT (respond with exactly this structure):
{
  "accommodation_options": [
    {
      "name": "Real hotel name in ${request.destination}",
      "price_per_night": 150000,
      "total_price": 300000,
      "facilities": ["WiFi", "AC", "Breakfast"]
    },
    {
      "name": "Second real hotel name",
      "price_per_night": 250000,
      "total_price": 500000,
      "facilities": ["WiFi", "AC", "Pool"]
    },
    {
      "name": "Third real hotel name",
      "price_per_night": 400000,
      "total_price": 800000,
      "facilities": ["WiFi", "AC", "Breakfast", "Pool"]
    }
  ],
  "day_plans": [
    {
      "day_number": 1,
      "theme": "${request.themes.isNotEmpty ? request.themes[0] : 'tour'}",
      "activities": [
        {
          "time": "08.00 - 10.00",
          "name": "Real place name",
          "description": "One short sentence describing this activity.",
          "estimated_cost": 30000
        }
      ]
    }
  ],
  "estimated_food_cost": 300000,
  "estimated_transport_cost": 200000,
  "estimated_activity_cost": 150000
}

Generate exactly ${request.totalDays} day_plans. Each day must have 3-5 activities.
Every single activity MUST have a realistic non-zero estimated_cost. Description MUST be one sentence only.
Make sure the sum of the cheapest accommodation + food + transport + activities is within budget $budgetFormatted.
''';
  }

  // Method untuk parse response JSON dari Gemini
  GeminiItineraryResponse _parseResponse(String responseText) {
    // Gemini terkadang menambahkan markdown code block (```json ... ```)
    // meskipun sudah diminta tidak. Baris ini membersihkannya.
    String cleanJson = responseText
        .replaceAll('```json', '')  // hapus pembuka code block
        .replaceAll('```', '')      // hapus penutup code block
        .trim();                    // hapus whitespace di awal/akhir

    // dart:convert untuk decode JSON string menjadi Map
    final Map<String, dynamic> jsonData = jsonDecode(cleanJson);

    return GeminiItineraryResponse.fromMap(jsonData);
  }
}

// Provider untuk GeminiService
final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});