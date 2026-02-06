import 'package:flutter/material.dart';
import 'package:MyPocket/Widgets/common/button_custom.dart';

class SaveButtonSectionWidget extends StatelessWidget {
  final Widget voiceButton;
  final VoidCallback? onSave;
  final Color mainColor;

  const SaveButtonSectionWidget({
    Key? key,
    required this.voiceButton,
    required this.onSave,
    required this.mainColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            voiceButton,
            const SizedBox(width: 20),
            Expanded(
              child: ButtonCustom(
                text: "Guardar",
                onTap: onSave,
                color: mainColor,
              ),
            )
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
