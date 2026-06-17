import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trip_genie/view/pages/onboarding_page.dart';
import 'package:trip_genie/view/pages/auth_page.dart';
import 'package:trip_genie/view/pages/home_page.dart';
import 'package:trip_genie/view/pages/generate_itinerary_page.dart';
import 'package:trip_genie/view/pages/detail_itinerary_page.dart';
import 'package:trip_genie/view/pages/history_page.dart';
import 'package:trip_genie/view/pages/profile_page.dart';

class AppRoutes {
  static const String onboarding = '/';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String generateItinerary = '/generate';
  static const String detailItinerary = '/detail/:id';
  static const String history = '/history';
  static const String profile = '/profile';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // Halaman pertama yang dibuka
    initialLocation: AppRoutes.onboarding,
    
    // redirect dipanggil setiap kali ada navigasi
    // Di sini kita tentukan logika "siapa boleh akses halaman mana"
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      
      // Jika belum pernah lihat onboarding, arahkan ke onboarding
      if (!hasSeenOnboarding) return AppRoutes.onboarding;
      
      // Jika sudah lihat onboarding tapi belum login, arahkan ke auth
      // (logika cek login akan ditambahkan setelah fase auth selesai)
      return null; // null artinya tidak ada redirect, lanjut ke tujuan semula
    },
    
    // Daftar semua halaman
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const AuthPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.generateItinerary,
        builder: (context, state) => const GenerateItineraryPage(),
      ),
      GoRoute(
        // ":id" artinya bagian ini adalah parameter dinamis
        // contoh: /detail/42 → id = "42"
        path: AppRoutes.detailItinerary,
        builder: (context, state) {
          // Cara mengambil parameter dari URL
          final id = state.pathParameters['id']!;
          return DetailItineraryPage(itineraryId: int.parse(id));
        },
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
});