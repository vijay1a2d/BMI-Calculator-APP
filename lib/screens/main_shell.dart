// screens/main_shell.dart
// Bottom navigation shell — persistent IndexedStack of 4 tabs.
// Tab switching is driven by AppState.selectedTab.

import 'package:flutter/material.dart';

import '../providers/app_state.dart';
import 'calculator_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const _tabs = <Widget>[
    HomeScreen(),
    CalculatorScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Scaffold(
          body: IndexedStack(
            index: appState.selectedTab,
            children: _tabs,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: appState.selectedTab,
            onDestinationSelected: appState.setSelectedTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.calculate_outlined),
                selectedIcon: Icon(Icons.calculate),
                label: 'Calculator',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: 'Progress',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
