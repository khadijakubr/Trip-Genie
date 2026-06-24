import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trip_genie/shared/theme/app_theme.dart';
import 'package:trip_genie/viewmodel/auth_viewmodel.dart';
import 'package:trip_genie/viewmodel/home_viewmodel.dart';
import 'package:trip_genie/view/widgets/itinerary_card_widget.dart';
import 'package:trip_genie/view/widgets/home_widgets/empty_state_widget.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final itinerariesAsync = ref.watch(homeViewmodelProvider);

    final username = authState.user?.name ?? 'Traveler';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hi, $username! \u{1F44B}',
          style: AppTheme.headingSmall.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: itinerariesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Something went wrong.\nPull down to retry.',
            textAlign: TextAlign.center,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.errorColor),
          ),
        ),
        data: (itineraries) {
          final isEmpty = itineraries.isEmpty;

          if (isEmpty) {
            // ── State A: First-time user ──────────────
            return const Center(
              child: SingleChildScrollView(
                child: EmptyStateWidget(),
              ),
            );
          }

          // ── State B: Returning user ─────────────────
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 48),

                // Generate button area
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: FloatingActionButton(
                          onPressed: () => context.go('/generate'),
                          backgroundColor: AppTheme.primaryColor,
                          elevation: 4,
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.add_rounded,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Generate itinerary',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 56),

                // Recent Trips section title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Recent Trips',
                    style: AppTheme.headingMedium,
                  ),
                ),

                const SizedBox(height: 12),

                // Grid of itinerary cards
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: itineraries.length,
                  itemBuilder: (context, index) {
                    return ItineraryCard(
                      itinerary: itineraries[index],
                    );
                  },
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
