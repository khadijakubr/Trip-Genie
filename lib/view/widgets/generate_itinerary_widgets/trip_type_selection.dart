import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_genie/shared/theme/app_theme.dart';
import 'package:trip_genie/viewmodel/generate_itinerary_viewmodel.dart';

class TripTypeSelection extends ConsumerWidget {
  final VoidCallback onGenerate;

  const TripTypeSelection({super.key, required this.onGenerate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(generateItineraryViewModelProvider);
    final viewmodel = ref.read(generateItineraryViewModelProvider.notifier);
    final options = viewmodel.tripTypeOptionsList;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),

        // Title
        Text(
          'Who are you traveling with?',
          style: AppTheme.bodyMedium.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.normal,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 24),

        // 2x2 grid of trip type cards (shrinkWrap, no Expanded)
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: options.map((type) {
            final isSelected = state.selectedTripType == type;

            return GestureDetector(
              onTap: () => viewmodel.selectTripType(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.backgroundColor,
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.secondaryColor,
                    width: isSelected ? 3 : 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryColor
                                .withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _typeIcon(type, isSelected),
                    const SizedBox(height: 8),
                    Text(
                      type,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // Generate button — only visible after a trip type is selected
        if (state.selectedTripType != null)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onGenerate,
              style: AppTheme.primaryButtonStyle,
              child: const Text(
                'Generate My Itinerary',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _typeIcon(String type, bool isSelected) {
    final icon = Image.asset(
      'assets/icons/${type.toLowerCase()}.png',
      width: 48,
      height: 48,
      color: isSelected ? Colors.white : AppTheme.primaryColor,
      colorBlendMode: BlendMode.srcIn,
      fit: BoxFit.contain,
    );

    return icon;
  }
}
