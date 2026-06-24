import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trip_genie/view/widgets/app_bottom_nav.dart';

/// Shell scaffold used by [StatefulShellRoute.indexedStack].
/// Provides the persistent [AppBottomNav] across Home, History, and Profile tabs.
class ShellScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ShellScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          // Navigate to the selected tab branch — instant, no page transition.
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
