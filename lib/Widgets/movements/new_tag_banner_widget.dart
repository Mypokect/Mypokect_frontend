import 'package:flutter/material.dart';

class NewTagBannerWidget extends StatelessWidget {
  final String tagName;

  const NewTagBannerWidget({super.key, required this.tagName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '"$tagName" se creará como nueva etiqueta al guardar',
              style: TextStyle(fontSize: 12, color: Colors.blue.shade700, fontFamily: 'Baloo2', fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
