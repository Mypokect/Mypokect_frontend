import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/base_url.dart';
import '../models/savings_goal.dart';

class SavingsGoalsApi {
  static List<SavingsGoal>? _goalsCache;
  static DateTime? _cacheTimestamp;
  static const Duration _cacheValidity = Duration(minutes: 5);

  Future<List<SavingsGoal>> getGoals() async {
    final now = DateTime.now();

    // Temporarily disable cache for debugging
    // if (_goalsCache != null &&
    //     _cacheTimestamp != null &&
    //     now.difference(_cacheTimestamp!).abs() < _cacheValidity) {
    //   return _goalsCache!;
    // }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('toke');

    if (token == null || token.isEmpty) {
      print("DEBUG: No token found");
      return [];
    }

    final url = Uri.parse('${BaseUrl.apiUrl}saving-goals');
    print("DEBUG: Fetching goals from: $url");
    print("DEBUG: Full URL: ${url.toString()}");
    print("DEBUG: Token: ${token.substring(0, 10)}...");
    print("DEBUG: Expected Laravel endpoints:");
    print("  GET ${BaseUrl.apiUrl}saving-goals -> SavingGoalController@index");
    print("  POST ${BaseUrl.apiUrl}saving-goals -> SavingGoalController@store");
    print(
        "  GET ${BaseUrl.apiUrl}saving-goals/{id} -> SavingGoalController@show");
    print(
        "  PUT ${BaseUrl.apiUrl}saving-goals/{id} -> SavingGoalController@update");
    print(
        "  DELETE ${BaseUrl.apiUrl}saving-goals/{id} -> SavingGoalController@destroy");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
      );

      print("DEBUG: Response status: ${response.statusCode}");
      print("DEBUG: Response body: ${response.body}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print("DEBUG: Parsed JSON: $json");

// Try different possible response structures from Laravel
        List<dynamic> list = [];

        if (json is List) {
          list = json;
          print("DEBUG: Response is direct list with ${json.length} items");
        } else if (json is Map) {
          if (json.containsKey('data')) {
            list = json['data'];
            print("DEBUG: Using 'data' key");
          } else if (json.containsKey('goals')) {
            list = json['goals'];
            print("DEBUG: Using 'goals' key");
          } else if (json.containsKey('saving_goals')) {
            list = json['saving_goals'];
            print("DEBUG: Using 'saving_goals' key");
          } else {
            print(
                "DEBUG: Unknown response structure. Available keys: ${(json as Map).keys.toList()}");
          }
        } else {
          print(
              "DEBUG: Response is neither List nor Map. Type: ${json.runtimeType}");
        }

        print("DEBUG: Final goals list: $list");

        try {
          final goals = list.map((e) => SavingsGoal.fromJson(e)).toList();
          print("DEBUG: Parsed goals count: ${goals.length}");

          _goalsCache = goals;
          _cacheTimestamp = now;
          return goals;
        } catch (e) {
          print("DEBUG: Error parsing goals: $e");
          print(
              "DEBUG: First item for debug: ${list.isNotEmpty ? list[0] : 'No items'}");
          return [];
        }
      } else if (response.statusCode == 401) {
        print("DEBUG: Unauthorized - clearing cache");
        _goalsCache = null;
        _cacheTimestamp = null;
        return [];
      } else {
        print("DEBUG: Error response:");
        print("  Status: ${response.statusCode}");
        print("  Body: ${response.body}");
        print("  Headers: ${response.headers}");

        if (response.statusCode == 404) {
          print(
              "DEBUG: 404 Not Found - Verificar ruta Laravel: /api/saving-goals");
        } else if (response.statusCode == 500) {
          print(
              "DEBUG: 500 Server Error - Verificar controller o log del servidor");
        } else if (response.statusCode == 403) {
          print("DEBUG: 403 Forbidden - Verificar middleware de autenticación");
        }
      }
    } on FormatException catch (e) {
      print("DEBUG: Format exception: $e");
      if (_goalsCache != null) {
        return _goalsCache!;
      }
      return [];
    } on Exception catch (e) {
      print("DEBUG: General exception: $e");
      if (_goalsCache != null) {
        return _goalsCache!;
      }
      return [];
    }
    return [];
  }

  Future<http.Response> testConnection() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('toke');

    final url = Uri.parse('${BaseUrl.apiUrl}saving-goals');
    print("DEBUG: Testing connection to: $url");
    print("DEBUG: Token exists: ${token != null && token.isNotEmpty}");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      print("DEBUG: Connection test response:");
      print("  Status: ${response.statusCode}");
      print("  Body: ${response.body}");

      return response;
    } catch (e) {
      print("DEBUG: Connection test failed: $e");
      return http.Response('Connection failed: $e', 500);
    }
  }

  static void clearCache() {
    _goalsCache = null;
    _cacheTimestamp = null;
  }

  Future<http.Response> createGoal({
    required String name,
    required String tag,
    required double targetAmount,
    required String emoji,
    required String icon,
    required String color,
  }) async {
    clearCache();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('toke');

    final url = Uri.parse('${BaseUrl.apiUrl}saving-goals');

    return await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'tag': tag,
        'target_amount': targetAmount,
        'emoji': emoji,
        'icon': icon,
        'color': color,
      }),
    );
  }

  Future<http.Response> updateGoal({
    required String id,
    required double currentAmount,
  }) async {
    clearCache();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('toke');

    final url = Uri.parse('${BaseUrl.apiUrl}saving-goals/$id');

    return await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'current_amount': currentAmount,
      }),
    );
  }
}
