import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_genie/shared/theme/app_theme.dart';
import 'package:trip_genie/viewmodel/history_viewmodel.dart';
import 'package:trip_genie/view/widgets/itinerary_card_widget.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itinerariesAsync = ref.watch(historyViewmodelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Trips',
          style: TextStyle(
            fontFamily: 'Gloock',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppTheme.errorColor),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load trips',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(historyViewmodelProvider.notifier).fetchHistory(),
                  style: AppTheme.primaryButtonStyle,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (itineraries) {
          if (itineraries.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_outlined,
                      size: 64, color: AppTheme.textSecondary),
                  SizedBox(height: 16),
                  Text(
                    'No trips yet',
                    style: TextStyle(
                      fontFamily: 'Gloock',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Generate your first itinerary\nto see it here',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: itineraries.length,
            itemBuilder: (context, index) {
              final itinerary = itineraries[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: ItineraryCard(itinerary: itinerary),
              );
            },
          );
        },
      ),
    );
  }
}
