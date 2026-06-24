import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trip_genie/model/accommodation_option.dart';
import 'package:trip_genie/shared/theme/app_theme.dart';

/// Selectable accommodation card — shows one of the 3 Gemini options.
class AccommodationCard extends StatelessWidget {
  final AccommodationOption option;
  final bool isSelected;
  final NumberFormat currencyFormat;
  final VoidCallback onTap;

  const AccommodationCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.currencyFormat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.secondaryColor,
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.secondaryColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.hotel_rounded,
                  color: isSelected ? Colors.white : AppTheme.primaryColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.name,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${currencyFormat.format(option.pricePerNight)} / night',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: option.facilities.map((f) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                                : AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            f,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Total price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rp ${currencyFormat.format(option.totalPrice)}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${option.facilities.length} facilities',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Selected',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Saved (non-interactive) accommodation card shown when navigating
/// from history where `accommodationOptionsProvider` is empty.
class SavedAccommodationCard extends StatelessWidget {
  final String name;
  final double cost;
  final NumberFormat currencyFormat;

  const SavedAccommodationCard({
    super.key,
    required this.name,
    required this.cost,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.hotel_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Saved',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Rp ${currencyFormat.format(cost)}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
