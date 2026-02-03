import 'package:flutter/material.dart';
import '../../Theme/Theme.dart';

/// Indicador de progreso simplificado - Solo barra horizontal
/// Diseño minimalista consistente con el resto de la app
class GoalProgressIndicator extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color? progressColor;
  final double height;
  final bool showPercentage;

  const GoalProgressIndicator({
    super.key,
    required this.progress,
    this.progressColor,
    this.height = 6.0,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = progressColor ?? AppTheme.primaryColor;
    final percentage = (progress * 100).toInt();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra de progreso
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: height,
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),

        // Porcentaje (opcional)
        if (showPercentage) ...[
          const SizedBox(height: 4),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
              fontFamily: 'Baloo2',
            ),
          ),
        ],
      ],
    );
  }
}

/// Barra de progreso con animación suave
class AnimatedGoalProgress extends StatefulWidget {
  final double progress;
  final Color? progressColor;
  final double height;
  final Duration animationDuration;

  const AnimatedGoalProgress({
    super.key,
    required this.progress,
    this.progressColor,
    this.height = 6.0,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedGoalProgress> createState() => _AnimatedGoalProgressState();
}

class _AnimatedGoalProgressState extends State<AnimatedGoalProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedGoalProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GoalProgressIndicator(
          progress: _animation.value,
          progressColor: widget.progressColor,
          height: widget.height,
        );
      },
    );
  }
}

/// Variante mini para espacios reducidos
class MiniProgressBar extends StatelessWidget {
  final double progress;
  final Color? color;

  const MiniProgressBar({
    super.key,
    required this.progress,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 4,
        child: LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}
