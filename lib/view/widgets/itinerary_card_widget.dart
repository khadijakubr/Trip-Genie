import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:trip_genie/model/itinerary.dart';

/// Generates a gradient pair based on destination name for visual variety.
List<Color> _gradientForDestination(String destination) {
  final hash = destination.hashCode.abs();
  final variants = <List<Color>>[
    [const Color(0xFF004AAD), const Color(0xFF6FB3D8)],
    [const Color(0xFF0D5E9E), const Color(0xFFA1D7E8)],
    [const Color(0xFF003580), const Color(0xFF5BA3C9)],
    [const Color(0xFF1A6FB0), const Color(0xFF89C5DC)],
    [const Color(0xFF002D6E), const Color(0xFF78BED4)],
    [const Color(0xFF084C8A), const Color(0xFF95CFE2)],
  ];
  return variants[hash % variants.length];
}

/// Reusable itinerary card with gradient background.
/// Used on the home page and can also be reused on the history page.
class ItineraryCard extends StatelessWidget {
  final Itinerary itinerary;

  const ItineraryCard({super.key, required this.itinerary});

  @override
  Widget build(BuildContext context) {
    final colors = _gradientForDestination(itinerary.destination);
    final dateFormat = DateFormat('MMM dd');
    final dateRange =
        '${dateFormat.format(itinerary.startDate)} - ${dateFormat.format(itinerary.endDate)}';

    return GestureDetector(
      onTap: () => context.go('/detail/${itinerary.id}'),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 150),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Destination name
              Text(
                itinerary.destination,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // Date range with calendar icon
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      dateRange,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
