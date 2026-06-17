import 'activity.dart';

class DayPlan {
  final int? id;
  final int itineraryId;      // relasi ke itinerary
  final int dayNumber;        // hari ke-berapa (1, 2, 3...)
  final String theme;         // tema hari ini (alam, kuliner, dll)
  final List<Activity> activities; // daftar aktivitas di hari ini

  DayPlan({
    this.id,
    required this.itineraryId,
    required this.dayNumber,
    required this.theme,
    required this.activities,
  });
}