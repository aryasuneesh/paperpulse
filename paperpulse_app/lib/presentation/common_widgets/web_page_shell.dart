import 'package:flutter/material.dart';

const double _kBreakpoint = 600.0;
const double _kDefaultMaxWidth = 560.0;
const double _kWideTextScale = 1.18;

/// Centers and constrains page content for wide (desktop/web) screens.
///
/// On narrow screens (≤600 dp) the child is returned unchanged so Android
/// layout is completely unaffected. On wide screens the content is:
///   - Centred horizontally
///   - Capped at [maxWidth]
///   - Given a slightly larger text scale so mobile-sized type reads well
///     on a high-res desktop display without any per-widget font overrides.
class WebPageShell extends StatelessWidget {
  const WebPageShell({
    required this.child,
    this.maxWidth = _kDefaultMaxWidth,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= _kBreakpoint) return child;
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(_kWideTextScale),
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
