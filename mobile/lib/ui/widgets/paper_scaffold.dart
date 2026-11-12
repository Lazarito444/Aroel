import 'dart:math';

import 'package:aroel/ui/paper_theme.dart';
import 'package:flutter/material.dart';

/// The ground every screen sits on.
///
/// The paper carries a faint grain — three per cent, warm, never a gradient — so the app
/// reads as paper rather than as a white rectangle (§6.3).
class PaperScaffold extends StatelessWidget {
  const PaperScaffold({
    required this.child,
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.bottom,
    this.padding = const EdgeInsets.all(24),
    this.showBackButton = true,
  });

  /// The content of the screen.
  final Widget child;

  /// The page title, set in Newsreader.
  final String? title;

  /// A widget in place of the back button.
  final Widget? leading;

  /// Actions at the trailing edge of the title bar.
  final List<Widget>? actions;

  /// A bar pinned to the bottom of the screen.
  final Widget? bottom;

  /// The padding around [child].
  final EdgeInsets padding;

  /// Whether the title bar shows a back button.
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);

    return Scaffold(
      backgroundColor: tokens.palette.paper,
      appBar: title == null
          ? null
          : AppBar(
              backgroundColor: tokens.palette.paper,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              leading:
                  leading ??
                  (showBackButton
                      ? IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, size: 20),
                          color: tokens.palette.ink,
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).backButtonTooltip,
                          onPressed: () => Navigator.of(context).maybePop(),
                        )
                      : null),
              title: Text(title ?? ''),
              titleSpacing: 0,
              actions: actions,
            ),
      bottomNavigationBar: bottom,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Padding(padding: padding, child: child),
          ),
          const Positioned.fill(child: _PaperGrain()),
        ],
      ),
    );
  }
}

/// The grain of the paper, drawn once and never repainted.
class _PaperGrain extends StatelessWidget {
  const _PaperGrain();

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _GrainPainter(
            color: (isDark ? const Color(0xFFFFFFFF) : const Color(0xFF3C2814)).withValues(alpha: 0.03),
          ),
        ),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  const _GrainPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Random random = Random(1974);
    final Paint paint = Paint()..color = color;
    final int count = ((size.width * size.height) / 1400).clamp(0, 2400).toInt();

    for (int i = 0; i < count; i++) {
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.6, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) => oldDelegate.color != color;
}
