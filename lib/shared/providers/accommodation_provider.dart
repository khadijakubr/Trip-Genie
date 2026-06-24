import 'package:flutter_riverpod/legacy.dart' show StateProvider;
import '../../model/accommodation_option.dart';

// Provider sementara untuk menyimpan accommodation options
// selama navigasi dari GenerateItineraryPage ke DetailItineraryPage
//
// Kenapa perlu provider terpisah?
// Karena GoRouter tidak bisa membawa objek kompleks seperti
// List<AccommodationOption> sebagai parameter URL.
// URL hanya bisa membawa string sederhana seperti ID.
// Jadi data accommodation options disimpan di sini sementara,
// diambil oleh DetailItineraryPage saat halaman dibuka.
//
// StateProvider dipilih karena:
// - Datanya sederhana (hanya List)
// - Perlu bisa diupdate dari luar (dari GenerateItineraryViewModel)
// - Tidak butuh logic kompleks seperti AsyncNotifier
final accommodationOptionsProvider =
    StateProvider<List<AccommodationOption>>((ref) => []);
//                                           
//                          nilai awal adalah list kosong