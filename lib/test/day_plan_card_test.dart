import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:trip_genie/model/activity.dart';
import 'package:trip_genie/model/day_plan.dart';
import 'package:trip_genie/view/widgets/detail_itinerary_widgets/day_plan_card_widget.dart';

void main() {
  // Set Indonesian locale so NumberFormat('#,###', 'id_ID') uses
  // dot (.) as thousands separator, e.g. Rp 50.000
  Intl.defaultLocale = 'id_ID';

  group('DayPlanCard', () {
    late DayPlan dayPlan;
    late NumberFormat currencyFormat;

    setUp(() {
      final activities = [
        Activity(
          id: 1,
          dayPlanId: 1,
          time: '08.00 - 10.00',
          name: 'Visit Borobudur',
          description: 'Explore the ancient temple.',
          estimatedCost: 50000,
        ),
        Activity(
          id: 2,
          dayPlanId: 1,
          time: '12.00 - 13.00',
          name: 'Lunch at Local Restaurant',
          description: 'Try authentic cuisine.',
          estimatedCost: 30000,
        ),
      ];

      dayPlan = DayPlan(
        id: 1,
        itineraryId: 1,
        dayNumber: 1,
        theme: 'Nature',
        activities: activities,
      );

      currencyFormat = NumberFormat('#,###', 'id_ID');
    });

    /// Helper to pump the DayPlanCard inside a MaterialApp + Scaffold
    /// so that text styles and themes resolve correctly.
    Future<void> pumpDayPlanCard(
      WidgetTester tester, {
      DayPlan? customDayPlan,
      int? customDayNumber,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DayPlanCard(
                dayPlan: customDayPlan ?? dayPlan,
                dayNumber: customDayNumber ?? 1,
                currencyFormat: currencyFormat,
              ),
            ),
          ),
        ),
      );
    }

    // ────────── Test 1: Header ──────────

    testWidgets('renders day header with number badge, title, and theme',
        (tester) async {
      await pumpDayPlanCard(tester);

      // Day number badge (the "1" inside the blue square)
      expect(find.text('1'), findsOneWidget);
      // Day title text
      expect(find.text('Day 1'), findsOneWidget);
      // Theme name
      expect(find.text('Nature'), findsOneWidget);
    });

    // ────────── Test 2: Activities ──────────

    testWidgets('renders all activities with time, name, description, cost',
        (tester) async {
      await pumpDayPlanCard(tester);

      // ── First activity ──
      expect(find.text('08.00 - 10.00'), findsOneWidget);
      expect(find.text('Visit Borobudur'), findsOneWidget);
      expect(find.text('Explore the ancient temple.'), findsOneWidget);
      expect(find.text('Rp 50.000'), findsOneWidget);

      // ── Second activity ──
      expect(find.text('12.00 - 13.00'), findsOneWidget);
      expect(find.text('Lunch at Local Restaurant'), findsOneWidget);
      expect(find.text('Try authentic cuisine.'), findsOneWidget);
      expect(find.text('Rp 30.000'), findsOneWidget);
    });

    // ────────── Test 3: Rupiah formatting ──────────

    testWidgets('cost is formatted in IDR with dot thousands separator',
        (tester) async {
      // Create a day plan with one expensive activity
      final expensiveDayPlan = DayPlan(
        id: 2,
        itineraryId: 1,
        dayNumber: 1,
        theme: 'Cultural',
        activities: [
          Activity(
            id: 3,
            dayPlanId: 2,
            time: '09.00 - 12.00',
            name: 'Museum Visit',
            description: 'Guided tour with professional guide.',
            estimatedCost: 150000,
          ),
        ],
      );

      await pumpDayPlanCard(tester, customDayPlan: expensiveDayPlan);

      // Indonesian format uses dot, not comma: 150.000 not 150,000
      expect(find.text('Rp 150.000'), findsOneWidget);
    });

    // ────────── Test 4: Empty activities ──────────

    testWidgets('renders card body with no activities list',
        (tester) async {
      final emptyDayPlan = DayPlan(
        id: 3,
        itineraryId: 1,
        dayNumber: 2,
        theme: 'Culinary',
        activities: [],
      );

      await pumpDayPlanCard(
        tester,
        customDayPlan: emptyDayPlan,
        customDayNumber: 2,
      );

      // Header still renders correctly for day 2
      expect(find.text('Day 2'), findsOneWidget);
      expect(find.text('Culinary'), findsOneWidget);

      // No activity widgets appear
      expect(find.text('08.00 - 10.00'), findsNothing);
    });
  });
}
