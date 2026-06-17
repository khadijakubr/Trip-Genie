import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_genie/model/itinerary.dart';

/// State: List of Itineraries (user's itineraries on home)
/// Methods: fetchItineraries(), deleteItinerary()
class HomeViewmodel extends AsyncNotifier<List<Itinerary>> {
  @override
  Future<List<Itinerary>> build() async {
    // TODO: Implement initial fetch of itineraries
    return [];
  }

  /// Fetch all user itineraries
  Future<void> fetchItineraries() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // TODO: Implement fetch itineraries logic
      throw UnimplementedError('fetchItineraries() not implemented');
    });
  }

  /// Delete an itinerary by ID
  Future<void> deleteItinerary(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // TODO: Implement delete itinerary logic
      throw UnimplementedError('deleteItinerary() not implemented');
    });
  }
}

final homeViewmodelProvider =
    AsyncNotifierProvider<HomeViewmodel, List<Itinerary>>(() {
  return HomeViewmodel();
});
