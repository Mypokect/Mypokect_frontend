import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import '../../Widgets/common/text_widget.dart';
import '../../Theme/Theme.dart';

class ActionFooter extends StatelessWidget {
  final bool isListening;
  final Color colorTexto;
  final VoidCallback onLongPressMic;
  final VoidCallback onLongPressUpMic;
  final VoidCallback onSave;

  const ActionFooter({
    super.key,
    required this.isListening,
    required this.colorTexto,
    required this.onLongPressMic,
    required this.onLongPressUpMic,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onLongPress: onLongPressMic,
            onLongPressUp: onLongPressUpMic,
            child: AvatarGlow(
              animate: isListening,
              glowColor: colorTexto,
              duration: const Duration(milliseconds: 1500),
              repeat: true,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isListening
                      ? colorTexto.withOpacity(0.1)
                      : AppTheme.backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isListening
                        ? colorTexto
                        : AppTheme.greyColor.withOpacity(0.2),
                    width: isListening ? 2.5 : 1.5,
                  ),
                ),
                child: Icon(
                  Icons.mic_none_rounded,
                  color: isListening
                      ? colorTexto
                      : AppTheme.greyColor.withOpacity(0.5),
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onSave,
              child: Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorTexto,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorTexto.withOpacity(0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextWidget(
                      text: "GUARDAR",
                      color: Colors.white,
                      size: 14,
                      fontWeight: FontWeight.w900,
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
