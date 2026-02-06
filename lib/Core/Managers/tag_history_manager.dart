import 'package:shared_preferences/shared_preferences.dart';

class TagHistoryManager {
  static const String _key = 'frequent_tags';
  static const int _maxTags = 10;
  
  // Guardar etiqueta (y ponerla de primera)
  // IMPORTANTE: NO guarda etiquetas de metas (las que empiezan con emoji)
  static Future<void> recordUsage(String tag) async {
    if (tag.isEmpty) return;

    // NO guardar etiquetas de metas (detectadas por emoji al inicio)
    if (_isGoalTag(tag)) {
      return; // Las etiquetas de metas vienen del backend, no del historial local
    }

    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_key) ?? [];

    // Normalizar
    String tagClean = tag.trim();

    // Si ya existe, la quitamos para ponerla de primera
    history.removeWhere((t) => t.toLowerCase() == tagClean.toLowerCase());
    history.insert(0, tagClean);

    // Mantener límite
    if (history.length > _maxTags) {
      history = history.sublist(0, _maxTags);
    }

    await prefs.setStringList(_key, history);
  }

  // Detectar si una etiqueta es de meta (emoji + espacio + nombre)
  static bool _isGoalTag(String tag) {
    if (tag.isEmpty) return false;

    // Las etiquetas de metas tienen formato: "emoji nombre"
    // Ejemplo: "✈️ Viaje a París", "🏖️ Vacaciones"
    // Los emojis ocupan 1-4 bytes en Unicode
    final parts = tag.split(' ');
    if (parts.length < 2) return false;

    final firstPart = parts.first;
    // Un emoji típicamente tiene longitud de runes <= 4
    return firstPart.runes.length <= 4;
  }
  
  // Obtener combinando servidor, local y metas
  static Future<List<String>> getAllTags({List<String>? serverTags, required List<String> goalTags}) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_key) ?? [];
    List<String> server = serverTags ?? [];

    // DEBUG: Ver qué hay en cada fuente
    print('🔍 DEBUG TagHistoryManager.getAllTags:');
    print('  Local history (SharedPreferences): $history');
    print('  Server tags (from /tags endpoint): $server');
    print('  Goal tags (from backend goals): $goalTags');

    // Unificar listas sin duplicados (incluyendo goalTags)
    Set<String> uniqueTags = {...history, ...server, ...goalTags};

    print('  Final unique tags: ${uniqueTags.toList()}');
    return uniqueTags.toList();
  }

  // Eliminar una etiqueta específica del historial local
  // Útil cuando se borra una meta para limpiar su etiqueta huérfana
  static Future<void> removeTag(String tag) async {
    if (tag.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_key) ?? [];

    // Eliminar la etiqueta (case-insensitive)
    history.removeWhere((t) => t.toLowerCase() == tag.toLowerCase());

    await prefs.setStringList(_key, history);
  }

  static Future<void> initialize() async {
    // Para asegurarnos que SharedPreferences esté listo
    await SharedPreferences.getInstance();
  }
}