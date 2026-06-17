import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_genie/model/itinerary.dart';

/// State: Itinerary detail data
/// Methods: fetchItineraryDetail(), updateItinerary(), deleteItinerary()
class DetailItineraryViewmodel extends AsyncNotifier<Itinerary?> {
  late final int _itineraryId;

  @override
  Future<Itinerary?> build() async {
    // TODO: Implement initial fetch of itinerary detail
    return null;
  }

  /// Initialize viewmodel with itinerary ID
  void initialize(int itineraryId) {
    _itineraryId = itineraryId;
    // TODO: Trigger fetch after initialization
  }

  /// Fetch itinerary details by ID
  Future<void> fetchItineraryDetail(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // TODO: Implement fetch detail logic
      throw UnimplementedError('fetchItineraryDetail() not implemented');
    });
  }

  /// Update itinerary
  Future<void> updateItinerary(Itinerary itinerary) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // TODO: Implement update itinerary logic
      throw UnimplementedError('updateItinerary() not implemented');
    });
  }

  /// Delete itinerary
  Future<void> deleteItinerary(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // TODO: Implement delete itinerary logic
      throw UnimplementedError('deleteItinerary() not implemented');
    });
  }
}

final detailItineraryViewmodelProvider =
    AsyncNotifierProvider<DetailItineraryViewmodel, Itinerary?>(() {
  return DetailItineraryViewmodel();
});
