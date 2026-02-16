// Full-screen blur + translucent scrim + dots in center
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

class BlurDotsLoader extends StatelessWidget {
  const BlurDotsLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      // block taps while loading
      absorbing: true,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: Colors.black.withOpacity(0.15), // transparent scrim
          alignment: Alignment.center,
          child: const _DotsLoader(),
        ),
      ),
    );
  }
}

// Row of 3 pulsing dots
class _DotsLoader extends StatelessWidget {
  const _DotsLoader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          _PulseDot(phase: 0.00),
          SizedBox(width: 10),
          _PulseDot(phase: 0.33),
          SizedBox(width: 10),
          _PulseDot(phase: 0.66),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final double phase; // 0..1 (stagger)
  final double size;
  final Color color;

  const _PulseDot({
    required this.phase,
    this.size = 10,
    this.color = Colors.green, // tweak to your brand color
  });

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        // v cycles 0..1 with a phase offset
        final v = (math.sin(2 * math.pi * (_c.value + widget.phase)) + 1) / 2;
        final scale = 0.6 + 0.4 * v;     // 0.6..1.0
        final opacity = 0.5 + 0.5 * v;   // 0.5..1.0

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: widget.size * 2,
              height: widget.size * 2,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.35),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
