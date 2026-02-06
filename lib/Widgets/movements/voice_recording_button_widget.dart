import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';

class VoiceRecordingButtonWidget extends StatelessWidget {
  final bool isListening;
  final Color mainColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const VoiceRecordingButtonWidget({
    Key? key,
    required this.isListening,
    required this.mainColor,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AvatarGlow(
        animate: isListening,
        glowColor: mainColor,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                  color: isListening ? Colors.red : Colors.grey[300]!,
                  width: 2)),
          child: Icon(Icons.mic, color: isListening ? Colors.red : mainColor),
        ),
      ),
    );
  }
}
