// Model ini merepresentasikan semua input yang dikumpulkan
// dari user di GenerateItineraryPage (form + pilihan tema + tipe trip)
class TripRequest {
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  // List tema untuk setiap hari, contoh: ['Nature', 'Culinary', 'Healing', atau 'Cultural]
  final List<String> themes;
  // Tipe perjalanan: 'Solo', 'Couple', 'Family', atau 'Friends'
  final String tripType;

  TripRequest({
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.themes,
    required this.tripType,
  });

  // Helper untuk hitung jumlah hari perjalanan
  // endDate.difference(startDate).inDays menghitung selisih hari
  int get totalDays => endDate.difference(startDate).inDays + 1;
}