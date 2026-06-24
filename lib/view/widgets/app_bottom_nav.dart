import 'package:flutter/material.dart';
import 'package:trip_genie/shared/theme/app_theme.dart';

/// Reusable bottom navigation bar for the main app sections.
///
/// [currentIndex] determines which tab is highlighted:
///   0 = Home, 1 = History, 2 = Profile
///
/// [onTap] is called when a tab is tapped. The parent (shell route)
/// provides the navigation logic so switching is instant (no animation).
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int index) onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
        backgroundColor: Colors.white,
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            activeIcon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
