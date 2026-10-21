import 'package:flutter/material.dart';

/// Keeps related fields side by side only when each has enough room.
class ResponsiveFormRow extends StatelessWidget {
  const ResponsiveFormRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth >= 560) return Row(children: children);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final child in children)
            if (child is Expanded)
              child.child
            else if (child is SizedBox)
              const SizedBox(height: 16)
            else
              child,
        ],
      );
    },
  );
}
