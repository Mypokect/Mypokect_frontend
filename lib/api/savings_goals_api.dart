import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/base_url.dart';
import '../models/savings_goal.dart';

class SavingsGoalsApi {
  static List<SavingsGoal>? _goalsCache;
  static DateTime? _cacheTimestamp;
  static const Duration _cacheValidity = Duration(minutes: 5);

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('toke');
    if (token == null || token.isEmpty) {
      throw Exception('No se encontró token de autenticación');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<List<SavingsGoal>> getGoals() async {
    final now = DateTime.now();

    if (_goalsCache != null &&
        _cacheTimestamp != null &&
        now.difference(_cacheTimestamp!).abs() < _cacheValidity) {
      return _goalsCache!;
    }

    final url = Uri.parse('${BaseUrl.apiUrl}saving-goals');

    try {
      final response = await http.get(
        url,
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        List<dynamic> list = [];
        if (json is List) {
          list = json;
        } else if (json is Map) {
          if (json.containsKey('data')) {
            final data = json['data'];
            list = data is List ? data : [];
          } else if (json.containsKey('goals')) {
            list = json['goals'];
          }
        }

        final goals = list.map((e) => SavingsGoal.fromJson(e)).toList();
        _goalsCache = goals;
        _cacheTimestamp = now;
        return goals;
      } else if (response.statusCode == 401) {
        _goalsCache = null;
        _cacheTimestamp = null;
        return [];
      }
    } on FormatException {
      if (_goalsCache != null) return _goalsCache!;
    } catch (e) {
      if (_goalsCache != null) return _goalsCache!;
    }
    return [];
  }

  static void clearCache() {
    _goalsCache = null;
    _cacheTimestamp = null;
  }

  /// Create a new savings goal
  /// Backend expects: name, target_amount, emoji, color, deadline (optional)
  Future<http.Response> createGoal({
    required String name,
    required double targetAmount,
    required String emoji,
    required String color,
    DateTime? deadline,
  }) async {
    clearCache();

    final url = Uri.parse('${BaseUrl.apiUrl}saving-goals');

    return await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({
        'name': name,
        'target_amount': targetAmount,
        'emoji': emoji,
        'color': color,
        if (deadline != null) 'deadline': deadline.toIso8601String(),
      }),
    );
  }

  /// Update a savings goal
  /// Backend accepts: name, target_amount, emoji, color, deadline (all optional)
  Future<http.Response> updateGoal({
    required String id,
    String? name,
    double? targetAmount,
    String? emoji,
    String? color,
    DateTime? deadline,
  }) async {
    clearCache();

    final url = Uri.parse('${BaseUrl.apiUrl}saving-goals/$id');

    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (targetAmount != null) body['target_amount'] = targetAmount;
    if (emoji != null) body['emoji'] = emoji;
    if (color != null) body['color'] = color;
    if (deadline != null) body['deadline'] = deadline.toIso8601String();

    return await http.put(
      url,
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
  }

  /// Get a single goal by ID
  Future<SavingsGoal?> getGoalById(String id) async {
    final url = Uri.parse('${BaseUrl.apiUrl}saving-goals/$id');

    try {
      final response = await http.get(
        url,
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        Map<String, dynamic> goalData;
        if (json is Map) {
          if (json.containsKey('data')) {
            goalData = Map<String, dynamic>.from(json['data']);
          } else {
            goalData = Map<String, dynamic>.from(json);
          }
        } else {
          return null;
        }

        return SavingsGoal.fromJson(goalData);
      }
    } catch (e) {
      print("DEBUG: Exception fetching goal: $e");
    }
    return null;
  }

  /// Delete a goal by ID
  Future<bool> deleteGoal(String id) async {
    clearCache();

    final url = Uri.parse('${BaseUrl.apiUrl}saving-goals/$id');

    try {
      final response = await http.delete(
        url,
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Meta no encontrada');
      } else if (response.statusCode == 409) {
        final json = jsonDecode(response.body);
        final message = json['message'] ?? 'No se puede eliminar la meta';
        throw Exception(message);
      } else {
        throw Exception('Error al eliminar la meta');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error de conexión al eliminar la meta');
    }
  }
}
