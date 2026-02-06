import 'package:flutter/material.dart';
import 'package:MyPocket/Theme/theme.dart';

class InvoiceAlertCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String mainValue;
  final String secondaryInfo;
  final double? progress;
  final Color color;
  final IconData icon;
  final bool isPositive;
  final bool isNegative;

  const InvoiceAlertCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.mainValue,
    required this.secondaryInfo,
    required this.progress,
    required this.color,
    required this.icon,
    this.isPositive = false,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Baloo2',
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontFamily: 'Baloo2',
                      ),
                    ),
                  ],
                ),
              ),
              if (isPositive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.goalGreen,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "AHORRO",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Baloo2',
                    ),
                  ),
                ),
              if (isNegative)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "PÉRDIDA",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Baloo2',
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 15),

          // Main Value
          Text(
            mainValue,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
              fontFamily: 'Baloo2',
            ),
          ),

          const SizedBox(height: 6),

          // Secondary Info
          Text(
            secondaryInfo,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: 'Baloo2',
            ),
          ),

          // Progress Bar (si aplica)
          if (progress != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress!.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
