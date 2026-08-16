import 'dart:math';
import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/font_manager.dart';

class AppCircularProgress extends StatelessWidget {
  /// Percentage value between 0 and 100.
  final double percentage;

  /// Color of the progress arc. Defaults to indigo if not provided.
  final Color progressColor;

  /// Diameter of the widget. Default: 200.
  final double size;

  /// Thickness of the arc stroke. Default: 16.
  final double strokeWidth;


  const AppCircularProgress({
    super.key,
    required this.percentage,
    required this.progressColor,
    this.size = 50,
    this.strokeWidth = 6,
  });

  double get _progress => (percentage.clamp(0, 100)) / 100;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _CircularProgressPainter(
              progress: _progress,
              strokeWidth: strokeWidth,
              progressColor: progressColor,
            ),
          ),
          Text(
            '${percentage.clamp(0, 100).round()}%',
            style: TextStyle(
              color: progressColor,
              fontSize: FontSize.s12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Painter (private) ────────────────────────────────────────────────────────

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color progressColor;

  const _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.grey.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter old) =>
      old.progress != progress ||
          old.strokeWidth != strokeWidth ||
          old.progressColor != progressColor;
}
