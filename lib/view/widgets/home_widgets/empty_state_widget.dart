import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trip_genie/shared/theme/app_theme.dart';

/// Empty state shown to first-time users with no itineraries yet.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bot / magic wand icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 40,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),

            // Main message
            Text(
              "I'm Trip Genie,\nyour travel buddy!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Gloock',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            // Subtitle
            Text(
              "Let's plan your first adventure",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),

            // Generate button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.go('/generate'),
                style: AppTheme.primaryButtonStyle,
                child: const Text(
                  'Generate Your First Itinerary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
