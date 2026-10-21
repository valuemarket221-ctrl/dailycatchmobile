import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

void safePop<T extends Object?>(BuildContext context, [T? result]) {
  try {
    final navigator = Navigator.maybeOf(context);
    if (navigator != null && navigator.canPop()) {
      navigator.pop<T>(result);
      return;
    }
  } catch (_) {
    // The source widget can be unmounted just after closing a sheet/dialog.
  }

  try {
    if (context.canPop()) {
      context.pop<T>(result);
      return;
    }
  } catch (_) {
    // Fall through to the stable route below.
  }

  try {
    if (context.mounted) {
      context.go('/home');
    }
  } catch (_) {
    // No router is attached to this context anymore.
  }
}
