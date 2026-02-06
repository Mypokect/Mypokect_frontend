import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Widgets/common/text_widget.dart';
import '../../Theme/Theme.dart';

class PaymentSection extends StatelessWidget {
  final String paymentMethod;
  final Color colorActive;
  final Color colorTexto;
  final Function(String) onPaymentSelected;

  const PaymentSection({
    super.key,
    required this.paymentMethod,
    required this.colorActive,
    required this.colorTexto,
    required this.onPaymentSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _PayOption(
          id: "digital",
          icon: Icons.credit_card_rounded,
          label: "Digital",
          isSelected: paymentMethod == "digital",
          colorActive: colorActive,
          colorTexto: colorTexto,
          onTap: () => onPaymentSelected("digital"),
        ),
        const SizedBox(width: 16),
        _PayOption(
          id: "cash",
          icon: Icons.payments_rounded,
          label: "Efectivo",
          isSelected: paymentMethod == "cash",
          colorActive: colorActive,
          colorTexto: colorTexto,
          onTap: () => onPaymentSelected("cash"),
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
  final Color colorActive;
  final Color colorTexto;
  final VoidCallback onTap;

  const _PayOption({
    required this.id,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.colorActive,
    required this.colorTexto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {
          onTap();
          HapticFeedback.lightImpact();
        },
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? colorActive.withOpacity(0.1)
                : AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? colorActive : Colors.black.withOpacity(0.05),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorActive.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? colorTexto
                    : AppTheme.greyColor.withOpacity(0.4),
              ),
              const SizedBox(width: 10),
              TextWidget(
                text: label,
                size: 13,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? colorTexto
                    : AppTheme.greyColor.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
