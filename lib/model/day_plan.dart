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

  Map<String, dynamic> toMap() {
    return {
      'itinerary_id': itineraryId,
      'day_number': dayNumber,
      'theme': theme,
      // activities tidak dimasukkan, disimpan di tabel terpisah
    };
  }

  factory DayPlan.fromMap(Map<String, dynamic> map, List<Activity> activities) {
    return DayPlan(
      id: map['id'] as int?,
      itineraryId: map['itinerary_id'] as int,
      dayNumber: map['day_number'] as int,
      theme: map['theme'] as String,
      activities: activities,
    );
  }
}