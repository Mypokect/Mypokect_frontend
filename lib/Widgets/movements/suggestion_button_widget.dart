import 'package:flutter/material.dart';
import '../../Theme/Theme.dart';

class SuggestionButtonWidget extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const SuggestionButtonWidget({
    super.key,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: isLoading ? Colors.grey.shade300 : AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3), width: 1.5),
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor)),
                ),
              )
            : Icon(Icons.lightbulb_outline_rounded, color: AppTheme.primaryColor, size: 22),
      ),
    );
  }
}
