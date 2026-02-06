import 'package:flutter/material.dart';
import 'package:MyPocket/Widgets/common/text_widget.dart';
import 'package:MyPocket/utils/helpers.dart';

class SavingsInfoRowWidget extends StatelessWidget {
  final String label;
  final dynamic value;

  const SavingsInfoRowWidget({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double amount = value is num ? value.toDouble() : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget(text: label, color: Colors.grey, size: 14),
          TextWidget(
              text: formatCurrency(amount),
              fontWeight: FontWeight.bold,
              size: 14),
        ],
      ),
    );
  }
}
