import 'package:flutter/material.dart';

class PaymentMethodButtonWidget extends StatelessWidget {
  final String value;
  final String text;
  final IconData icon;
  final String selectedValue;
  final Color activeColor;
  final VoidCallback onTap;

  const PaymentMethodButtonWidget({
    Key? key,
    required this.value,
    required this.text,
    required this.icon,
    required this.selectedValue,
    required this.activeColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedValue == value;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: isSelected
                  ? activeColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isSelected ? activeColor : Colors.grey[300]!,
                  width: isSelected ? 2 : 1)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18, color: isSelected ? activeColor : Colors.grey),
              const SizedBox(width: 8),
              Text(text,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? activeColor : Colors.grey[600],
                      fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
