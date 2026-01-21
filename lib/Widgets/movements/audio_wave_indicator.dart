import 'package:flutter/material.dart';

class AudioWaveIndicator extends StatefulWidget {
  final Color color;
  final bool isAnimating;

  const AudioWaveIndicator({super.key, required this.color, required this.isAnimating});

  @override
  State<AudioWaveIndicator> createState() => _AudioWaveIndicatorState();
}

class _AudioWaveIndicatorState extends State<AudioWaveIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAnimating) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double height = 10 + 10 * (1 - ((_controller.value + index * 0.2) % 1)).abs();
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 3,
              height: height,
              decoration: BoxDecoration(color: widget.color, borderRadius: BorderRadius.circular(5)),
            );
          },
        );
      }),
    );
  }
}