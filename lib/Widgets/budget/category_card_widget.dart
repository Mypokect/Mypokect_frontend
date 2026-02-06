import 'package:flutter/material.dart';
import 'package:MyPocket/utils/helpers.dart';

class CategoryCardWidget extends StatelessWidget {
  final String name;
  final double amount;
  final Color color;
  final bool isEditing;
  final bool readOnly;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CategoryCardWidget({
    Key? key,
    required this.name,
    required this.amount,
    required this.color,
    this.isEditing = false,
    this.readOnly = false,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: isEditing ? Colors.blue[50] : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border:
              Border.all(color: isEditing ? Colors.blue : Colors.grey[200]!)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(Icons.category, color: color, size: 18)),
        title: Text(name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(formatCurrency(amount)),
        trailing: readOnly
            ? null
            : Row(mainAxisSize: MainAxisSize.min, children: [
                if (onEdit != null)
                  IconButton(
                      icon: const Icon(Icons.edit,
                          size: 20, color: Colors.blueGrey),
                      onPressed: onEdit),
                if (onDelete != null)
                  IconButton(
                      icon: const Icon(Icons.delete,
                          size: 20, color: Colors.redAccent),
                      onPressed: onDelete),
              ]),
      ),
    );
  }
}
