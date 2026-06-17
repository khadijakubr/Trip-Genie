import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_genie/model/itinerary.dart';

/// State: Generated Itinerary data
/// Methods: generateItinerary(), saveItinerary()
class GenerateItineraryViewmodel extends AsyncNotifier<Itinerary?> {
  @override
  Future<Itinerary?> build() async {
    // TODO: Implement initial state
    return null;
  }

  /// Generate new itinerary with given parameters
  Future<void> generateItinerary({
    required String destination,
    required int days,
    required String budget,
    required List<String> interests,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // TODO: Implement itinerary generation logic
      throw UnimplementedError('generateItinerary() not implemented');
    });
  }

  /// Save generated itinerary to database
  Future<void> saveItinerary() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // TODO: Implement save itinerary logic
      throw UnimplementedError('saveItinerary() not implemented');
    });
  }
}

final generateItineraryViewmodelProvider =
    AsyncNotifierProvider<GenerateItineraryViewmodel, Itinerary?>(() {
  return GenerateItineraryViewmodel();
});
