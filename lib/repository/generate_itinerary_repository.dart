import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/database_helper.dart';
import '../model/gemini_response.dart';
import '../model/trip_request.dart';

class GenerateItineraryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> saveGeneratedItinerary({
    required TripRequest request,
    required GeminiItineraryResponse geminiResponse,
  }) async {
    final db = await _dbHelper.database;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User tidak ditemukan');

    return await db.transaction((txn) async {
      final itineraryId = await txn.insert('itineraries', {
        'user_id': userId,
        'destination': request.destination,
        'start_date': request.startDate.toIso8601String(),
        'end_date': request.endDate.toIso8601String(),
        'budget': request.budget,
        'accommodation': null,
        'accommodation_cost': null,
        'food_cost': geminiResponse.estimatedFoodCost,
        'transport_cost': geminiResponse.estimatedTransportCost,
        'activity_cost': geminiResponse.estimatedActivityCost,
        'total_cost': null,
        'created_at': DateTime.now().toIso8601String(),
      });

      for (final dayPlanMap in geminiResponse.dayPlans) {
        final dayPlanId = await txn.insert('day_plans', {
          'itinerary_id': itineraryId,
          'day_number': dayPlanMap['day_number'] as int,
          'theme': dayPlanMap['theme'] as String,
        });

        final activities = dayPlanMap['activities'] as List<dynamic>;
        for (final activityMap in activities) {
          await txn.insert('activities', {
            'day_plan_id': dayPlanId,
            'time': activityMap['time'] as String,
            'name': activityMap['name'] as String,
            'description': activityMap['description'] as String,
            'estimated_cost':
                (activityMap['estimated_cost'] as num).toDouble(),
          });
        }
      }

      return itineraryId;
    });
  }
  // ← kurung tutup class ada di sini, setelah semua method selesai
}

final generateItineraryRepositoryProvider =
    Provider<GenerateItineraryRepository>((ref) {
  return GenerateItineraryRepository();
});