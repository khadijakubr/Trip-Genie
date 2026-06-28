//import 'itinerary.dart';
import 'accommodation_option.dart';

// Model untuk menampung seluruh response dari Gemini
// sebelum diproses lebih lanjut
class GeminiItineraryResponse {
  // 3 opsi akomodasi untuk dipilih user di detail page
  final List<AccommodationOption> accommodationOptions;
  // Data itinerary lengkap per hari
  final List<Map<String, dynamic>> dayPlans;
  // Estimasi biaya per kategori
  final double estimatedFoodCost;
  final double estimatedTransportCost;
  final double estimatedActivityCost;

  GeminiItineraryResponse({
    required this.accommodationOptions,
    required this.dayPlans,
    required this.estimatedFoodCost,
    required this.estimatedTransportCost,
    required this.estimatedActivityCost,
  });

  factory GeminiItineraryResponse.fromMap(Map<String, dynamic> map) {
    return GeminiItineraryResponse(
      accommodationOptions: (map['accommodation_options'] as List<dynamic>)
          .map((item) => AccommodationOption.fromMap(
                item as Map<String, dynamic>,
              ))
          .toList(),
      dayPlans: (map['day_plans'] as List<dynamic>)
          .cast<Map<String, dynamic>>(),
      estimatedFoodCost:
          (map['estimated_food_cost'] as num).toDouble(),
      estimatedTransportCost:
          (map['estimated_transport_cost'] as num).toDouble(),
      estimatedActivityCost:
          (map['estimated_activity_cost'] as num).toDouble(),
    );
  }
}