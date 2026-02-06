import 'package:flutter/material.dart';

class ProcessingOverlayWidget extends StatelessWidget {
  const ProcessingOverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              const SizedBox(height: 20),
              const Text('🤖 Procesando con IA...', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'Baloo2')),
              const SizedBox(height: 8),
              Text('Analizando tu voz', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14, fontFamily: 'Baloo2')),
            ],
          ),
        ),
      ),
    );
  }
}
