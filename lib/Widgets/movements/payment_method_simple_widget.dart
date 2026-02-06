import 'package:flutter/material.dart';

class PaymentMethodSectionSimple extends StatelessWidget {
  final Widget child;

  const PaymentMethodSectionSimple({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Método de Pago",
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}
