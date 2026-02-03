import 'package:flutter/material.dart';
import '../../models/goal_contribution.dart';

/// List item widget for displaying individual contributions in history
class ContributionItem extends StatelessWidget {
  final GoalContribution contribution;
  final VoidCallback? onDelete;
  final bool showDeleteButton;

  const ContributionItem({
    super.key,
    required this.contribution,
    this.onDelete,
    this.showDeleteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildLeading(),
        title: _buildTitle(),
        subtitle: _buildSubtitle(),
        trailing: showDeleteButton ? _buildTrailing(context) : null,
      ),
    );
  }

  /// Leading icon with amount indicator
  Widget _buildLeading() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.add_circle,
        color: Color(0xFF4CAF50),
        size: 24,
      ),
    );
  }

  /// Title showing amount
  Widget _buildTitle() {
    return Text(
      contribution.formattedAmount,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'Baloo2',
        color: Color(0xFF4CAF50),
      ),
    );
  }

  /// Subtitle showing description and date
  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (contribution.description.isNotEmpty) ...[
          Text(
            contribution.description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontFamily: 'Baloo2',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
        ],
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 12,
              color: Colors.grey.shade500,
            ),
            const SizedBox(width: 4),
            Text(
              contribution.formattedDate,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontFamily: 'Baloo2',
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '• ${contribution.relativeTime}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade400,
                fontFamily: 'Baloo2',
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Trailing delete button
  Widget _buildTrailing(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.delete_outline,
        color: Colors.grey.shade400,
        size: 20,
      ),
      onPressed: () => _confirmDelete(context),
    );
  }

  /// Confirm delete dialog
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar abono'),
        content: Text(
          '¿Estás seguro de eliminar este abono de ${contribution.formattedAmount}?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF5350),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

/// Month header for grouped contribution lists
class ContributionMonthHeader extends StatelessWidget {
  final String monthYear;
  final int contributionCount;
  final double totalAmount;

  const ContributionMonthHeader({
    super.key,
    required this.monthYear,
    required this.contributionCount,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(top: 8),
      color: Colors.grey.shade50,
      child: Row(
        children: [
          Expanded(
            child: Text(
              monthYear,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Baloo2',
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Text(
            '$contributionCount ${contributionCount == 1 ? 'abono' : 'abonos'}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontFamily: 'Baloo2',
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _formatAmount(totalAmount),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
                fontFamily: 'Baloo2',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }
}

/// Empty state widget when no contributions exist
class ContributionEmptyState extends StatelessWidget {
  final String goalName;

  const ContributionEmptyState({
    super.key,
    required this.goalName,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.savings_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Sin abonos aún',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Baloo2',
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Comienza a abonar a tu meta "$goalName" para ver tu progreso aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontFamily: 'Baloo2',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
