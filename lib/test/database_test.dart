import '../model/itinerary.dart';
import '../model/day_plan.dart';
import '../model/activity.dart';
import '../repository/generate_itinerary_repository.dart';
import '../repository/detail_itinerary_repository.dart';
import '../repository/history_repository.dart';

Future<void> runDatabaseTest() async {
  print('=== MULAI TEST DATABASE ===');

  // ----- TEST 1: SAVE -----
  print('\n[1] Test SAVE itinerary...');
  
  // Buat data dummy untuk test
  final testItinerary = Itinerary(
    userId: 'test_user_123',
    destination: 'Lombok',
    startDate: DateTime(2025, 7, 1),
    endDate: DateTime(2025, 7, 3),
    budget: 3000000,
    createdAt: DateTime.now(),
    dayPlans: [
      DayPlan(
        itineraryId: 0,  // akan diisi otomatis oleh repository
        dayNumber: 1,
        theme: 'Pantai',
        activities: [
          Activity(
            dayPlanId: 0,  // akan diisi otomatis
            time: '08.00 - 10.00',
            name: 'Pantai Tanjung Aan',
            description: 'Menikmati sunrise di pantai',
            estimatedCost: 50000,
          ),
          Activity(
            dayPlanId: 0,
            time: '11.00 - 13.00',
            name: 'Bukit Merese',
            description: 'Trekking ringan dengan pemandangan laut',
            estimatedCost: 30000,
          ),
        ],
      ),
      DayPlan(
        itineraryId: 0,
        dayNumber: 2,
        theme: 'Kuliner',
        activities: [
          Activity(
            dayPlanId: 0,
            time: '09.00 - 11.00',
            name: 'Pasar Cakranegara',
            description: 'Wisata kuliner lokal',
            estimatedCost: 100000,
          ),
        ],
      ),
    ],
  );

  final generateRepo = GenerateItineraryRepository();
  final savedId = await generateRepo.saveItinerary(testItinerary);
  print('✅ Save berhasil! ID itinerary: $savedId');

  // ----- TEST 2: GET BY ID -----
  print('\n[2] Test GET BY ID...');
  final detailRepo = DetailItineraryRepository();
  final fetched = await detailRepo.getItineraryById(savedId);
  
  if (fetched != null) {
    print('✅ Get berhasil!');
    print('   Destinasi: ${fetched.destination}');
    print('   Jumlah hari: ${fetched.dayPlans.length}');
    print('   Aktivitas hari 1: ${fetched.dayPlans[0].activities.length} aktivitas');
  } else {
    print('❌ Get gagal! Data tidak ditemukan');
  }

  // ----- TEST 3: UPDATE AKOMODASI -----
  print('\n[3] Test UPDATE AKOMODASI...');
  await detailRepo.updateAccommodation(
    itineraryId: savedId,
    accommodation: 'The Mandalika Resort',
    accommodationCost: 480000,
  );
  
  final afterUpdate = await detailRepo.getItineraryById(savedId);
  if (afterUpdate?.accommodation == 'The Mandalika Resort') {
    print('✅ Update berhasil!');
    print('   Akomodasi: ${afterUpdate?.accommodation}');
    print('   Total cost: ${afterUpdate?.totalCost}');
  } else {
    print('❌ Update gagal!');
  }

  // ----- TEST 4: GET ALL BY USER -----
  print('\n[4] Test GET ALL BY USER...');
  final historyRepo = HistoryRepository();
  final allItineraries = await historyRepo.getAllItinerariesByUser('test_user_123');
  print('✅ Get all berhasil! Jumlah itinerary: ${allItineraries.length}');

  // ----- TEST 5: DELETE -----
  print('\n[5] Test DELETE...');
  await historyRepo.deleteItinerary(savedId);
  
  final afterDelete = await detailRepo.getItineraryById(savedId);
  if (afterDelete == null) {
    print('✅ Delete berhasil! Data sudah tidak ada');
  } else {
    print('❌ Delete gagal! Data masih ada');
  }

  print('\n=== TEST SELESAI ===');
}