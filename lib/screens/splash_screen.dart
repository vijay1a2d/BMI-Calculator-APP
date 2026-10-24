// screens/splash_screen.dart
// Animated splash screen → transitions to MainShell after init.

import 'package:flutter/material.dart';

import '../utils/constants.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Navigate after a short display time
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, _, _) => const MainShell(),
            transitionsBuilder: (_, anim, _, child) {
              return FadeTransition(opacity: anim, child: child);
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo icon
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: cs.onPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(
                    Icons.monitor_weight_outlined,
                    size: 52,
                    color: cs.onPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.appName,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.appSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onPrimary.withValues(alpha: 0.8),
                        letterSpacing: 0.5,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Text(
                  AppStrings.appTagline,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onPrimary.withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
