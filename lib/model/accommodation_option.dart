// Model untuk satu opsi akomodasi yang dikembalikan Gemini
// Gemini akan return 3 opsi akomodasi untuk dipilih user
class AccommodationOption {
  final String name;
  final double pricePerNight;
  final double totalPrice;
  // Fasilitas dalam bentuk list string
  // contoh: ['WiFi', 'AC', 'Sarapan']
  final List<String> facilities;

  AccommodationOption({
    required this.name,
    required this.pricePerNight,
    required this.totalPrice,
    required this.facilities,
  });

  // fromMap untuk parsing dari JSON response Gemini
  factory AccommodationOption.fromMap(Map<String, dynamic> map) {
    return AccommodationOption(
      name: map['name'] as String,
      pricePerNight: (map['price_per_night'] as num).toDouble(),
      totalPrice: (map['total_price'] as num).toDouble(),
      // map['facilities'] dari JSON berupa List<dynamic>
      // .cast<String>() mengubahnya menjadi List<String>
      facilities: (map['facilities'] as List<dynamic>).cast<String>(),
    );
  }
}