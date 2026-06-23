import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database_helper.dart';
import '../model/itinerary.dart';
import '../model/day_plan.dart';
import '../model/activity.dart';
import 'package:sqflite/sqflite.dart';

class HistoryRepository {

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // GET SEMUA ITINERARY MILIK USER
  Future<List<Itinerary>> getAllItinerariesByUser(String userId) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'itineraries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',  // terbaru di atas
    );

    // Untuk setiap itinerary, ambil juga day_plans-nya
    final itineraries = <Itinerary>[];
    for (final map in maps) {
      final dayPlans = await _getDayPlans(db, map['id'] as int);
      itineraries.add(Itinerary.fromMap(map, dayPlans));
    }

    return itineraries;
  }

  // DELETE ITINERARY
  Future<void> deleteItinerary(int id) async {
    final db = await _dbHelper.database;

    // delete() menghapus baris yang memenuhi kondisi where
    await db.delete(
      'itineraries',
      where: 'id = ?',
      whereArgs: [id],
    );
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

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository();
});