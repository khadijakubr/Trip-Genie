import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_genie/model/itinerary.dart';

/// State: List of historical itineraries
/// Methods: fetchHistory(), clearHistory()
class HistoryViewmodel extends AsyncNotifier<List<Itinerary>> {
  @override
  Future<List<Itinerary>> build() async {
    // TODO: Implement initial fetch of history
    return [];
  }

  /// Fetch user's itinerary history
  Future<void> fetchHistory() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // TODO: Implement fetch history logic
      throw UnimplementedError('fetchHistory() not implemented');
    });
  }

  /// Clear all history
  Future<void> clearHistory() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // TODO: Implement clear history logic
      throw UnimplementedError('clearHistory() not implemented');
    });
  }
}

final historyViewmodelProvider =
    AsyncNotifierProvider<HistoryViewmodel, List<Itinerary>>(() {
  return HistoryViewmodel();
});
