import 'package:flutter/material.dart';
import '../../utils/movement_utils.dart';
import '../common/text_widget.dart';
import 'sound_wave_animation.dart';
import 'voice_input_mixin.dart';

class FooterActionsWidget extends StatelessWidget {
  final Color activeColor;
  final VoiceState voiceState;
  final bool microphoneAvailable;
  final int recordingSeconds;
  final VoidCallback onMicTap;
  final VoidCallback onMicLongPress;
  final VoidCallback? onMicLongPressUp;
  final VoidCallback onCancelVoice;
  final VoidCallback onSave;

  const FooterActionsWidget({
    super.key,
    required this.activeColor,
    required this.voiceState,
    required this.microphoneAvailable,
    required this.recordingSeconds,
    required this.onMicTap,
    required this.onMicLongPress,
    this.onMicLongPressUp,
    required this.onCancelVoice,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        MovementUtils.responsivePadding(context),
        0,
        MovementUtils.responsivePadding(context),
        MovementUtils.responsiveSpacing(context, 45),
      ),
      color: Colors.white,
      child: Row(
        children: [
          _buildMicButton(),
          if (voiceState == VoiceState.listening) ...[
            const SizedBox(width: 12),
            _buildCancelButton(),
          ],
          const SizedBox(width: 18),
          Expanded(child: _buildSaveButton()),
        ],
      ),
    );
  }

  Widget _buildMicButton() {
    if (!microphoneAvailable) {
      return _buildDisabledMicButton();
    }

    final style = _getVoiceButtonStyle();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: voiceState == VoiceState.idle || voiceState == VoiceState.listening
              ? onMicTap
              : null,
          onLongPress: voiceState == VoiceState.idle ? onMicLongPress : null,
          onLongPressUp: onMicLongPressUp,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (voiceState == VoiceState.listening)
                SoundWaveAnimation(color: activeColor, size: 62),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: style.buttonColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: voiceState == VoiceState.listening
                        ? activeColor
                        : Colors.black.withValues(alpha: 0.05),
                    width: voiceState == VoiceState.listening ? 2 : 1,
                  ),
                  boxShadow: voiceState == VoiceState.listening
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          )
                        ]
                      : null,
                ),
                child: voiceState == VoiceState.processing
                    ? Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(style.iconColor),
                          ),
                        ),
                      )
                    : Icon(style.icon, color: style.iconColor, size: 28),
              ),
            ],
          ),
        ),
        if (voiceState == VoiceState.listening)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _formattedTime,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: activeColor,
                fontFamily: 'Baloo2',
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDisabledMicButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: 0.4,
          child: GestureDetector(
            onTap: onMicTap,
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: Icon(Icons.mic_off_rounded, color: Colors.grey.shade400, size: 28),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCancelButton() {
    return GestureDetector(
      onTap: onCancelVoice,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.red.shade200, width: 1.5),
        ),
        child: Icon(Icons.close_rounded, color: Colors.red.shade600, size: 24),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: onSave,
      child: Container(
        height: 62,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: activeColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: activeColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextWidget(
              text: "GUARDAR",
              color: Colors.white,
              size: 15,
              fontWeight: FontWeight.w900,
            ),
            SizedBox(width: 8),
            Icon(Icons.check_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  ({Color buttonColor, IconData icon, Color iconColor}) _getVoiceButtonStyle() {
    switch (voiceState) {
      case VoiceState.idle:
        return (
          buttonColor: Colors.grey.shade50,
          icon: Icons.mic_none_rounded,
          iconColor: activeColor.withValues(alpha: 0.6),
        );
      case VoiceState.listening:
        return (
          buttonColor: activeColor.withValues(alpha: 0.1),
          icon: Icons.mic_rounded,
          iconColor: activeColor,
        );
      case VoiceState.processing:
        return (
          buttonColor: Colors.blue.shade50,
          icon: Icons.mic_rounded,
          iconColor: Colors.blue,
        );
      case VoiceState.success:
        return (
          buttonColor: Colors.green.shade50,
          icon: Icons.check_circle_rounded,
          iconColor: Colors.green,
        );
      case VoiceState.error:
        return (
          buttonColor: Colors.red.shade50,
          icon: Icons.error_rounded,
          iconColor: Colors.red,
        );
    }
  }

  String get _formattedTime =>
      '${recordingSeconds ~/ 60}:${(recordingSeconds % 60).toString().padLeft(2, '0')}';
}
