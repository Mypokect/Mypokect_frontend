import 'package:flutter/material.dart';

import '../api/user_api.dart';

class HomeController {
  final UserApi _userApi = UserApi();

  // --- DATA STATE ---
  String userName = "Cargando...";
  double balance = 0.0;
  bool isLoading = true;
  String statusLabel = "Analizando...";
  Color statusColor = const Color(0xFF006B52);
  IconData statusIcon = Icons.bar_chart_rounded;

  // --- LOAD HOME DATA ---
  Future<void> loadHomeData({Function()? onDataLoaded}) async {
    try {
      final data = await _userApi.getHomeData();

      // Mapeo de colores desde el Backend
      Color color = const Color(0xFF006B52);
      if (data['status_color'] == 'green') {
        color = Colors.green;
      } else if (data['status_color'] == 'red') {
        color = Colors.red;
      } else if (data['status_color'] == 'orange') {
        color = Colors.orange;
      }

      // Mapeo de íconos
      IconData icon = Icons.bar_chart_rounded;
      if (data['icon_type'] == 'up') {
        icon = Icons.trending_up;
      } else if (data['icon_type'] == 'down') {
        icon = Icons.trending_down;
      }

      // Actualizar estado
      userName = data['name'];
      balance = double.parse(data['balance'].toString());
      statusLabel = data['status_label'] ?? "Sin datos";
      statusColor = color;
      statusIcon = icon;
      isLoading = false;

      if (onDataLoaded != null) {
        onDataLoaded();
      }
    } catch (e) {
      isLoading = false;
      if (onDataLoaded != null) {
        onDataLoaded();
      }
      rethrow;
    }
  }
}
