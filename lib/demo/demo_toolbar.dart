import 'package:flutter/material.dart';
import 'package:myapp/config/router/app_router.dart';
import 'package:myapp/demo/demo_client.dart';
import 'package:myapp/utils/local_auth_session.dart';
import 'package:myapp/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class DemoToolbar extends StatelessWidget {
  const DemoToolbar({super.key, required this.child});
  final Widget child;

  Future<void> _chooseAccount(BuildContext context) async {
    // MaterialApp.builder is above the Navigator; use its overlay for dialogs.
    final overlay = router.routerDelegate.navigatorKey.currentState?.overlay;
    if (overlay == null) return;
    final choice = await showModalBottomSheet<String>(
      context: overlay.context,
      builder:
          (sheetContext) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final entry
                    in const {
                      'client': 'Voir comme client',
                      'vendeur': 'Voir comme vendeur',
                      'admin': 'Voir comme administrateur',
                      'reset': 'Reinitialiser la demonstration',
                    }.entries)
                  ListTile(
                    title: Text(entry.value),
                    onTap: () => Navigator.pop(sheetContext, entry.key),
                  ),
              ],
            ),
          ),
    );
    if (choice == null || !context.mounted) return;
    context.read<CartProvider>().clear();
    if (choice == 'reset') {
      await DemoClient.reset();
      await LocalAuthSession.signOut();
      router.go('/login');
      return;
    }
    final route = await LocalAuthSession.signIn(
      email: '$choice@dailycatch.local',
      password: choice,
    );
    router.go(route ?? '/login');
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Material(
        color: const Color(0xFF073E43),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 36,
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'DEMO - Aucun paiement reel',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                TextButton.icon(
                  label: const Text(
                    'Comptes',
                    style: TextStyle(color: Colors.white),
                  ),
                  icon: const Icon(
                    Icons.switch_account,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => _chooseAccount(context),
                ),
              ],
            ),
          ),
        ),
      ),
      Expanded(child: child),
    ],
  );
}
