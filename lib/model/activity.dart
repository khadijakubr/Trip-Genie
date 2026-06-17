class Activity {
  final int? id;
  final int dayPlanId;        // relasi ke day_plan
  final String time;          // contoh: "08.00 - 10.00"
  final String name;          // nama aktivitas/tempat
  final String description;   // deskripsi singkat
  final double estimatedCost; // estimasi biaya aktivitas ini

  Activity({
    this.id,
    required this.dayPlanId,
    required this.time,
    required this.name,
    required this.description,
    required this.estimatedCost,
  });
}