import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database_helper.dart';
import '../model/itinerary.dart';
import '../model/day_plan.dart';
import '../model/activity.dart';
import 'package:sqflite/sqflite.dart';

class HomeRepository {

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // GET ITINERARY TERBARU UNTUK PREVIEW DI HOME
  // home hanya ambil beberapa untuk ditampilkan sebagai preview

  Future<List<Itinerary>> getRecentItineraries(
    String userId, {
    int limit = 4,  // default ambil 4 itinerary terbaru saja
  }) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'itineraries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: limit,  // batasi jumlah hasil
    );

    final itineraries = <Itinerary>[];
    for (final map in maps) {
      final dayPlans = await _getDayPlans(db, map['id'] as int);
      itineraries.add(Itinerary.fromMap(map, dayPlans));
    }

    return itineraries;
  }


  // CEK APAKAH USER SUDAH PUNYA ITINERARY
  // Dipakai untuk menentukan tampilan home:
  // - Belum punya → tampil "Generate First Itinerary"
  // - Sudah punya → tampil tombol generate + preview history
  Future<bool> hasItinerary(String userId) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'itineraries',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,  // cukup cek satu saja
    );

    // isEmpty = tidak ada itinerary sama sekali
    // isNotEmpty = sudah ada minimal satu itinerary
    return result.isNotEmpty;
  }

  Future<List<DayPlan>> _getDayPlans(Database db, int itineraryId) async {
    final maps = await db.query(
      'day_plans',
      where: 'itinerary_id = ?',
      whereArgs: [itineraryId],
      orderBy: 'day_number ASC',
    );

    final dayPlans = <DayPlan>[];
    for (final map in maps) {
      final activities = await _getActivities(db, map['id'] as int);
      dayPlans.add(DayPlan.fromMap(map, activities));
    }
    return dayPlans;
  }

  Future<List<Activity>> _getActivities(Database db, int dayPlanId) async {
    final maps = await db.query(
      'activities',
      where: 'day_plan_id = ?',
      whereArgs: [dayPlanId],
    );
    return maps.map((map) => Activity.fromMap(map)).toList() as List<Activity>;
  }
}

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository();
});