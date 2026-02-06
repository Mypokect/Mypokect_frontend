class DashboardUtils {
  // Topes DIAN 2025 (en pesos)
  static const double topeDeclaracion = 69718600; // UVT 1400 * 49799
  static const double uvt2025 = 49799;

  /// Parsea de forma segura un valor dinámico a double
  static double safeParse(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0;
  }

  /// Extrae la lista de alertas del JSON de respuesta
  static List<Map<String, dynamic>> extractAlertsList(Map<String, dynamic> json) {
    if (json['data'] is List) return List<Map<String, dynamic>>.from(json['data']);
    if (json['data'] is Map && json['data']['data'] is List) {
      return List<Map<String, dynamic>>.from(json['data']['data']);
    }
    return [];
  }
}
