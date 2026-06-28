import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trip_genie/shared/theme/app_theme.dart';
import 'package:trip_genie/viewmodel/generate_itinerary_viewmodel.dart';

class ThemeSelection extends ConsumerStatefulWidget {
  const ThemeSelection({super.key});

  @override
  ConsumerState<ThemeSelection> createState() => _ThemeSelectionState();
}

class _ThemeSelectionState extends ConsumerState<ThemeSelection> {
  /// Local selection — highlights a theme in the grid on tap.
  /// Only committed to the viewmodel when the arrow button is pressed.
  String? _selectedTheme;

  void _selectTheme(String theme) {
    setState(() => _selectedTheme = theme);
  }

  void _goToNextDay() {
    if (_selectedTheme == null) return;
    final viewmodel = ref.read(generateItineraryViewModelProvider.notifier);
    viewmodel.selectTheme(_selectedTheme!, viewmodel.totalDays);
    // Clear local selection so the widget shows the next day's grid cleanly.
    setState(() => _selectedTheme = null);
  }

  @override
  Widget build(BuildContext context) {
    final viewmodel = ref.read(generateItineraryViewModelProvider.notifier);
    final themes = viewmodel.themeOptions;
    final totalDays = viewmodel.totalDays;
    final currentDay = viewmodel.currentDayIndex;
    final isLastDay = currentDay + 1 >= totalDays;
    final themeChosen = _selectedTheme != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Title ──
        Text(
          'Choose a theme for each day',
          style: AppTheme.bodyMedium.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.normal,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),

        // ── Progress indicator ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Day dots
              ...List.generate(totalDays, (i) {
                final isActive = i == currentDay;
                final isDone = i < currentDay;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Container(
                    width: isActive ? 12 : 8,
                    height: isActive ? 12 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone
                          ? AppTheme.primaryColor
                          : isActive
                              ? AppTheme.primaryColor.withValues(alpha: 0.6)
                              : AppTheme.secondaryColor,
                    ),
                  ),
                );
              }),
              const SizedBox(width: 12),
              Text(
                'Day ${currentDay + 1} of $totalDays',
                style: AppTheme.bodySmall,
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // ── 2×2 grid of theme circles (shrinkWrap, no Expanded) ──
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: themes.map((theme) {
            final isSelected = _selectedTheme == theme;

            return GestureDetector(
              onTap: () => _selectTheme(theme),
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
                    _themeIcon(theme, isSelected),
                    const SizedBox(height: 8),
                    Text(
                      theme,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
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

        // ── Next day arrow button ──
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: themeChosen
              ? SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _goToNextDay,
                    style: AppTheme.primaryButtonStyle,
                    icon: Icon(
                      isLastDay
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                      size: 20,
                    ),
                    label: Text(
                      isLastDay ? 'Continue' : 'Next Day',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _themeIcon(String theme, bool isSelected) {
    final colorFilter = isSelected
        ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
        : ColorFilter.mode(
            AppTheme.primaryColor,
            BlendMode.srcIn,
          );

    switch (theme) {
      case 'Nature':
        return SvgPicture.asset(
          'assets/icons/nature.svg',
          width: 50,
          height: 50,
          colorFilter: colorFilter,
          fit: BoxFit.contain,
        );
      case 'Culinary':
        return SvgPicture.asset(
          'assets/icons/culinary.svg',
          width: 50,
          height: 50,
          colorFilter: colorFilter,
          fit: BoxFit.contain,
        );
      case 'Healing':
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/icons/healing.png',
            width: 50,
            height: 50,
            color: isSelected ? Colors.white : AppTheme.primaryColor,
            colorBlendMode: BlendMode.srcIn,
            fit: BoxFit.contain,
          ),
        );
      case 'Cultural':
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/icons/cultural.png',
            width: 50,
            height: 50,
            color: isSelected ? Colors.white : AppTheme.primaryColor,
            colorBlendMode: BlendMode.srcIn,
            fit: BoxFit.contain,
          ),
        );
      default:
        return const Icon(Icons.explore, size: 36);
    }
  }
}
