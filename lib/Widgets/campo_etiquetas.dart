import 'package:flutter/material.dart';

class CampoEtiquetas extends StatefulWidget {
  final TextEditingController etiquetaController;
  final List<String> etiquetasUsuario;
  final ValueChanged<String> onEtiquetaSeleccionada;

  const CampoEtiquetas({
    super.key,
    required this.etiquetaController,
    required this.etiquetasUsuario,
    required this.onEtiquetaSeleccionada,
  });

  @override
  State<CampoEtiquetas> createState() => _CampoEtiquetasState();
}

class _CampoEtiquetasState extends State<CampoEtiquetas> {
  late FocusNode _focusNode;
  late TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _internalController = TextEditingController(text: widget.etiquetaController.text);

    _internalController.addListener(() {
      widget.etiquetaController.text = _internalController.text;
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _internalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: _internalController,
      focusNode: _focusNode,
      optionsBuilder: (TextEditingValue textEditingValue) {
        final input = textEditingValue.text.toLowerCase();
        if (_focusNode.hasFocus && input.isEmpty) {
          return widget.etiquetasUsuario;
        }
        return widget.etiquetasUsuario.where(
          (option) => option.toLowerCase().contains(input),
        );
      },
      onSelected: (String selection) {
        _internalController.text = selection;
        widget.etiquetaController.text = selection;
        widget.onEtiquetaSeleccionada(selection);
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: textEditingController,
            focusNode: focusNode,
            decoration: const InputDecoration(
              hintText: 'Etiqueta',
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 16),
          ),
        );
      },
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<String> onSelected,
          Iterable<String> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    title: Text(option),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
