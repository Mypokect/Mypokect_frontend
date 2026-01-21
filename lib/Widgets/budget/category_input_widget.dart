import 'package:flutter/material.dart';
import 'package:MyPocket/Theme/theme.dart';

class CategoryInputWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController amountController;
  final bool isEditing;
  final bool isListening;
  final VoidCallback onListen;
  final VoidCallback onSave;
  final VoidCallback? onCancel;

  const CategoryInputWidget({
    Key? key,
    required this.nameController,
    required this.amountController,
    required this.isEditing,
    required this.isListening,
    required this.onListen,
    required this.onSave,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: isListening ? Colors.red[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isEditing
                  ? AppTheme.primaryColor
                  : (isListening ? Colors.red : Colors.grey[300]!))),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 15),
          _buildInputRow(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
            isEditing
                ? "Editar Categoría"
                : (isListening ? "Escuchando..." : "Nueva Categoría"),
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isListening ? Colors.red : Colors.black87)),
        GestureDetector(
          onTap: onListen,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: isListening ? Colors.red : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  const BoxShadow(color: Colors.black12, blurRadius: 3)
                ]),
            child: Icon(isListening ? Icons.mic : Icons.mic_none,
                color: isListening ? Colors.white : Colors.black, size: 20),
          ),
        )
      ],
    );
  }

  Widget _buildInputRow() {
    return Row(
      children: [
        Expanded(
            flex: 2,
            child: SizedBox(
                height: 45,
                child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                        hintText: "Nombre (Ej: Hotel)",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10))))),
        const SizedBox(width: 8),
        Expanded(
            flex: 2,
            child: SizedBox(
                height: 45,
                child: TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: "Valor",
                        prefixIcon: const Icon(Icons.attach_money, size: 16),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10))))),
        const SizedBox(width: 8),
        InkWell(
          onTap: onSave,
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
                color: isEditing ? Colors.green : Colors.black,
                borderRadius: BorderRadius.circular(12)),
            child:
                Icon(isEditing ? Icons.check : Icons.add, color: Colors.white),
          ),
        ),
        if (isEditing && onCancel != null) ...[
          const SizedBox(width: 5),
          InkWell(
              onTap: onCancel,
              child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.close, color: Colors.red))),
        ]
      ],
    );
  }
}
