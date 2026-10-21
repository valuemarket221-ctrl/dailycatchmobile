import 'package:flutter/material.dart';

/// Centers short forms and scrolls the entire content when space is limited.
class AuthScrollLayout extends StatelessWidget {
  const AuthScrollLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: LayoutBuilder(
      builder:
          (context, constraints) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
    ),
  );
}
