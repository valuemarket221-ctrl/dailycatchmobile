import 'dart:async';
import 'package:flutter/foundation.dart';

/// Convertit un Stream en ChangeNotifier pour le refreshListenable de GoRouter.
/// GoRouter écoutera ce notifier pour déclencher une re-évaluation du redirect.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
