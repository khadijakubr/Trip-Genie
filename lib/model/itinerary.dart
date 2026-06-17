import 'day_plan.dart';

class Itinerary {
  final int? id; // id di database SQLite
  final String userId; // id user yang membuat (dari Firebase Auth)
  final String destination; 
  final DateTime startDate; 
  final DateTime endDate; 
  final double budget; 
  final String? accommodation; 
  final double? accommodationCost;
  final double? foodCost;
  final double? transportCost;
  final double? activityCost;
  final double? totalCost;
  final List<DayPlan> dayPlans; 
  final DateTime createdAt;

  Itinerary({
    this.id,
    required this.userId,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.budget,
    this.accommodation,
    this.accommodationCost,
    this.foodCost,
    this.transportCost,
    this.activityCost,
    this.totalCost,
    required this.dayPlans,
    required this.createdAt,
  });
}