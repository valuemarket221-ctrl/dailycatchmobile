import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

enum SystemStateKind {
  paymentFailed,
  reservationExpired,
  basketUnavailable,
  locationPermission,
  notificationPermission,
  offline,
  maintenance,
}

class SystemStatePage extends StatelessWidget {
  const SystemStatePage({super.key, required this.kind});

  final SystemStateKind kind;

  _StateData get _data {
    switch (kind) {
      case SystemStateKind.paymentFailed:
        return const _StateData(
          title: 'Paiement échoué',
          icon: Icons.close,
          iconColor: Color(0xFFFF5A5F),
          headline: 'Paiement échoué',
          body:
              'Une erreur est survenue lors\ndu paiement. Veuillez réessayer.',
          primary: 'Réessayer',
          secondary: 'Changer de moyen de paiement',
          route: '/payment',
        );
      case SystemStateKind.reservationExpired:
        return const _StateData(
          title: 'Réservation expirée',
          icon: Icons.schedule,
          iconColor: Color(0xFFFF5A5F),
          headline: 'Réservation expirée',
          body:
              'Ce panier n’est plus disponible.\nVeuillez choisir un autre panier.',
          primary: 'Voir d’autres paniers',
          route: '/home',
          outlined: true,
        );
      case SystemStateKind.basketUnavailable:
        return const _StateData(
          title: 'Panier indisponible',
          icon: Icons.shopping_bag,
          iconColor: AppColors.blueBic,
          headline: 'Panier indisponible',
          body: 'Ce panier n’est plus disponible\npour le moment.',
          primary: 'Voir d’autres paniers',
          route: '/home',
        );
      case SystemStateKind.locationPermission:
        return const _StateData(
          title: '',
          icon: Icons.location_on,
          iconColor: AppColors.blueBic,
          headline: 'Activer votre position',
          body:
              'Nous utilisons votre position pour\nvous montrer les offres disponibles\nprès de chez vous.',
          primary: 'Activer la localisation',
          secondary: 'Plus tard',
          route: '/home',
        );
      case SystemStateKind.notificationPermission:
        return const _StateData(
          title: 'Permissions notifications',
          icon: Icons.notifications,
          iconColor: AppColors.blueBic,
          headline: 'Activer les notifications',
          body:
              'Recevez des alertes pour vos\ncommandes, promotions et\nnouveaux paniers.',
          primary: 'Activer',
          secondary: 'Plus tard',
          route: '/home',
        );
      case SystemStateKind.offline:
        return const _StateData(
          title: 'Hors connexion',
          icon: Icons.wifi_off,
          iconColor: Color(0xFF142D31),
          headline: 'Pas de connexion',
          body: 'Vérifiez votre connexion\ninternet et réessayez.',
          primary: 'Réessayer',
          route: '/home',
        );
      case SystemStateKind.maintenance:
        return const _StateData(
          title: 'Page maintenance',
          icon: Icons.construction,
          iconColor: AppColors.blueBic,
          headline: 'Maintenance en cours',
          body:
              'Nous améliorons DailyCatch\npour vous offrir une meilleure\nexpérience.\n\nVeuillez réessayer plus tard.',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _data;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 24, 30, 28),
          child: Column(
            children: [
              if (state.title.isNotEmpty) Text(state.title, style: _title),
              const Spacer(flex: 2),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: state.iconColor.withValues(alpha: 0.12),
                ),
                child: Icon(state.icon, size: 45, color: state.iconColor),
              ),
              const SizedBox(height: 38),
              Text(state.headline, textAlign: TextAlign.center, style: _head),
              const SizedBox(height: 18),
              Text(state.body, textAlign: TextAlign.center, style: _body),
              const Spacer(flex: 3),
              if (state.primary != null)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () => context.go(state.route ?? '/home'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.blueBic,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(state.primary!, style: _button),
                  ),
                ),
              if (state.secondary != null) ...[
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: Text(state.secondary!, style: _link),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StateData {
  const _StateData({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.headline,
    required this.body,
    this.primary,
    this.secondary,
    this.route,
    this.outlined = false,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final String headline;
  final String body;
  final String? primary;
  final String? secondary;
  final String? route;
  final bool outlined;
}

final _title = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _head = GoogleFonts.poppins(
  fontSize: 15,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _body = GoogleFonts.poppins(
  fontSize: 12,
  height: 1.6,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF526669),
);
final _button = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);
final _link = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w900,
  color: AppColors.blueBic,
);
