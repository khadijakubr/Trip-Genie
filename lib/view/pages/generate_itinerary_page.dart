import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trip_genie/shared/theme/app_theme.dart';
import 'package:trip_genie/viewmodel/generate_itinerary_viewmodel.dart';
import 'package:trip_genie/view/widgets/generate_itinerary_widgets/trip_details_form.dart';
import 'package:trip_genie/view/widgets/generate_itinerary_widgets/theme_selection.dart';
import 'package:trip_genie/view/widgets/generate_itinerary_widgets/trip_type_selection.dart';
import 'package:trip_genie/view/widgets/generate_itinerary_widgets/loading_screen.dart';

class GenerateItineraryPage extends ConsumerStatefulWidget {
  const GenerateItineraryPage({super.key});

  @override
  ConsumerState<GenerateItineraryPage> createState() =>
      _GenerateItineraryPageState();
}

class _GenerateItineraryPageState
    extends ConsumerState<GenerateItineraryPage> {
  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController();
  DateTime? _departureDate;
  DateTime? _returnDate;

  @override
  void dispose() {
    _destinationController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  /// Reset the viewmodel state on page entry if it's stuck at `done` or `loading`
  /// from a previous generation session.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = ref.read(generateItineraryViewModelProvider);
      if (current.currentStep == GenerateStep.done ||
          current.currentStep == GenerateStep.loading) {
        ref.read(generateItineraryViewModelProvider.notifier).reset();
      }
    });
  }

  Future<void> _pickDate({required bool isDeparture}) async {
    final now = DateTime.now();
    DateTime firstDate;
    DateTime lastDate = now.add(const Duration(days: 365 * 2));

    if (isDeparture) {
      firstDate = now;
      if (_returnDate != null && _returnDate!.isAfter(now)) {
        lastDate = _returnDate!;
      }
    } else {
      firstDate = _departureDate ?? now;
      // Limit return date to departure + 6 days (max 7 total)
      if (_departureDate != null) {
        final maxReturn =
            _departureDate!.add(Duration(days: GenerateItineraryViewModel.maxDays - 1));
        if (maxReturn.isBefore(lastDate)) {
          lastDate = maxReturn;
        }
      }
    }

    // Use the previously selected date as the picker's initial view, or
    // fall back to now / firstDate if nothing has been picked yet.
    final DateTime initialDate;
    if (isDeparture) {
      initialDate = _departureDate ?? now;
    } else {
      initialDate = _returnDate ?? _departureDate ?? now;
    }
    // Clamp to the allowed range in case constraints changed
    final clamped = initialDate.isBefore(firstDate)
        ? firstDate
        : initialDate.isAfter(lastDate)
            ? lastDate
            : initialDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: clamped,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departureDate = picked;
          if (_returnDate != null && _returnDate!.isBefore(picked)) {
            _returnDate = null;
          }
        } else {
          _returnDate = picked;
        }
      });
    }
  }

  void _handleSubmit() {
    final viewmodel = ref.read(generateItineraryViewModelProvider.notifier);

    // Validate via viewmodel
    final error = viewmodel.validateTripDetails(
      destination: _destinationController.text,
      startDate: _departureDate,
      endDate: _returnDate,
      budgetText: _budgetController.text,
    );
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    final success = viewmodel.submitTripDetails(
      destination: _destinationController.text,
      startDate: _departureDate,
      endDate: _returnDate,
      budgetText: _budgetController.text,
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please check your inputs')),
      );
    }
  }

  Future<void> _handleGenerate() async {
    final viewmodel = ref.read(generateItineraryViewModelProvider.notifier);
    await viewmodel.generateItinerary();
  }

  void _goBack() {
    final current = ref.read(generateItineraryViewModelProvider);
    if (current.currentStep == GenerateStep.tripDetails) {
      context.go('/home');
    } else {
      ref.read(generateItineraryViewModelProvider.notifier).reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<GenerateItineraryState>(
      generateItineraryViewModelProvider,
      (prev, next) {
        // ── Show API error messages ──
        if (next.errorMessage != null && next.currentStep != GenerateStep.loading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              backgroundColor: Colors.red.shade700,
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
          // Clear the error so it doesn't re-show on rebuilds
          ref
              .read(generateItineraryViewModelProvider.notifier)
              .clearError();
        }

        // ── Navigate to detail on success ──
        if (prev?.currentStep != GenerateStep.done &&
            next.currentStep == GenerateStep.done) {
          final id = next.savedItineraryId;
          if (id != null) {
            context.go('/detail/$id');
          } else {
            context.go('/home');
          }
        }
      },
    );

    final state = ref.watch(generateItineraryViewModelProvider);

    // ── Loading is full-screen overlay ──
    if (state.currentStep == GenerateStep.loading) {
      return const Scaffold(body: LoadingScreen());
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.secondaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // ── Centered card ──
              Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 420),
                    decoration: AppTheme.formCardDecoration,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      child: _buildStep(state),
                    ),
                  ),
                ),
              ),

              // ── Back button top-left ──
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white),
                  onPressed: _goBack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(GenerateItineraryState state) {
    switch (state.currentStep) {
      case GenerateStep.tripDetails:
        return TripDetailsForm(
          key: const ValueKey('step1'),
          destinationController: _destinationController,
          budgetController: _budgetController,
          departureDate: _departureDate,
          returnDate: _returnDate,
          onPickDeparture: () => _pickDate(isDeparture: true),
          onPickReturn: () => _pickDate(isDeparture: false),
          onSubmit: _handleSubmit,
        );

      case GenerateStep.themeSelection:
        return const ThemeSelection(
          key: ValueKey('step2'),
        );

      case GenerateStep.tripType:
        return TripTypeSelection(
          key: const ValueKey('step3'),
          onGenerate: _handleGenerate,
        );

      case GenerateStep.loading:
        return const SizedBox.shrink();

      case GenerateStep.done:
        return const SizedBox.shrink();
    }
  }
}
