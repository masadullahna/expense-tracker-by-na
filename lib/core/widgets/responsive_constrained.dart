import 'package:flutter/material.dart';

/// Constrains content to a max width and centers it on wide screens (web).
///
/// Narrow screens (< [maxWidth]) behave exactly as before — full width.
/// Wide screens get a centered column so layouts never stretch edge-to-edge.
class ResponsiveConstrained extends StatelessWidget {
  const ResponsiveConstrained({
    super.key,
    required this.child,
    this.maxWidth = 700,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= maxWidth) return child;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        );
      },
    );
  }
}
