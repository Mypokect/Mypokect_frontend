import 'package:flutter/material.dart';

class CustomAlert {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required Color color,
    required IconData icon,
    Duration duration = const Duration(seconds: 4),
  }) {
    // Primero, verificamos que el contexto siga siendo válido antes de hacer nada.
    if (!context.mounted) return;

    final overlay = Overlay.of(context, rootOverlay: true);
    if (overlay == null) {
      debugPrint('❗ No se pudo obtener el overlay.');
      return;
    }

    late OverlayEntry entry;

    // CAMBIO 1: Añadimos una bandera para saber si la alerta está visible.
    bool isVisible = true;

    // CAMBIO 2: Creamos una función para remover la alerta de forma segura.
    // Esto evita duplicar código y maneja la bandera de estado.
    void removeEntry() {
      // Solo intentamos remover la alerta si todavía está visible.
      if (isVisible) {
        isVisible = false; // Marcamos como no visible para que no se intente remover de nuevo.
        entry.remove();
      }
    }

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 40,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.4), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  // CAMBIO 3: El botón de cerrar ahora usa nuestra función segura.
                  onTap: removeEntry,
                  child: Icon(Icons.close, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    // El temporizador también usa nuestra función segura.
    Future.delayed(duration, removeEntry);
  }
}