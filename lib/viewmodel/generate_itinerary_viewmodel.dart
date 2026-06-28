import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../model/trip_request.dart';
import '../model/gemini_response.dart';
import '../services/gemini_services.dart';
import '../repository/generate_itinerary_repository.dart';
import '../shared/providers/accommodation_provider.dart';
import '../viewmodel/home_viewmodel.dart';
import '../viewmodel/history_viewmodel.dart';

// State untuk proses generate itinerary
class GenerateItineraryState {
  // Ganti int menjadi GenerateStep
  final GenerateStep currentStep;
  final bool isLoading;
  final String? errorMessage;
  final int? savedItineraryId;
  final GeminiItineraryResponse? geminiResponse;
  final List<String> selectedThemes;
  final String? selectedTripType;

  final String? destination;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? budget;

  const GenerateItineraryState({
    this.currentStep = GenerateStep.tripDetails,
    this.isLoading = false,
    this.errorMessage,
    this.savedItineraryId,
    this.geminiResponse,
    this.selectedThemes = const [],
    this.selectedTripType,
    this.destination,
    this.startDate,
    this.endDate,
    this.budget,
  });

  GenerateItineraryState copyWith({
    GenerateStep? currentStep,
    bool? isLoading,
    String? errorMessage,
    int? savedItineraryId,
    GeminiItineraryResponse? geminiResponse,
    List<String>? selectedThemes,
    String? selectedTripType,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
  }) {
    return GenerateItineraryState(
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      savedItineraryId: savedItineraryId ?? this.savedItineraryId,
      geminiResponse: geminiResponse ?? this.geminiResponse,
      selectedThemes: selectedThemes ?? this.selectedThemes,
      selectedTripType: selectedTripType ?? this.selectedTripType,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
    );
  }
}

enum GenerateStep {
  tripDetails,    // step 0 — form input
  themeSelection, // step 1 — pilih tema per hari
  tripType,       // step 2 — pilih tipe perjalanan
  loading,        // step 3 — loading generate
  done,           // step 4 — selesai
}

class GenerateItineraryViewModel
    extends Notifier<GenerateItineraryState> {
  static const int maxDays = 7;

  // ── Computed getters for widgets ──

  /// Total number of days in the trip (derived from start/end dates).
  int get totalDays {
    if (state.startDate == null || state.endDate == null) return 1;
    return state.endDate!.difference(state.startDate!).inDays + 1;
  }

  /// Which day the user is currently selecting a theme for.
  int get currentDayIndex => state.selectedThemes.length;

  /// The 4 theme options shown in the theme selection grid.
  List<String> get themeOptions => ['Nature', 'Culinary', 'Healing', 'Cultural'];

  /// The 4 trip type options shown in the trip type selection grid.
  List<String> get tripTypeOptionsList => ['Family', 'Couple', 'Solo', 'Friends'];

  @override
  GenerateItineraryState build() {
    // State awal — semua kosong, step pertama
    return const GenerateItineraryState();
  }

  /// Validates trip detail fields and returns a user-facing error message,
  /// or null if all fields are valid.
  String? validateTripDetails({
    required String destination,
    required DateTime? startDate,
    required DateTime? endDate,
    required String budgetText,
  }) {
    if (destination.trim().isEmpty) return 'Please enter a destination';
    if (startDate == null) return 'Please select a departure date';
    if (endDate == null) return 'Please select a return date';
    if (endDate.isBefore(startDate)) {
      return 'Return date must be after departure date';
    }

    final days = endDate.difference(startDate).inDays + 1;
    if (days > maxDays) return 'Maximum itinerary is $maxDays days';

    if (budgetText.trim().isEmpty) return 'Please enter a budget';
    final cleanBudget = budgetText.replaceAll('.', '');
    final budget = double.tryParse(cleanBudget.trim());
    if (budget == null || budget <= 0) return 'Budget must be a valid number';

    final minBudget = days * 250000.0;
    if (budget < minBudget) {
      return 'Minimum budget is Rp ${NumberFormat('#,###', 'id_ID').format(minBudget)} for $days day(s)';
    }

    return null;
  }

  // Dipanggil saat user submit form di Step 1
  // Berpindah ke Step 2 (pilih tema)
  bool submitTripDetails({
  required String destination,
  required DateTime? startDate,
  required DateTime? endDate,
  required String budgetText,
  }) {
    // Validasi di ViewModel
    if (destination.trim().isEmpty) return false;
    if (startDate == null || endDate == null) return false;
    if (endDate.isBefore(startDate)) return false;

    final days = endDate.difference(startDate).inDays + 1;
    if (days > maxDays) return false;

    // Strip Indonesian thousands separator (.) before parsing
    final cleanBudget = budgetText.replaceAll('.', '');
    final budget = double.tryParse(cleanBudget.trim());
    if (budget == null) return false;

    // Minimum budget: Rp 250.000 per hari
    final minBudget = days * 250000.0;
    if (budget < minBudget) return false;

    // Simpan data form ke state dan pindah ke step berikutnya
    state = state.copyWith(
      destination: destination.trim(),
      startDate: startDate,
      endDate: endDate,
      budget: budget,
      currentStep: GenerateStep.themeSelection,
    );

    return true;
  }

  // Dipanggil saat user pilih tema untuk satu hari
  void selectTheme(String theme, int totalDays) {
    final updatedThemes = [...state.selectedThemes, theme];
    // Kalau semua hari sudah dipilih temanya, lanjut ke Step 3
    if (updatedThemes.length >= totalDays) {
      state = state.copyWith(
        selectedThemes: updatedThemes,
        currentStep: GenerateStep.tripType,
      );
    } else {
      // Kalau belum semua, tetap di Step 2 dengan tema ter-update
      state = state.copyWith(selectedThemes: updatedThemes);
    }
  }

  // Dipanggil saat user pilih tipe perjalanan di Step 3
  void selectTripType(String tripType) {
    state = state.copyWith(selectedTripType: tripType);
  }

  // Method utama — generate itinerary via Gemini API
  // Dipanggil saat user tekan "Generate My Itinerary"
  Future<void> generateItinerary() async {
  // Validasi semua data yang dibutuhkan ada di state
  if (state.destination == null ||
      state.startDate == null ||
      state.endDate == null ||
      state.budget == null ||
      state.selectedTripType == null) {
    state = state.copyWith(
      errorMessage: 'Data perjalanan tidak lengkap',
      currentStep: GenerateStep.tripDetails,
    );
    return;
  }

  state = state.copyWith(
    isLoading: true,
    currentStep: GenerateStep.loading,
    errorMessage: null,
  );

  try {
    // Bangun TripRequest dari data yang tersimpan di state
    final request = TripRequest(
      destination: state.destination!,
      startDate: state.startDate!,
      endDate: state.endDate!,
      budget: state.budget!,
      themes: state.selectedThemes,
      tripType: state.selectedTripType!,
    );

    final geminiResponse = await ref
        .read(geminiServiceProvider)
        .generateItinerary(request);

    final itineraryId = await ref
        .read(generateItineraryRepositoryProvider)
        .saveGeneratedItinerary(
          request: request,
          geminiResponse: geminiResponse,
        );

    // Simpan accommodation options ke provider sementara
    ref.read(accommodationOptionsProvider.notifier).state =
        geminiResponse.accommodationOptions;
    ref.read(freshItineraryIdProvider.notifier).state = itineraryId;

    // Invalidate home & history providers so they refetch on next visit
    ref.invalidate(homeViewmodelProvider);
    ref.invalidate(historyViewmodelProvider);

    state = state.copyWith(
      isLoading: false,
      currentStep: GenerateStep.done,
      savedItineraryId: itineraryId,
      geminiResponse: geminiResponse,
    );
  } catch (e) {
    state = state.copyWith(
      isLoading: false,
      currentStep: GenerateStep.tripType,
      errorMessage: e.toString(),
    );
  }
}

  // Clear error message without changing step
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  // Reset state — dipanggil kalau user mau generate ulang
  void reset() {
    state = const GenerateItineraryState();
  }
}

final generateItineraryViewModelProvider =
    NotifierProvider<GenerateItineraryViewModel, GenerateItineraryState>(
  GenerateItineraryViewModel.new,
);