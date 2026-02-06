import 'package:flutter/material.dart';

class ModeSwitchWidget extends StatelessWidget {
  final String currentMode;
  final ValueChanged<String> onModeChanged;

  const ModeSwitchWidget({
    Key? key,
    required this.currentMode,
    required this.onModeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(25)),
        child: Row(children: [
          ModeOptionWidget(
              text: "Manual",
              icon: Icons.edit,
              isActive: currentMode == 'manual',
              onTap: () => onModeChanged('manual')),
          ModeOptionWidget(
              text: "Asistente IA",
              icon: Icons.auto_awesome,
              isActive: currentMode == 'ia',
              onTap: () => onModeChanged('ia'))
        ]));
  }
}

class ModeOptionWidget extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const ModeOptionWidget({
    Key? key,
    required this.text,
    required this.icon,
    required this.isActive,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: isActive
                        ? [
                            const BoxShadow(
                                color: Colors.black12, blurRadius: 5)
                          ]
                        : []),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(icon,
                      size: 16, color: isActive ? Colors.black : Colors.grey),
                  const SizedBox(width: 8),
                  Text(text,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.black : Colors.grey,
                          fontSize: 13))
                ]))));
  }
}
