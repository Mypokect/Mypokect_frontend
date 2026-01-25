import 'package:flutter/material.dart';
import '../../Theme/Theme.dart';

class CampoEtiquetas extends StatefulWidget {
  final TextEditingController etiquetaController;
  final List<String> etiquetasUsuario;
  final Function(String) onEtiquetaSeleccionada;
  final bool isLoadingSuggestion;

  const CampoEtiquetas({
    super.key,
    required this.etiquetaController,
    required this.etiquetasUsuario,
    required this.onEtiquetaSeleccionada,
    this.isLoadingSuggestion = false,
  });

  @override
  State<CampoEtiquetas> createState() => _CampoEtiquetasState();
}

class _CampoEtiquetasState extends State<CampoEtiquetas> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      focusNode: _focusNode,
      textEditingController: widget.etiquetaController,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return widget.etiquetasUsuario;
        }
        return widget.etiquetasUsuario.where((String opcion) {
          return opcion
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        widget.onEtiquetaSeleccionada(selection);
        FocusScope.of(context).unfocus();
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          onSubmitted: (String value) => onFieldSubmitted(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Baloo2',
            color: AppTheme.textColor,
          ),
          decoration: InputDecoration(
            hintText: "Categoría (Ej: Comida)",
            hintStyle: TextStyle(
              color: AppTheme.greyColor.withOpacity(0.5),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            prefixIcon: widget.isLoadingSuggestion
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  )
                : Icon(
                    Icons.label_outline_rounded,
                    color: widget.etiquetaController.text.isEmpty
                        ? AppTheme.greyColor.withOpacity(0.4)
                        : AppTheme.primaryColor,
                    size: 20,
                  ),
            filled: true,
            fillColor: AppTheme.backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: widget.etiquetaController.text.isEmpty
                  ? BorderSide.none
                  : BorderSide(
                      color: AppTheme.primaryColor.withOpacity(0.15),
                      width: 1.5,
                    ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppTheme.primaryColor.withOpacity(0.4),
                width: 2,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            isDense: true,
          ),
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<String> onSelected,
        Iterable<String> options,
      ) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 10,
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 180),
              width: MediaQuery.of(context).size.width - 90,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 6),
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  final bool isMeta = option.startsWith('💰');

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onSelected(option),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isMeta
                                    ? AppTheme.primaryColor.withOpacity(0.15)
                                    : AppTheme.backgroundColor.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isMeta
                                    ? Icons.savings_rounded
                                    : Icons.history_rounded,
                                color: isMeta
                                    ? AppTheme.primaryColor
                                    : AppTheme.greyColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontWeight: isMeta
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: isMeta
                                      ? AppTheme.primaryColor
                                      : AppTheme.textColor,
                                  fontSize: 14,
                                  fontFamily: 'Baloo2',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
