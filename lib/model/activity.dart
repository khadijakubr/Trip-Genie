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

  Map<String, dynamic> toMap() {
    return {
      'day_plan_id': dayPlanId,
      'time': time,
      'name': name,
      'description': description,
      'estimated_cost': estimatedCost,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] as int?,
      dayPlanId: map['day_plan_id'] as int,
      time: map['time'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      estimatedCost: map['estimated_cost'] as double,
    );
  }
}