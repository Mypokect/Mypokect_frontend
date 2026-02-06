import 'package:flutter/material.dart';
import 'package:MyPocket/Theme/theme.dart';

class MoneyInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onChanged;

  const MoneyInputWidget({
    Key? key,
    required this.controller,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Presupuesto Total",
            style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1)),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: AppTheme.primaryColor),
          decoration: const InputDecoration(
              hintText: "\$ 0",
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.black12)),
          onChanged: (_) => onChanged?.call(),
        ),
      ],
    );
  }
}
