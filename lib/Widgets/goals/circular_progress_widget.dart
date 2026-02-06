import 'dart:math' as math;
import 'package:flutter/material.dart';

class CircularProgressIndicatorCustom extends StatelessWidget {
  final double progress;
  final Widget centerWidget;
  final Color progressColor;
  final double strokeWidth;
  final double size;

  const CircularProgressIndicatorCustom({
    super.key,
    required this.progress,
    required this.centerWidget,
    required this.progressColor,
    this.strokeWidth = 10,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _CirclePainter(
                progress: progress,
                color: progressColor,
                strokeWidth: strokeWidth,
              ),
            ),
          ),
          centerWidget,
        ],
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CirclePainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final progressColor = color;
    final backgroundColor = color.withValues(alpha: 0.12);

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    if (progress > 0) {
      final startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _CirclePainter &&
        (oldDelegate.progress != progress || oldDelegate.color != color);
  }
}
