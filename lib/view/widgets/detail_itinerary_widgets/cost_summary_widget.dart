import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:trip_genie/model/itinerary.dart';
import 'package:trip_genie/shared/theme/app_theme.dart';

/// Card showing the budget breakdown: accommodation, food, transport,
/// activities, total, and the user's original input budget.
///
/// When [previewAccommodationCost] is provided (user has a local selection
/// not yet saved), it is used instead of the DB value and a "(preview)" label
/// is shown on the accommodation row.
class CostSummaryCard extends StatelessWidget {
  final Itinerary itinerary;
  final NumberFormat currencyFormat;
  final int? selectedAccommodationIndex;
  final double? previewAccommodationCost;
  final double? previewTotalCost;

  const CostSummaryCard({
    super.key,
    required this.itinerary,
    required this.currencyFormat,
    required this.selectedAccommodationIndex,
    this.previewAccommodationCost,
    this.previewTotalCost,
  });

  @override
  Widget build(BuildContext context) {
    final foodCost = itinerary.foodCost ?? 0.0;
    final transportCost = itinerary.transportCost ?? 0.0;
    final activityCost = itinerary.activityCost ?? 0.0;
    final accommodationCost =
        previewAccommodationCost ?? itinerary.accommodationCost ?? 0.0;
    final totalCost = previewTotalCost ?? itinerary.totalCost ?? 0.0;
    final inputBudget = itinerary.budget;
    final isPreview = previewAccommodationCost != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.secondaryColor, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _costRow(
            isPreview ? 'Accommodation (preview)' : 'Accommodation',
            accommodationCost,
            iconPath: 'assets/icons/accommodation.svg',
            isSelected: selectedAccommodationIndex != null,
          ),
          const Divider(height: 24),
          _costRow('Food', foodCost, iconPath: 'assets/icons/food.svg'),
          const SizedBox(height: 12),
          _costRow('Transport', transportCost,
              iconPath: 'assets/icons/transportation.svg'),
          const SizedBox(height: 12),
          _costRow('Activities', activityCost,
              iconPath: 'assets/icons/activity.svg'),
          const Divider(height: 24),
          // Total row — icon on left, amount on right (icon visible on white bg)
          _costRow(isPreview ? 'Total Budget (preview)' : 'Total Budget',
              totalCost,
              iconPath: 'assets/icons/budget.svg', isTotal: true),
          const SizedBox(height: 8),
          // Original input budget
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Budget',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                'Rp ${currencyFormat.format(inputBudget)}',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _costRow(
    String label,
    double amount, {
    String? iconPath,
    bool isTotal = false,
    bool isSelected = false,
  }) {
    final iconWidget = iconPath != null
        ? SvgPicture.asset(
            iconPath,
            width: 15,
            height: 15,
            colorFilter: ColorFilter.mode(
              // 🐛 FIX: was `Colors.white` for isTotal — invisible on white card bg
              // Now uses primaryColor so it's always visible
              AppTheme.primaryColor,
              BlendMode.srcIn,
            ),
          )
        : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ── Left: icon + label (icons always on left) ──
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Icon(Icons.check_circle,
                  size: 16, color: AppTheme.primaryColor),
            if (isSelected) const SizedBox(width: 6),
            if (iconWidget != null) ...[
              iconWidget,
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: isTotal ? 15 : 13,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        // ── Right: amount only ──
        Text(
          'Rp ${currencyFormat.format(amount)}',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? AppTheme.primaryColor : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
