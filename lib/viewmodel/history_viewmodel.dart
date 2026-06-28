import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_genie/model/itinerary.dart';
import 'package:trip_genie/repository/history_repository.dart';
import 'package:trip_genie/viewmodel/auth_viewmodel.dart';
import 'package:trip_genie/viewmodel/home_viewmodel.dart';

/// State: List of all itineraries belonging to the current user.
class HistoryViewmodel extends AsyncNotifier<List<Itinerary>> {
  @override
  Future<List<Itinerary>> build() async {
    final authState = ref.watch(authViewModelProvider);
    final userId = authState.user?.id;
    if (userId == null) return [];

    final repository = ref.read(historyRepositoryProvider);
    return repository.getAllItinerariesByUser(userId);
  }

  /// Fetch updated history from the database.
  Future<void> fetchHistory() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authState = ref.read(authViewModelProvider);
      final userId = authState.user?.id;
      if (userId == null) return <Itinerary>[];

      final repository = ref.read(historyRepositoryProvider);
      return repository.getAllItinerariesByUser(userId);
    });
  }

  /// Delete a single itinerary by id, then refresh both history and home.
  Future<void> deleteItinerary(int id) async {
    await ref.read(historyRepositoryProvider).deleteItinerary(id);
    ref.invalidate(homeViewmodelProvider);
    await fetchHistory();
  }
}

final historyViewmodelProvider =
    AsyncNotifierProvider<HistoryViewmodel, List<Itinerary>>(() {
  return HistoryViewmodel();
});
