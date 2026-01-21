import 'package:flutter/material.dart';
import 'package:MyPocket/Widgets/common/text_widget.dart';
import 'package:flutter/scheduler.dart';

class SavingsGoalCardWidget extends StatelessWidget {
  final String name;
  final String emoji;
  final IconData icon;
  final Color color;
  final double currentAmount;
  final double targetAmount;
  final VoidCallback onContribute;
  final int index;

  const SavingsGoalCardWidget({
    super.key,
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onContribute,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      value: progress,
                      backgroundColor: color.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      strokeWidth: 5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextWidget(
                    text: emoji,
                    size: 18,
                  ),
                  const SizedBox(height: 2),
                  TextWidget(
                    text: name,
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: TextWidget(
                      text: percentage,
                      size: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextWidget(
                    text: '$currentFormatted / $targetFormatted',
                    size: 10,
                    color: Colors.grey[600]!,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color,
                          color.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onContribute,
                        borderRadius: BorderRadius.circular(10),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: Colors.white, size: 12),
                              SizedBox(width: 3),
                              TextWidget(
                                text: "Abonar",
                                size: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (progress >= 1.0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
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
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
