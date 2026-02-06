import 'package:flutter/material.dart';

class TipoRecordatorioSelector extends StatefulWidget {
  const TipoRecordatorioSelector({super.key});

  @override
  State<TipoRecordatorioSelector> createState() => _TipoRecordatorioSelectorState();
}

class _TipoRecordatorioSelectorState extends State<TipoRecordatorioSelector> {
  String tipoSeleccionado = 'Único';

  @override
  Widget build(BuildContext context) {
    return Expanded( // ✅ se adapta dentro del Row
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: SegmentedButton<String>(
          showSelectedIcon: false,
          selected: <String>{tipoSeleccionado},
          onSelectionChanged: (Set<String> newSelection) {
            setState(() {
              tipoSeleccionado = newSelection.first;
            });
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (states) => states.contains(WidgetState.selected)
                  ? Colors.green.shade600
                  : Colors.transparent,
            ),
            foregroundColor: WidgetStateProperty.resolveWith<Color?>(
              (states) => states.contains(WidgetState.selected)
                  ? Colors.white
                  : Colors.grey.shade700,
            ),
            textStyle: WidgetStateProperty.all(
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          segments: const <ButtonSegment<String>>[
            ButtonSegment<String>(
              value: 'Único',
              label: Center(child: Text('Único')),
            ),
            ButtonSegment<String>(
              value: 'Mensual',
              label: Center(child: Text('Mensual')),
            ),
          ],
        ),
      ),
    );
  }
}
