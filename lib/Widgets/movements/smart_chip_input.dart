import 'package:flutter/material.dart';

class SmartChipInput extends StatefulWidget {
  final TextEditingController controller; // 1. Recibimos controlador
  final List<String> tags;
  final Function(String) onTagSelected;
  final bool isLocked;

  const SmartChipInput({
    super.key,
    required this.controller,
    required this.tags,
    required this.onTagSelected,
    this.isLocked = false,
  });

  @override
  State<SmartChipInput> createState() => _SmartChipInputState();
}

class _SmartChipInputState extends State<SmartChipInput> {
  // 2. CREAMOS EL FOCUSNODE QUE FALTA
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(); // Inicializar
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Limpiar
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si queremos el efecto "Chip", el campo puede parecer inactivo visualmente,
    // pero el Autocomplete debe controlar la lógica.
    
    return LayoutBuilder(builder: (context, constraints) {
      return RawAutocomplete<String>(
        // 3. PASAR AMBOS OBLIGATORIAMENTE
        focusNode: _focusNode,
        textEditingController: widget.controller,
        
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return widget.tags.take(5); 
          }
          return widget.tags.where((String option) {
            return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
          });
        },
        onSelected: widget.onTagSelected,
        
        // CÓMO SE VE EL INPUT
        fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: widget.isLocked ? const Color(0xFFE8EAF6) : Colors.grey[100], 
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: widget.isLocked ? const Color(0xFF536DFE) : Colors.transparent),
            ),
            child: TextField(
              controller: textController,
              focusNode: focusNode,
              enabled: !widget.isLocked,
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: widget.isLocked ? const Color(0xFF536DFE) : Colors.black87
              ),
              decoration: InputDecoration(
                // Ícono dinámico (💰 si es meta)
                icon: Icon(
                  widget.isLocked ? Icons.savings : Icons.label_outline, 
                  color: widget.isLocked ? const Color(0xFF536DFE) : Colors.grey
                ),
                hintText: "¿Qué categoría es?",
                border: InputBorder.none,
                // Botón para borrar rápido
                suffixIcon: widget.controller.text.isNotEmpty && !widget.isLocked
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18), 
                      onPressed: () => textController.clear()
                    )
                  : null
              ),
            ),
          );
        },
        
        // CÓMO SE VE LA LISTA FLOTANTE
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 8.0,
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              child: Container(
                width: constraints.maxWidth, 
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String option = options.elementAt(index);
                    return ListTile(
                      dense: true,
                      // Si la opción empieza con 💰, se ve diferente
                      leading: Icon(
                        option.contains('💰') ? Icons.savings : Icons.label, 
                        size: 18, 
                        color: Colors.grey
                      ),
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
    });
  }
}