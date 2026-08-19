import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  static const _heroImage =
      'assets/images/ChatGPT Image 12 août 2026, 16_27_47.png';
  static const _logoAsset = 'assets/images/logo.png';

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxWidth = media.size.shortestSide >= 600 ? 430.0 : double.infinity;

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
                const _TopWash(),
                const _BottomWash(),
                SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    media.padding.top + 34,
                    24,
                    media.padding.bottom + 18,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          media.size.height - media.padding.vertical - 56,
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          _logoAsset,
                          width: 210,
                          fit: BoxFit.contain,
                          cacheWidth: 420,
                          filterQuality: FilterQuality.high,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Créer un compte',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: AppColors.blueBic,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                        Text(
                          'Choisissez votre profil DailyCatch.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: AppColors.blueBic.withValues(alpha: 0.76),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 34),
                        _RoleCard(
                          title: 'Je veux sauver un panier',
                          description:
                              'Réserver des paniers frais près de moi.',
                          icon: Icons.shopping_bag_outlined,
                          onTap: () => context.go('/register-client'),
                        ),
                        const SizedBox(height: 14),
                        _RoleCard(
                          title: 'Je suis vendeur',
                          description:
                              'Publier mes invendus et gérer mes retraits.',
                          icon: Icons.storefront_outlined,
                          onTap: () => context.go('/register-partner'),
                        ),
                        const SizedBox(height: 18),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text(
                            'J’ai déjà un compte',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.blueBic.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppColors.blueBic, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: AppColors.blueBic,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        color: AppColors.blueBic.withValues(alpha: 0.66),
                        fontSize: 12,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.blueBic,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopWash extends StatelessWidget {
  const _TopWash();

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
              Colors.white.withValues(alpha: 0.70),
              Colors.white.withValues(alpha: 0.06),
            ],
            stops: const [0, 0.42, 1],
          ),
        ),
      ),
    );
  }
}

class _BottomWash extends StatelessWidget {
  const _BottomWash();

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
              AppColors.blueBic.withValues(alpha: 0.16),
              AppColors.blueBic.withValues(alpha: 0.78),
            ],
            stops: const [0, 0.68, 1],
          ),
        ),
      ),
    );
  }
}
