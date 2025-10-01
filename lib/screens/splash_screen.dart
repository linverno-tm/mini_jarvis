import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme_config.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo/Icon
            Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ThemeConfig.primaryColor,
                        ThemeConfig.secondaryColor,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: ThemeConfig.glowShadow,
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 60,
                  ),
                )
                .animate()
                .scale(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutBack,
                )
                .fadeIn(),

            const SizedBox(height: 24),

            // App Name
            Text(
                  'JARVIS',
                  style: TextStyle(
                    color: ThemeConfig.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 300))
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 8),

            // Tagline
            Text(
                  'Your Voice Assistant',
                  style: TextStyle(
                    color: ThemeConfig.textSecondary,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 600))
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 60),

            // Loading Indicator
            SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ThemeConfig.primaryColor,
                    ),
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .fadeIn(delay: const Duration(milliseconds: 900)),
          ],
        ),
      ),
    );
  }
}
