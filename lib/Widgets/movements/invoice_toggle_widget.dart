import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Theme/Theme.dart';
import '../common/text_widget.dart';

class InvoiceToggleWidget extends StatelessWidget {
  final bool hasInvoice;
  final ValueChanged<bool> onChanged;

  const InvoiceToggleWidget({
    super.key,
    required this.hasInvoice,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: hasInvoice ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasInvoice ? AppTheme.primaryColor.withValues(alpha: 0.3) : Colors.grey.shade300,
            width: hasInvoice ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.receipt_long_rounded, size: 22, color: hasInvoice ? AppTheme.primaryColor : Colors.grey.shade400),
            const SizedBox(width: 12),
            Expanded(child: TextWidget(text: "Factura Electrónica", size: 14, fontWeight: FontWeight.w700, color: hasInvoice ? AppTheme.primaryColor : Colors.black87)),
            const SizedBox(width: 8),
            Switch(
              value: hasInvoice,
              onChanged: (value) {
                HapticFeedback.lightImpact();
                onChanged(value);
              },
              activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.5),
              inactiveTrackColor: Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}
