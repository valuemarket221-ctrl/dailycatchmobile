import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

/// Splash Page - Clean TGTG Style With Fade & Scale Animation
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _opacityController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation controller (0.5 -> 1.0)
    _scaleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Opacity animation controller (0.0 -> 1.0)
    _opacityController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Scale animation: starts at 0.5 and grows to 1.0
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );

    // Opacity animation: starts transparent and becomes visible
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _opacityController, curve: Curves.easeIn),
    );

    // Start animations
    _scaleController.forward();
    _opacityController.forward();

    // Navigate to login after animation completes
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        context.push('/login');
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _opacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blueBic,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleController, _opacityController]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Text(
                  'DailyCatch',
                  style: GoogleFonts.poppins(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
