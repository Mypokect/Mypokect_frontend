// Archivo: Widgets/home/principal_actions_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Asegúrate de que las rutas de importación sean correctas para tu proyecto
import 'package:MyPocket/Theme/theme.dart';
import 'package:MyPocket/Widgets/common/text_widget.dart';

// 1. Clase Modelo para organizar los datos de cada tarjeta
class ActionCardData {
  final String title;
  final String? iconPath; // Para íconos en assets (SVG, PNG)
  final IconData? iconData; // Para Material Icons
  final VoidCallback onTap;

  ActionCardData({
    required this.title,
    this.iconPath,
    this.iconData,
    required this.onTap,
  }) : assert(iconPath != null || iconData != null,
            "Debes proveer un iconPath o un iconData");
}

// 2. El Widget reutilizable que muestra la lista de tarjetas
class PrincipalActionsWidget extends StatelessWidget {
  final List<ActionCardData> actions;

  const PrincipalActionsWidget({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 20, right: 5),
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return _buildCard(
              action.title, action.iconPath, action.iconData, action.onTap);
        },
      ),
    );
  }

  // El método para construir cada tarjeta individual ahora pertenece a este widget
  Widget _buildCard(
      String title, String? iconPath, IconData? iconData, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 15, top: 10, bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(50),
              ),
              child: iconPath != null
                  ? SvgPicture.asset(
                      iconPath,
                      colorFilter: ColorFilter.mode(
                        Colors.grey[600]!,
                        BlendMode.srcIn,
                      ),
                    )
                  : Icon(iconData, color: Colors.grey[600], size: 30),
            ),
            const SizedBox(height: 10),
            TextWidget(
              text: title,
              color: AppTheme.greyColor,
              size: 14,
              fontWeight: FontWeight.w500,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
