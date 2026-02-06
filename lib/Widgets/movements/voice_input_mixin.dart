import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';

enum VoiceState { idle, listening, processing, success, error }

/// Mixin que encapsula toda la lógica de entrada de voz
mixin VoiceInputMixin<T extends StatefulWidget> on State<T> {
  final SpeechToText speechToText = SpeechToText();

  bool isListening = false;
  bool microphoneAvailable = false;
  bool isProcessingAI = false;
  VoiceState voiceState = VoiceState.idle;
  Timer? recordingTimer;
  int recordingSeconds = 0;

  /// Callback para cuando se obtiene una transcripción
  void onTranscription(String text);

  /// Callback para cuando la transcripción es final y debe procesarse
  Future<void> onFinalTranscription(String text);

  /// Callback para limpiar campos antes de nueva grabación
  void onClearFieldsForNewRecording();

  /// Inicializa el sistema de reconocimiento de voz
  Future<void> initVoice() async {
    microphoneAvailable = await speechToText.initialize();
  }

  /// Alterna entre iniciar y detener la grabación
  void toggleVoice() {
    if (isListening) {
      stopVoice();
    } else {
      startVoice();
    }
  }

  /// Cancela la grabación actual
  Future<void> cancelVoice() async {
    await speechToText.stop();
    HapticFeedback.lightImpact();
    recordingTimer?.cancel();

    setState(() {
      isListening = false;
      voiceState = VoiceState.idle;
      recordingSeconds = 0;
    });

    onClearFieldsForNewRecording();
  }

  /// Inicia la grabación de voz
  Future<void> startVoice() async {
    HapticFeedback.heavyImpact();

    if (!microphoneAvailable) {
      microphoneAvailable = await speechToText.initialize();

      if (!microphoneAvailable) {
        _showMicrophoneUnavailableDialog();
        return;
      }
    }

    if (speechToText.isListening) {
      await speechToText.stop();
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    setState(() {
      isListening = true;
      voiceState = VoiceState.listening;
      recordingSeconds = 0;
    });

    onClearFieldsForNewRecording();

    recordingTimer?.cancel();
    recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => recordingSeconds++);
      }
    });

    try {
      final locales = await speechToText.locales();
      String? spanishLocale;

      for (final locale in locales) {
        if (locale.localeId.startsWith('es-')) {
          spanishLocale = locale.localeId;
          break;
        }
      }

      await speechToText.listen(
        onResult: (res) {
          if (mounted) {
            onTranscription(res.recognizedWords);

            if (res.finalResult && res.recognizedWords.isNotEmpty && isListening) {
              stopVoice();
            }
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        localeId: spanishLocale,
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (!speechToText.isListening && mounted) {
        setState(() {
          isListening = false;
          voiceState = VoiceState.error;
        });
        recordingTimer?.cancel();

        _showSnackBar('No se pudo iniciar el micrófono. Intenta de nuevo.', Colors.orange);

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) setState(() => voiceState = VoiceState.idle);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isListening = false;
          voiceState = VoiceState.error;
        });
        recordingTimer?.cancel();

        _showSnackBar('Error: ${e.toString()}', Colors.red);

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => voiceState = VoiceState.idle);
        });
      }
    }
  }

  /// Detiene la grabación de voz
  Future<void> stopVoice() async {
    if (!isListening) return;

    isListening = false;
    await speechToText.stop();
    HapticFeedback.mediumImpact();
    recordingTimer?.cancel();

    setState(() => voiceState = VoiceState.processing);
  }

  /// Procesa la voz con IA (llamado después de stopVoice)
  Future<void> processVoiceWithAI(String transcription) async {
    if (transcription.isEmpty) {
      setState(() => voiceState = VoiceState.idle);
      return;
    }

    setState(() => isProcessingAI = true);

    try {
      await onFinalTranscription(transcription);

      if (mounted) {
        setState(() {
          voiceState = VoiceState.success;
          isProcessingAI = false;
        });

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) setState(() => voiceState = VoiceState.idle);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          voiceState = VoiceState.error;
          isProcessingAI = false;
        });

        _showSnackBar('Error procesando voz: ${e.toString()}', Colors.red);

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => voiceState = VoiceState.idle);
        });
      }
    }
  }

  void _showMicrophoneUnavailableDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reconocimiento de voz no disponible'),
        content: const Text(
          'El reconocimiento de voz no está disponible en este dispositivo/simulador.\n\n'
          'Para usar esta función:\n'
          '• En dispositivos reales: verifica los permisos de micrófono\n'
          '• En simuladores iOS: usa un dispositivo real o emulador Android\n\n'
          'Puedes continuar ingresando los datos manualmente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Obtiene el color del botón según el estado de voz
  ({Color buttonColor, IconData icon, Color iconColor}) getVoiceButtonStyle(Color activeColor) {
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

  /// Formatea el tiempo de grabación
  String get formattedRecordingTime =>
      '${recordingSeconds ~/ 60}:${(recordingSeconds % 60).toString().padLeft(2, '0')}';

  @mustCallSuper
  void disposeVoice() {
    recordingTimer?.cancel();
  }
}
