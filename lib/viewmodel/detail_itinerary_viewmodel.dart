import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/itinerary.dart';
import '../model/accommodation_option.dart';
import '../repository/detail_itinerary_repository.dart';
import '../shared/providers/accommodation_provider.dart';

class DetailItineraryState {
  final Itinerary? itinerary;
  final List<AccommodationOption> accommodationOptions;
  final int? selectedAccommodationIndex;
  final bool isLoading;
  final String? errorMessage;

  const DetailItineraryState({
    this.itinerary,
    this.accommodationOptions = const [],
    this.selectedAccommodationIndex,
    this.isLoading = true,
    this.errorMessage,
  });

  /// Total number of trip days (derived from itinerary dates).
  int get totalDays {
    if (itinerary == null) return 1;
    return itinerary!.endDate.difference(itinerary!.startDate).inDays + 1;
  }

  /// The accommodation cost from the locally-selected option, or null if
  /// nothing is selected locally (falls back to DB-saved value).
  double? get previewAccommodationCost {
    if (selectedAccommodationIndex != null &&
        selectedAccommodationIndex! < accommodationOptions.length) {
      return accommodationOptions[selectedAccommodationIndex!].totalPrice;
    }
    return null;
  }

  /// The effective accommodation cost — preview if locally selected,
  /// otherwise the DB-saved value.
  double get effectiveAccommodationCost =>
      previewAccommodationCost ?? itinerary?.accommodationCost ?? 0.0;

  /// The effective total cost — computed from the preview accommodation
  /// cost (if any) plus the fixed food/transport/activity costs.
  double get effectiveTotalCost {
    final base = (itinerary?.foodCost ?? 0) +
        (itinerary?.transportCost ?? 0) +
        (itinerary?.activityCost ?? 0);
    return base + effectiveAccommodationCost;
  }

  /// Whether the user has a locally-selected accommodation that differs
  /// from what is saved in the database.
  bool get hasUnsavedAccommodation {
    if (selectedAccommodationIndex == null) return false;
    if (itinerary?.accommodation == null) return true;
    final selected = accommodationOptions[selectedAccommodationIndex!];
    return selected.name != itinerary!.accommodation;
  }

  DetailItineraryState copyWith({
    Itinerary? itinerary,
    List<AccommodationOption>? accommodationOptions,
    int? selectedAccommodationIndex,
    bool clearSelectedIndex = false,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DetailItineraryState(
      itinerary: itinerary ?? this.itinerary,
      accommodationOptions:
          accommodationOptions ?? this.accommodationOptions,
      selectedAccommodationIndex: clearSelectedIndex
          ? null
          : selectedAccommodationIndex ?? this.selectedAccommodationIndex,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class DetailItineraryViewModel extends Notifier<DetailItineraryState> {
  @override
  DetailItineraryState build() {
    return const DetailItineraryState();
  }

  /// Clears stale accommodation options from the global provider if the
  /// current itinerary is not the one that was just generated.
  /// When [freshItineraryIdProvider] is null (re-visit, not from generate),
  /// the provider is left untouched so options persist across page navigations.
  void _clearStaleOptions(int itineraryId) {
    final freshId = ref.read(freshItineraryIdProvider);
    if (freshId == null) return; // Not from generate — keep provider as-is
    if (freshId != itineraryId) {
      ref.read(accommodationOptionsProvider.notifier).state = [];
    }
    ref.read(freshItineraryIdProvider.notifier).state = null;
  }

  /// Loads the itinerary and resolves the selected accommodation index
  /// from the global provider.
  Future<void> loadItinerary(int itineraryId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Clear stale accommodation options from the global provider
      _clearStaleOptions(itineraryId);

      final itinerary = await ref
          .read(detailItineraryRepositoryProvider)
          .getItineraryById(itineraryId);

      if (itinerary == null) {
        state = state.copyWith(
          errorMessage: 'Itinerary tidak ditemukan',
          isLoading: false,
        );
        return;
      }

      final options = ref.read(accommodationOptionsProvider);
      int? selectedIndex;
      if (itinerary.accommodation != null) {
        selectedIndex = options.indexWhere(
          (o) => o.name == itinerary.accommodation,
        );
        if (selectedIndex == -1) selectedIndex = null;
      }

      state = state.copyWith(
        itinerary: itinerary,
        accommodationOptions: options,
        selectedAccommodationIndex: selectedIndex,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Selects an accommodation option locally (no DB write).
  /// User can freely tap different options — changes are previewed live
  /// in the cost summary and only persisted when [saveAccommodation] is called.
  void selectAccommodation(int index) {
    if (index >= state.accommodationOptions.length) return;
    state = state.copyWith(selectedAccommodationIndex: index);
  }

  /// Persists the locally-selected accommodation to the database and reloads.
  /// Called when the user taps "Continue to My Trips".
  Future<void> saveAccommodation(int itineraryId) async {
    if (state.selectedAccommodationIndex == null) return;

    final option =
        state.accommodationOptions[state.selectedAccommodationIndex!];

    try {
      await ref
          .read(detailItineraryRepositoryProvider)
          .updateAccommodation(
            itineraryId: itineraryId,
            accommodation: option.name,
            accommodationCost: option.totalPrice,
          );

      // Reload so the DB-saved values are reflected in state
      await loadItinerary(itineraryId);
    } catch (e) {
      state = state.copyWith(
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