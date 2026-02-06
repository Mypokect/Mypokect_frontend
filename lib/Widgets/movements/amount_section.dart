import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Widgets/common/text_widget.dart';
import '../../Theme/Theme.dart';

class AmountSection extends StatelessWidget {
  final bool isGoalMode;
  final bool esGasto;
  final TextEditingController montoController;
  final Color colorTexto;
  final Function(String) onChanged;

  const AmountSection({
    super.key,
    required this.isGoalMode,
    required this.esGasto,
    required this.montoController,
    required this.colorTexto,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextWidget(
            text: "\$",
            size: 48,
            color: AppTheme.greyColor.withOpacity(0.5),
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: montoController,
              keyboardType: TextInputType.number,
              autofocus: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: onChanged,
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w900,
                color: AppTheme.textColor,
                fontFamily: 'Baloo2',
                letterSpacing: -2.5,
                height: 1.1,
              ),
              decoration: InputDecoration(
                hintText: "0",
                hintStyle: TextStyle(
                  color: AppTheme.greyColor.withOpacity(0.3),
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Baloo2',
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
