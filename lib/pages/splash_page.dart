import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const _heroImage =
      'assets/images/ChatGPT Image 12 août 2026, 16_27_47.png';
  static const _logoAsset = 'assets/images/logo.png';

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1700), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final shortestSide = media.size.shortestSide;
    final maxWidth = shortestSide >= 600 ? 430.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF4F3),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(36),
              border: Border.all(color: const Color(0xFFB7C0C1), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  _heroImage,
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                  cacheWidth:
                      (media.size.width * media.devicePixelRatio).round(),
                  filterQuality: FilterQuality.medium,
                ),
                const _TopGlassWash(),
                const _BottomTealWash(),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    media.padding.top + 54,
                    24,
                    media.padding.bottom + 12,
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        _logoAsset,
                        width: 220,
                        fit: BoxFit.contain,
                        cacheWidth: 440,
                        filterQuality: FilterQuality.high,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const _FallbackBrand(),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Moins de gaspillage,\nplus de fraîcheur.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: AppColors.blueBic,
                          fontSize: 19,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                      const Spacer(),
                      const _SplashProgress(),
                      const SizedBox(height: 22),
                      Container(
                        width: 142,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashProgress extends StatelessWidget {
  const _SplashProgress();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: LinearProgressIndicator(
          minHeight: 4,
          color: Colors.white,
          backgroundColor: Colors.white.withValues(alpha: .34),
        ),
      ),
    );
  }
}

class _TopGlassWash extends StatelessWidget {
  const _TopGlassWash();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              Colors.white.withValues(alpha: 0.95),
              Colors.white.withValues(alpha: 0.78),
              Colors.white.withValues(alpha: 0.12),
            ],
            stops: const [0, 0.44, 1],
          ),
        ),
      ),
    );
  }
}

class _BottomTealWash extends StatelessWidget {
  const _BottomTealWash();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.center,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              AppColors.blueBic.withValues(alpha: 0.08),
              AppColors.blueBic.withValues(alpha: 0.72),
            ],
            stops: const [0, 0.72, 1],
          ),
        ),
      ),
    );
  }
}

class _FallbackBrand extends StatelessWidget {
  const _FallbackBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.set_meal_rounded, color: AppColors.blueBic, size: 56),
        const SizedBox(height: 8),
        Text(
          'DAILYCATCH',
          style: GoogleFonts.poppins(
            color: AppColors.blueBic,
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
