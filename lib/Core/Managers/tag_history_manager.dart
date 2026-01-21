import 'package:shared_preferences/shared_preferences.dart';

class TagHistoryManager {
  static const String _key = 'frequent_tags';
  static const int _maxTags = 10;
  
  // Guardar etiqueta (y ponerla de primera)
  static Future<void> recordUsage(String tag) async {
    if (tag.isEmpty) return;
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
  
  // Obtener combinando servidor y local
  static Future<List<String>> getAllTags({List<String>? serverTags, required List<String> goalTags}) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_key) ?? [];
    List<String> server = serverTags ?? [];

    // Unificar listas sin duplicados
    Set<String> uniqueTags = {...history, ...server};
    return uniqueTags.toList();
  }

  static Future<void> initialize() async {
    // Para asegurarnos que SharedPreferences esté listo
    await SharedPreferences.getInstance();
  }
}