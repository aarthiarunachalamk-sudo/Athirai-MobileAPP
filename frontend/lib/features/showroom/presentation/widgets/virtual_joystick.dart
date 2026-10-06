import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class VirtualJoystick extends StatefulWidget {
  const VirtualJoystick({
    super.key,
    required this.onDirectionChanged,
    this.radius = 58.0,
    this.knobRadius = 24.0,
  });

  /// Normalized offset (-1.0 to 1.0 on both X and Y)
  final ValueChanged<Offset> onDirectionChanged;
  final double radius;
  final double knobRadius;

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  Offset _dragOffset = Offset.zero;

  void _updatePosition(Offset localPos) {
    final center = Offset(widget.radius, widget.radius);
    final delta = localPos - center;
    final dist = delta.distance;
    final maxDist = widget.radius - widget.knobRadius;

    Offset clamped;
    if (dist <= maxDist) {
      clamped = delta;
    } else {
      clamped = Offset.fromDirection(delta.direction, maxDist);
    }

    setState(() {
      _dragOffset = clamped;
    });

    final normalized = Offset(
      clamped.dx / maxDist,
      clamped.dy / maxDist,
    );
    widget.onDirectionChanged(normalized);
  }

  void _reset() {
    setState(() {
      _dragOffset = Offset.zero;
    });
    widget.onDirectionChanged(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.radius * 2;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (details) => _updatePosition(details.localPosition),
      onPanUpdate: (details) => _updatePosition(details.localPosition),
      onPanEnd: (_) => _reset(),
      onPanCancel: () => _reset(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.42),
          border: Border.all(
            color: AppColors.goldPrimary.withOpacity(0.65),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.goldPrimary.withOpacity(0.15),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Inner guiding ring
            Container(
              width: size * 0.55,
              height: size * 0.55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.goldPrimary.withOpacity(0.25),
                  width: 1.0,
                ),
              ),
            ),
            // Crosshair markers
            Icon(
              Icons.navigation_rounded,
              color: AppColors.goldPrimary.withOpacity(0.3),
              size: 16,
            ),
            // Joystick Knob
            Transform.translate(
              offset: _dragOffset,
              child: Container(
                width: widget.knobRadius * 2,
                height: widget.knobRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      Color(0xFFFFDF7D),
                      AppColors.goldPrimary,
                      Color(0xFF8C6418),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.8),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldPrimary.withOpacity(0.55),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.drag_indicator_rounded,
                    color: Colors.black87,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
