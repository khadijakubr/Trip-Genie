import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'package:trip_genie/shared/constants/app_preferences.dart';
import 'package:trip_genie/shared/routes/app_routes.dart';
import 'package:trip_genie/shared/theme/app_theme.dart';

/// ──────────────────────────────────────────────
///  Slide data model — single source of truth
/// ──────────────────────────────────────────────
class _OnboardingSlideData {
  const _OnboardingSlideData({
    required this.titleLine1,
    required this.titleLine2,
    required this.subtitle,
    required this.lottieAsset,
  });

  final String titleLine1;
  final String titleLine2;
  final String subtitle;
  final String lottieAsset;
}

/// ──────────────────────────────────────────────
///  Custom decoder for .lottie (dotLottie) archives
/// ──────────────────────────────────────────────
Future<LottieComposition?> _lottieDecoder(List<int> bytes) {
  return LottieComposition.decodeZip(
    bytes,
    filePicker: (files) {
      for (final f in files) {
        if (f.name.startsWith('animations/') && f.name.endsWith('.json')) {
          return f;
        }
      }
      return null;
    },
  );
}

/// ──────────────────────────────────────────────
///  Single reusable slide widget
/// ──────────────────────────────────────────────
class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.data});

  final _OnboardingSlideData data;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // ── Lottie animation (top ~55%) ──
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Lottie.asset(
                data.lottieAsset,
                decoder: _lottieDecoder,
                fit: BoxFit.contain,
                repeat: true,
              ),
            ),
          ),

          // ── Title & subtitle (bottom ~45%) ──
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title line 1 (hero)
                  Text(
                    data.titleLine1,
                    style: TextStyle(
                      fontFamily: 'Gloock',
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textLight,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Title line 2 (supporting)
                  Text(
                    data.titleLine2,
                    style: TextStyle(
                      fontFamily: 'Gloock',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textLight,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Subtitle
                  Text(
                    data.subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textLight.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ──────────────────────────────────────────────
///  Slide data — single list, easy to maintain
/// ──────────────────────────────────────────────
const _kSlides = <_OnboardingSlideData>[
  _OnboardingSlideData(
    titleLine1: 'Welcome to',
    titleLine2: 'Trip Genie',
    subtitle: 'Your AI Travel Buddy',
    lottieAsset: 'assets/animations/Paper_plane.lottie',
  ),
  _OnboardingSlideData(
    titleLine1: 'Discover',
    titleLine2: 'Amazing Places',
    subtitle: 'Creating your holiday itinerary\nplans in seconds',
    lottieAsset: 'assets/animations/Globe.lottie',
  ),
  _OnboardingSlideData(
    titleLine1: "Let's Start",
    titleLine2: 'Your Journey',
    subtitle: 'Sign up and let AI plan\nyour perfect trip',
    lottieAsset: 'assets/animations/GPS_Navigation.lottie',
  ),
];

/// ──────────────────────────────────────────────
///  Onboarding page
/// ──────────────────────────────────────────────
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late final PageController _pageController;
  late Timer _autoScrollTimer;

  int _currentPage = 0;

  static const _autoScrollDuration = Duration(seconds: 5);

  // ─── Lifecycle ──────────────────────────────

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // ─── Auto-scroll ────────────────────────────

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(_autoScrollDuration, (_) {
      if (_currentPage < _kSlides.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubicEmphasized,
        );
      }
    });
  }

  void _resetAutoScroll() {
    _autoScrollTimer.cancel();
    _startAutoScroll();
  }

  // ─── Navigation ─────────────────────────────

  Future<void> _goToAuth() async {
    await AppPreferences.setHasSeenOnboarding(true);
    if (mounted) context.go(AppRoutes.auth);
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _resetAutoScroll();
  }

  bool get _isLastPage => _currentPage == _kSlides.length - 1;

  // ─── Build ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.secondaryColor,
            ],
          ),
        ),
        child: Stack(
          children: [
            // ── PageView ──────────────────────
            PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: _kSlides
                  .map((slide) => _OnboardingSlide(data: slide))
                  .toList(),
            ),

            // ── Skip button (top-right) ───────
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 20,
              child: TextButton(
                onPressed: _goToAuth,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textLight.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),

            // ── Dot indicators (bottom-left) ──
            Positioned(
              bottom: 40,
              left: 32,
              child: Row(
                children: List.generate(_kSlides.length, (i) {
                  final isActive = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isActive ? 28 : 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: isActive
                          ? AppTheme.textLight
                          : AppTheme.textLight.withValues(alpha: 0.3),
                    ),
                  );
                }),
              ),
            ),

            // ── FAB (last page only) ──────────
            if (_isLastPage)
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton.extended(
                  onPressed: _goToAuth,
                  backgroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  icon: Icon(
                    Icons.arrow_forward_rounded,
                    color: AppTheme.primaryColor,
                  ),
                  label: Text(
                    'Get Started',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
