import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:trip_genie/shared/theme/app_theme.dart';
import 'package:trip_genie/viewmodel/detail_itinerary_viewmodel.dart';
import 'package:trip_genie/view/widgets/detail_itinerary_widgets/accomodation_card_widget.dart';
import 'package:trip_genie/view/widgets/detail_itinerary_widgets/cost_summary_widget.dart';
import 'package:trip_genie/view/widgets/detail_itinerary_widgets/day_plan_card_widget.dart';

class DetailItineraryPage extends ConsumerStatefulWidget {
  final int itineraryId;

  const DetailItineraryPage({
    super.key,
    required this.itineraryId,
  });

  @override
  ConsumerState<DetailItineraryPage> createState() =>
      _DetailItineraryPageState();
}

class _DetailItineraryPageState extends ConsumerState<DetailItineraryPage> {
  final _dateFormat = DateFormat('dd MMMM yyyy');
  final _currencyFormat = NumberFormat('#,###', 'id_ID');

  @override
  void initState() {
    super.initState();
    // Defer provider modifications to after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(detailItineraryViewModelProvider.notifier)
          .loadItinerary(widget.itineraryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(detailItineraryViewModelProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: _buildBody(state),
    );
  }

  Widget _buildBody(DetailItineraryState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(state.errorMessage!, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    final itinerary = state.itinerary!;
    final totalDays = state.totalDays;
    final accommodationOptions = state.accommodationOptions;
    final hasAccommodationOptions = accommodationOptions.isNotEmpty;
    final hasSavedAccommodation = itinerary.accommodation != null;

    return CustomScrollView(
      slivers: [
        // ═══════════════════════════════════════
        // APP BAR — collapsible banner
        // ═══════════════════════════════════════
        SliverAppBar(
          expandedHeight: 180,
          pinned: true,
          backgroundColor: AppTheme.primaryColor,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          // Title shown in the toolbar when collapsed
          title: Text(
            itinerary.destination,
            style: const TextStyle(
              fontFamily: 'Gloock',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          // Expanded background with big city name + dates
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.secondaryColor.withValues(alpha: 0.8),
                  ],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Big city name in the banner
                  Text(
                    itinerary.destination,
                    style: const TextStyle(
                      fontFamily: 'Gloock',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Date
                  Text(
                    '${_dateFormat.format(itinerary.startDate)} — ${_dateFormat.format(itinerary.endDate)}  ·  $totalDays days',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ═══════════════════════════════════════
        // CONTENT
        // ═══════════════════════════════════════
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── 1. Accommodation Options ──
              if (hasAccommodationOptions || hasSavedAccommodation) ...[
                _sectionHeader(
                  'Accommodation',
                  subtitle: hasAccommodationOptions
                      ? 'Select one of the options below'
                      : 'Saved accommodation',
                ),
                const SizedBox(height: 12),
                if (hasAccommodationOptions)
                  ...List.generate(accommodationOptions.length, (i) {
                    final option = accommodationOptions[i];
                    final isSelected = state.selectedAccommodationIndex == i;
                    return AccommodationCard(
                      option: option,
                      isSelected: isSelected,
                      currencyFormat: _currencyFormat,
                      onTap: () => ref
                          .read(detailItineraryViewModelProvider.notifier)
                          .selectAccommodation(i),
                    );
                  }),
                if (!hasAccommodationOptions && hasSavedAccommodation)
                  SavedAccommodationCard(
                    name: itinerary.accommodation!,
                    cost: itinerary.accommodationCost ?? 0,
                    currencyFormat: _currencyFormat,
                  ),
                const SizedBox(height: 24),
              ],

              // ── 2. Day-by-Day Itinerary ──
              _sectionHeader('Your Itinerary'),
              const SizedBox(height: 12),
              ...List.generate(itinerary.dayPlans.length, (i) {
                final dayPlan = itinerary.dayPlans[i];
                return DayPlanCard(
                  dayPlan: dayPlan,
                  dayNumber: i + 1,
                  currencyFormat: _currencyFormat,
                );
              }),
              const SizedBox(height: 32),

              // ── 3. Budget Overview (at bottom) ──
              _sectionHeader('Budget Overview',
                  subtitle: 'Estimated cost breakdown'),
              const SizedBox(height: 12),
              CostSummaryCard(
                itinerary: itinerary,
                currencyFormat: _currencyFormat,
                selectedAccommodationIndex: state.selectedAccommodationIndex,
                previewAccommodationCost: state.previewAccommodationCost,
                previewTotalCost: state.effectiveTotalCost,
              ),
              const SizedBox(height: 32),

              // ── 4. Continue button ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () async {
                          if (state.hasUnsavedAccommodation) {
                            await ref
                                .read(
                                    detailItineraryViewModelProvider.notifier)
                                .saveAccommodation(widget.itineraryId);
                          }
                          if (mounted) {
                            context.go('/history');
                          }
                        },
                  style: AppTheme.primaryButtonStyle,
                  icon: state.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.history_rounded, size: 20),
                  label: Text(
                    state.isLoading
                        ? 'Saving…'
                        : 'Continue to My Trips',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Gloock',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
