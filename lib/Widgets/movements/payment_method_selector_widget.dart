import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../common/text_widget.dart';

class PaymentMethodSelectorWidget extends StatelessWidget {
  final String selectedMethod;
  final Color activeColor;
  final ValueChanged<String> onChanged;

  const PaymentMethodSelectorWidget({
    super.key,
    required this.selectedMethod,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(text: "MÉTODO DE PAGO", size: 10, fontWeight: FontWeight.w800, color: Colors.grey.shade500),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _PayOption(id: "digital", icon: Icons.credit_card_rounded, label: "Digital", isSelected: selectedMethod == "digital", activeColor: activeColor, onTap: () => onChanged("digital"))),
            const SizedBox(width: 12),
            Expanded(child: _PayOption(id: "cash", icon: Icons.payments_rounded, label: "Efectivo", isSelected: selectedMethod == "cash", activeColor: activeColor, onTap: () => onChanged("cash"))),
          ],
        ),
      ],
    );
  }
}

class _PayOption extends StatelessWidget {
  final String id;
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _PayOption({
    required this.id,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? activeColor : Colors.grey.shade300, width: isSelected ? 2 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: isSelected ? Colors.white : Colors.grey.shade400),
            const SizedBox(width: 8),
            TextWidget(text: label, size: 13, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : Colors.black87),
          ],
        ),
      ),
    );
  }
}
