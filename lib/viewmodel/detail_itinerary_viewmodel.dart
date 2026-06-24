import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/itinerary.dart';
import '../model/accommodation_option.dart';
import '../repository/detail_itinerary_repository.dart';

class DetailItineraryState {
  final Itinerary? itinerary;
  final List<AccommodationOption> accommodationOptions;
  final bool accommodationSelected;
  final bool isLoading;
  final String? errorMessage;

  const DetailItineraryState({
    this.itinerary,
    this.accommodationOptions = const [],
    this.accommodationSelected = false,
    this.isLoading = false,
    this.errorMessage,
  });

  DetailItineraryState copyWith({
    Itinerary? itinerary,
    List<AccommodationOption>? accommodationOptions,
    bool? accommodationSelected,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DetailItineraryState(
      itinerary: itinerary ?? this.itinerary,
      accommodationOptions:
          accommodationOptions ?? this.accommodationOptions,
      accommodationSelected:
          accommodationSelected ?? this.accommodationSelected,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

//Notifier biasa
class DetailItineraryViewModel extends Notifier<DetailItineraryState> {

  @override
  DetailItineraryState build() {
    // State awal kosong — data diload via loadItinerary()
    return const DetailItineraryState();
  }

  Future<void> loadItinerary(
    int itineraryId,
    List<AccommodationOption> accommodationOptions,
  ) async {
    // state sekarang dikenali karena extends Notifier dengan benar
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final itinerary = await ref
          .read(detailItineraryRepositoryProvider)
          .getItineraryById(itineraryId);

      state = state.copyWith(
        itinerary: itinerary,
        accommodationOptions: accommodationOptions,
        accommodationSelected: itinerary?.accommodation != null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> selectAccommodation(
    int itineraryId,
    AccommodationOption option,
  ) async {
    state = state.copyWith(isLoading: true);

    try {
      await ref
          .read(detailItineraryRepositoryProvider)
          .updateAccommodation(
            itineraryId: itineraryId,
            accommodation: option.name,
            accommodationCost: option.totalPrice,
          );

      // Reload agar data terbaru tampil setelah update
      await loadItinerary(
        itineraryId,
        state.accommodationOptions,
      );

      state = state.copyWith(
        accommodationSelected: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

// Ganti autoDispose menjadi NotifierProvider biasa
final detailItineraryViewModelProvider =
    NotifierProvider<DetailItineraryViewModel, DetailItineraryState>(
  DetailItineraryViewModel.new,
);