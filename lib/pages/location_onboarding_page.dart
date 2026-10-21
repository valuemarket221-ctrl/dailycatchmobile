import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/demo/demo_mode.dart';
import 'package:myapp/services/location_service.dart';
import 'package:myapp/styles/app_theme.dart';

class LocationOnboardingPage extends StatefulWidget {
  const LocationOnboardingPage({super.key, this.locate});
  final Future<LocationResult> Function()? locate;
  @override
  State<LocationOnboardingPage> createState() => _LocationOnboardingPageState();
}

class _LocationOnboardingPageState extends State<LocationOnboardingPage> {
  bool _busy = false;
  String? _message;
  Future<void> _activate() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final result =
          await (widget.locate?.call() ??
              LocationService().resolveCurrentLocation(
                requestPermission: true,
              ));
      if (!mounted) return;
      if (!result.isFallback) {
        context.go('/login');
      } else {
        setState(
          () =>
              _message =
                  DemoMode.enabled
                      ? 'Mode demo : les offres sont situees autour de Berlin. Aucune position GPS n\'est collectee.'
                      : result.warning ??
                          'Position indisponible. Vous pouvez continuer sans localisation.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _message =
                  'Position indisponible. Reessayez ou continuez sans localisation.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: LayoutBuilder(
            builder:
                (context, constraints) => SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: (constraints.maxHeight - 56).clamp(
                        0,
                        double.infinity,
                      ),
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const Spacer(),
                          Container(
                            width: 174,
                            height: 174,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE4F3F2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              size: 88,
                              color: AppTheme.reef,
                            ),
                          ),
                          const SizedBox(height: 36),
                          const Text(
                            'Activer votre position',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Text(
                            'Nous utilisons votre position pour vous montrer les offres disponibles pres de chez vous.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.7,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          if (_message != null) ...[
                            const SizedBox(height: 20),
                            Text(
                              _message!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppTheme.reef),
                            ),
                            if (!DemoMode.enabled)
                              TextButton(
                                onPressed: () async {
                                  try {
                                    final opened =
                                        await Geolocator.openAppSettings();
                                    if (!opened && mounted) {
                                      setState(
                                        () =>
                                            _message =
                                                'Modifiez l\'autorisation dans les parametres du navigateur ou de votre appareil.',
                                      );
                                    }
                                  } catch (_) {
                                    if (mounted) {
                                      setState(
                                        () =>
                                            _message =
                                                'Ouvrez les parametres de localisation de votre navigateur ou appareil.',
                                      );
                                    }
                                  }
                                },
                                child: const Text('Ouvrir les parametres'),
                              ),
                          ],
                          const SizedBox(height: 28),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: FilledButton(
                              onPressed: _busy ? null : _activate,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.reef,
                              ),
                              child:
                                  _busy
                                      ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Text('Activer la localisation'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: OutlinedButton(
                              onPressed:
                                  _busy ? null : () => context.go('/login'),
                              child: Text(
                                _message == null ? 'Plus tard' : 'Continuer',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
        ),
      ),
    ),
  );
}
