import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trip_genie/model/day_plan.dart';
import 'package:trip_genie/shared/theme/app_theme.dart';

/// Card for a single day's itinerary — shows the day number, theme,
/// and a list of activities with time, name, description, and cost.
class DayPlanCard extends StatelessWidget {
  final DayPlan dayPlan;
  final int dayNumber;
  final NumberFormat currencyFormat;

  const DayPlanCard({
    super.key,
    required this.dayPlan,
    required this.dayNumber,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.secondaryColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.06),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '$dayNumber',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day $dayNumber',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        dayPlan.theme,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Activities
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: dayPlan.activities.map((activity) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time column
                        SizedBox(
                          width: 80,
                          child: Text(
                            activity.time,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),

                        // Vertical divider dot
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 4, right: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),

                        // Activity details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.name,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                activity.description,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${currencyFormat.format(activity.estimatedCost)}',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
