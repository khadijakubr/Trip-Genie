import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_genie/model/itinerary.dart';
import 'package:trip_genie/repository/home_repository.dart';
import 'package:trip_genie/viewmodel/auth_viewmodel.dart';

/// State: List of recent itineraries for the home screen.
/// Empty list means first-time user (State A).
class HomeViewmodel extends AsyncNotifier<List<Itinerary>> {
  @override
  Future<List<Itinerary>> build() async {
    final authState = ref.watch(authViewModelProvider);
    final userId = authState.user?.id;
    if (userId == null) return [];

    final repository = ref.read(homeRepositoryProvider);
    return repository.getRecentItineraries(userId, limit: 4);
  }

  /// Refresh the itineraries list from the database.
  Future<void> refreshItineraries() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authState = ref.read(authViewModelProvider);
      final userId = authState.user?.id;
      if (userId == null) return <Itinerary>[];

      final repository = ref.read(homeRepositoryProvider);
      return repository.getRecentItineraries(userId, limit: 4);
    });
  }
}

final homeViewmodelProvider =
    AsyncNotifierProvider<HomeViewmodel, List<Itinerary>>(() {
  return HomeViewmodel();
});
