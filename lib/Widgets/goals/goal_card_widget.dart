import 'package:flutter/material.dart';
import 'package:MyPocket/Widgets/common/text_widget.dart';
import 'package:MyPocket/Widgets/goals/circular_progress_widget.dart';

class GoalCard extends StatefulWidget {
  final String id;
  final String name;
  final String emoji;
  final IconData icon;
  final Color color;
  final double currentAmount;
  final double targetAmount;
  final VoidCallback onContribute;
  final int index;

  const GoalCard({
    super.key,
    required this.id,
    required this.name,
    required this.emoji,
    required this.icon,
    required this.color,
    required this.currentAmount,
    required this.targetAmount,
    required this.onContribute,
    this.index = 0,
  });

  double get progress {
    if (targetAmount == 0) return 0.0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  String get currentFormatted => '\$${currentAmount.toStringAsFixed(0)}';
  String get targetFormatted => '\$${targetAmount.toStringAsFixed(0)}';
  String get percentage => '${(progress * 100).toInt()}%';

  @override
  State<GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + (widget.index * 80)),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onContribute,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.color.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 15),
                    _buildCircularProgress(),
                    const SizedBox(height: 20),
                    TextWidget(
                      text: widget.emoji,
                      size: 36,
                    ),
                    const SizedBox(height: 10),
                    TextWidget(
                      text: widget.name,
                      size: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextWidget(
                        text: widget.percentage,
                        size: 13,
                        fontWeight: FontWeight.bold,
                        color: widget.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextWidget(
                      text:
                          '${widget.currentFormatted} / ${widget.targetFormatted}',
                      size: 13,
                      color: Colors.grey[600]!,
                    ),
                    const Spacer(),
                    _buildContributeButton(),
                  ],
                ),
              ),
              if (widget.progress >= 1.0)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularProgress() {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicatorCustom(
              progress: widget.progress,
              centerWidget: Icon(
                widget.icon,
                size: 36,
                color: widget.color,
              ),
              progressColor: widget.color,
              strokeWidth: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributeButton() {
    return GestureDetector(
      onTap: widget.onContribute,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.color,
              widget.color.withValues(alpha: 0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onContribute,
            borderRadius: BorderRadius.circular(16),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  TextWidget(
                    text: "Abonar",
                    size: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
