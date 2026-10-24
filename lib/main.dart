// main.dart — BMI+ entry point
// Initialises SharedPreferences and AppState before runApp.
// Wires AppStateScope + ListenableBuilder for reactive theme switching.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/app_state.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final appState = AppState();
  await appState.init(prefs);
  runApp(BmiPlusApp(appState: appState));
}

class BmiPlusApp extends StatelessWidget {
  final AppState appState;
  const BmiPlusApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: appState,
      child: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: appState.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
