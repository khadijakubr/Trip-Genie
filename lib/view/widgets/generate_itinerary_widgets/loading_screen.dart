import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Custom decoder for .lottie (dotLottie) archives — reused from onboarding.
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

/// Full-screen loading overlay shown while the AI generates an itinerary.
///
/// Uses the Paper Plane animation from onboarding assets to keep visual
/// consistency, with pulsing text.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF004AAD),
            Color(0xFFA1D7E8),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // Animated plane — same style as onboarding
            SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset(
                'assets/animations/Paper_plane.lottie',
                decoder: _lottieDecoder,
                fit: BoxFit.contain,
                repeat: true,
              ),
            ),

            const SizedBox(height: 40),

            // Pulsing main text
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _pulseAnimation.value,
                  child: child,
                );
              },
              child: const Text(
                'Trip Genie is crafting\nyour perfect itinerary...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Gloock',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Subtitle
            Text(
              'This may take a few seconds',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),

            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
