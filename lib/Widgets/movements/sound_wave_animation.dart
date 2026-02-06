import 'package:flutter/material.dart';

class SoundWaveAnimation extends StatefulWidget {
  final Color color;
  final double size;

  const SoundWaveAnimation({
    super.key,
    required this.color,
    this.size = 62.0,
  });

  @override
  State<SoundWaveAnimation> createState() => _SoundWaveAnimationState();
}

class _SoundWaveAnimationState extends State<SoundWaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 2,
      height: widget.size * 2,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: SoundWavePainter(
              animation: _controller.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

class SoundWavePainter extends CustomPainter {
  final double animation;
  final Color color;

  SoundWavePainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Dibujar 3 ondas concéntricas
    for (int i = 0; i < 3; i++) {
      final progress = (animation + (i * 0.33)) % 1.0;
      final radius = maxRadius * progress;
      final opacity = 1.0 - progress;

      final paint = Paint()
        ..color = color.withOpacity(opacity * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(SoundWavePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
