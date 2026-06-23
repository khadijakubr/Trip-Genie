import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database_helper.dart';
import '../model/itinerary.dart';
import '../model/day_plan.dart';
import '../model/activity.dart';

class GenerateItineraryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // SAVE — Menyimpan itinerary baru ke database
  Future<int> saveItinerary(Itinerary itinerary) async {
    final db = await _dbHelper.database;
    
    // insert() menyimpan satu baris ke tabel
    // mengembalikan id yang digenerate SQLite untuk baris tersebut
    final itineraryId = await db.insert('itineraries', itinerary.toMap());

    // Setelah itinerary tersimpan, simpan semua day_plan miliknya
    for (final dayPlan in itinerary.dayPlans) {
      // Buat objek dayPlan baru dengan itineraryId yang baru didapat
      final dayPlanWithId = DayPlan(
        itineraryId: itineraryId,   
        dayNumber: dayPlan.dayNumber,
        theme: dayPlan.theme,
        activities: dayPlan.activities,
      );
      
      final dayPlanId = await db.insert('day_plans', dayPlanWithId.toMap());

      // Setelah day_plan tersimpan, simpan semua activity miliknya
      for (final activity in dayPlan.activities) {
        final activityWithId = Activity(
          dayPlanId: dayPlanId,     
          time: activity.time,
          name: activity.name,
          description: activity.description,
          estimatedCost: activity.estimatedCost,
        );
        
        await db.insert('activities', activityWithId.toMap());
      }
    }

    return itineraryId;
  }


  // GET ALL — Ambil semua itinerary milik user
  Future<List<Itinerary>> getItinerariesByUser(String userId) async {
    final db = await _dbHelper.database;
    
    // query() untuk mengambil data dengan kondisi tertentu
    final itineraryMaps = await db.query(
      'itineraries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    // Konversi setiap Map menjadi objek Itinerary
    final itineraries = <Itinerary>[];
    for (final map in itineraryMaps) {
      final dayPlans = await _getDayPlans(map['id'] as int);
      itineraries.add(Itinerary.fromMap(map, dayPlans));
    }

    return itineraries;
  }

  // GET ONE — Ambil satu itinerary berdasarkan id
  Future<Itinerary?> getItineraryById(int id) async {
    final db = await _dbHelper.database;
    
    final maps = await db.query(
      'itineraries',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,  
    );

    if (maps.isEmpty) return null;  
    
    final dayPlans = await _getDayPlans(id);
    return Itinerary.fromMap(maps.first, dayPlans);
  }


  // UPDATE — Update akomodasi setelah user memilih
  Future<void> updateAccommodation(
    int itineraryId,
    String accommodation,
    double accommodationCost,
    double totalCost,
  ) async {
    final db = await _dbHelper.database;
    
    // update() mengubah baris yang sudah ada
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

  // DELETE — Hapus itinerary beserta semua day_plan dan activity miliknya
  Future<void> deleteItinerary(int id) async {
    final db = await _dbHelper.database;
    
    await db.delete(
      'itineraries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  // PRIVATE HELPERS — hanya dipakai di dalam repository ini
  
  // Ambil semua day_plan milik satu itinerary
  Future<List<DayPlan>> _getDayPlans(int itineraryId) async {
    final db = await _dbHelper.database;
    
    final maps = await db.query(
      'day_plans',
      where: 'itinerary_id = ?',
      whereArgs: [itineraryId],
      orderBy: 'day_number ASC',  
    );

    final dayPlans = <DayPlan>[];
    for (final map in maps) {
      final activities = await _getActivities(map['id'] as int);
      dayPlans.add(DayPlan.fromMap(map, activities));
    }

    return dayPlans;
  }

  // Ambil semua activity milik satu day_plan
  Future<List<Activity>> _getActivities(int dayPlanId) async {
    final db = await _dbHelper.database;
    
    final maps = await db.query(
      'activities',
      where: 'day_plan_id = ?',
      whereArgs: [dayPlanId],
    );

    return maps.map((map) => Activity.fromMap(map)).toList() as List<Activity>;
  }
}

// Provider untuk GenerateItineraryRepository
final generateItineraryRepositoryProvider = Provider<GenerateItineraryRepository>((ref) {
  return GenerateItineraryRepository();
});