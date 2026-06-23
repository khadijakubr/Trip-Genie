import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_genie/shared/constants/app_preferences.dart';
import 'package:trip_genie/view/pages/onboarding_page.dart';
import 'package:trip_genie/view/pages/auth_page.dart';
import 'package:trip_genie/view/pages/home_page.dart';
import 'package:trip_genie/view/pages/generate_itinerary_page.dart';
import 'package:trip_genie/view/pages/detail_itinerary_page.dart';
import 'package:trip_genie/view/pages/history_page.dart';
import 'package:trip_genie/view/pages/profile_page.dart';
import 'package:trip_genie/viewmodel/auth_viewmodel.dart';

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
  final authState = ref.watch(authViewModelProvider);

  return GoRouter(
    // First page opened
    initialLocation: AppRoutes.onboarding,
    
    // redirect called every time route changes
    redirect: (context, state) async {
      final hasSeenOnboarding = await AppPreferences.getHasSeenOnboarding();
      final isOnOnboarding = state.matchedLocation == AppRoutes.onboarding;
      final isOnAuth = state.matchedLocation == AppRoutes.auth;
      
      if (!hasSeenOnboarding && !isOnOnboarding) {
        return AppRoutes.onboarding;
      }
      
      final isLoggedIn = authState.user != null;

      if (hasSeenOnboarding && !isLoggedIn && !isOnAuth) {
        return AppRoutes.auth;
      }

      if (isLoggedIn && isOnAuth) {
        return AppRoutes.home;
      }
      
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
          final id = int.parse(state.pathParameters['id']!);
          return DetailItineraryPage(itineraryId: id);
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