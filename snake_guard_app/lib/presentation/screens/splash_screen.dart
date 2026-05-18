import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/colors.dart';
import 'location_permission_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Preload haptic feedback
    HapticFeedback.mediumImpact();
    
    // Navigate after delay
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) => 
              const LocationPermissionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    AppColors.primaryRed.withOpacity(0.05),
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryRed.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.emergency,
                    size: 80,
                    color: AppColors.primaryRed,
                  ),
                ).animate()
                 .scale(duration: 800.ms, curve: Curves.easeOutBack)
                 .shimmer(delay: 800.ms, duration: 1.5.seconds, color: Colors.white),
                 
                const SizedBox(height: 32),
                
                Text(
                  'SNAKEGUARD',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppColors.textPrimaryDark,
                    letterSpacing: 4,
                  ),
                ).animate()
                 .fade(delay: 400.ms, duration: 600.ms)
                 .slideY(begin: 0.5, end: 0, duration: 600.ms, curve: Curves.easeOut),
                 
                const SizedBox(height: 8),
                
                Text(
                  'AI MEDICAL ASSISTANT',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.primaryRed,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate()
                 .fade(delay: 800.ms, duration: 600.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
