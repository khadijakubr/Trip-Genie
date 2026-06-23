import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database_helper.dart';
import '../model/itinerary.dart';
import '../model/day_plan.dart';
import '../model/activity.dart';
import 'package:sqflite/sqflite.dart';

class DetailItineraryRepository {

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // GET DETAIL SATU ITINERARY BESERTA SEMUA DAY PLAN DAN ACTIVITY
  Future<Itinerary?> getItineraryById(int id) async {
    final db = await _dbHelper.database;

    // Ambil satu baris dari tabel itineraries yang id-nya cocok
    final itineraryMaps = await db.query(
      'itineraries',       
      where: 'id = ?',     
      whereArgs: [id],     // nilai yang menggantikan tanda ?
      limit: 1,            // hanya ambil 1 baris
    );

    // Kalau tidak ditemukan, kembalikan null
    if (itineraryMaps.isEmpty) return null;

    // Ambil semua day_plan milik itinerary ini
    final dayPlans = await _getDayPlans(db, id);

    // Gabungkan data itinerary dengan day_plans-nya
    return Itinerary.fromMap(itineraryMaps.first, dayPlans);
  }

  // UPDATE AKOMODASI
  // Dipanggil ketika user memilih salah satu kartu akomodasi
  // di halaman detail itinerary
  Future<void> updateAccommodation({
    required int itineraryId,
    required String accommodation,
    required double accommodationCost,
  }) async {
    final db = await _dbHelper.database;

    // Hitung total cost baru setelah akomodasi dipilih
    // Ambil dulu data itinerary yang ada untuk dapat cost lainnya
    final maps = await db.query(
      'itineraries',
      where: 'id = ?',
      whereArgs: [itineraryId],
      limit: 1,
    );

    if (maps.isEmpty) return;

    // Ambil nilai cost yang sudah ada (bisa null kalau belum diisi)
    // ?? 0.0 artinya: kalau null, pakai 0.0
    final foodCost = (maps.first['food_cost'] as double?) ?? 0.0;
    final transportCost = (maps.first['transport_cost'] as double?) ?? 0.0;
    final activityCost = (maps.first['activity_cost'] as double?) ?? 0.0;

    // Hitung total baru
    final totalCost = accommodationCost + foodCost + transportCost + activityCost;

    // update() mengubah baris yang sudah ada di database
    await db.update(
      'itineraries',
      {
        'accommodation': accommodation,
        'accommodation_cost': accommodationCost,
        'total_cost': totalCost,
      },
      where: 'id = ?',
      whereArgs: [itineraryId],
    );
  }

  // UPDATE COST SUMMARY LENGKAP
  // Dipanggil setelah semua biaya dihitung dari hasil generate Gemini
  Future<void> updateCostSummary({
    required int itineraryId,
    required double foodCost,
    required double transportCost,
    required double activityCost,
  }) async {
    final db = await _dbHelper.database;

    // Ambil accommodation cost yang sudah ada
    final maps = await db.query(
      'itineraries',
      where: 'id = ?',
      whereArgs: [itineraryId],
      limit: 1,
    );

    if (maps.isEmpty) return;

    final accommodationCost = (maps.first['accommodation_cost'] as double?) ?? 0.0;
    final totalCost = accommodationCost + foodCost + transportCost + activityCost;

    await db.update(
      'itineraries',
      {
        'food_cost': foodCost,
        'transport_cost': transportCost,
        'activity_cost': activityCost,
        'total_cost': totalCost,
      },
      where: 'id = ?',
      whereArgs: [itineraryId],
    );
  }

  // PRIVATE HELPERS
  Future<List<DayPlan>> _getDayPlans(Database db, int itineraryId) async {
    final dayPlanMaps = await db.query(
      'day_plans',
      where: 'itinerary_id = ?',
      whereArgs: [itineraryId],
      orderBy: 'day_number ASC',  // urutkan dari hari pertama ke terakhir
    );

    // Untuk setiap day_plan, ambil juga activities-nya
    final dayPlans = <DayPlan>[];
    for (final map in dayPlanMaps) {
      final activities = await _getActivities(db, map['id'] as int);
      dayPlans.add(DayPlan.fromMap(map, activities));
    }

    return dayPlans;
  }

  Future<List<Activity>> _getActivities(Database db, int dayPlanId) async {
    final activityMaps = await db.query(
      'activities',
      where: 'day_plan_id = ?',
      whereArgs: [dayPlanId],
    );

    // Konversi setiap Map menjadi objek Activity
    // .map() → loop dan transformasi
    // .toList() → ubah hasil loop menjadi List
    return activityMaps.map((map) => Activity.fromMap(map)).toList() as List<Activity>;
  }
}

final detailItineraryRepositoryProvider =
    Provider<DetailItineraryRepository>((ref) {
  return DetailItineraryRepository();
});