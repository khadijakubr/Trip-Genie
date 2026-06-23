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

  // toMap() digunakan untuk mengubah objek Itinerary menjadi Map untuk disimpan ke SQLite
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'destination': destination,
      'start_date': startDate.toIso8601String(),  // DateTime dikonversi ke String karena SQLite tidak punya tipe DateTime
      'end_date': endDate.toIso8601String(),
      'budget': budget,
      'accommodation': accommodation,
      'accommodation_cost': accommodationCost,
      'food_cost': foodCost,
      'transport_cost': transportCost,
      'activity_cost': activityCost,
      'total_cost': totalCost,
      'created_at': createdAt.toIso8601String(),
      // dayPlans tidak dimasukkan karena disimpan di tabel terpisah
    };
  }

  // fromMap() digunakan untuk mengubah Map dari SQLite kembali menjadi objek Itinerary
  factory Itinerary.fromMap(Map<String, dynamic> map, List<DayPlan> dayPlans) {
    return Itinerary(
      id: map['id'] as int?,
      userId: map['user_id'] as String,
      destination: map['destination'] as String,
      startDate: DateTime.parse(map['start_date'] as String), // String dikonversi kembali ke DateTime menggunakan parse()
      endDate: DateTime.parse(map['end_date'] as String),
      budget: map['budget'] as double,
      accommodation: map['accommodation'] as String?,
      accommodationCost: map['accommodation_cost'] as double?,
      foodCost: map['food_cost'] as double?,
      transportCost: map['transport_cost'] as double?,
      activityCost: map['activity_cost'] as double?,
      totalCost: map['total_cost'] as double?,
      dayPlans: dayPlans,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}