import 'package:flutter/material.dart';
import '../../Theme/Theme.dart';
import 'campo_etiquetas.dart';

class DataSection extends StatelessWidget {
  final TextEditingController nombreController;
  final TextEditingController etiquetaController;
  final List<String> etiquetasUsuario;
  final Function(String) onEtiquetaSeleccionada;

  const DataSection({
    super.key,
    required this.nombreController,
    required this.etiquetaController,
    required this.etiquetasUsuario,
    required this.onEtiquetaSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: nombreController,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Baloo2',
            color: AppTheme.textColor,
          ),
          decoration: InputDecoration(
            hintText: "Descripción breve...",
            hintStyle: TextStyle(
              color: AppTheme.greyColor.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: AppTheme.backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),
        const SizedBox(height: 16),
        CampoEtiquetas(
          etiquetaController: etiquetaController,
          etiquetasUsuario: etiquetasUsuario,
          onEtiquetaSeleccionada: onEtiquetaSeleccionada,
        ),
      ],
    );
  }
}
