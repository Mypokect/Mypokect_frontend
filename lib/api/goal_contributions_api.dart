import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/base_url.dart';
import '../models/goal_contribution.dart';

/// API client for managing goal contributions (abonos)
class GoalContributionsApi {
  /// Get all contributions for a specific goal
  Future<List<GoalContribution>> getContributions(String goalId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('toke');

    if (token == null || token.isEmpty) {
      print("DEBUG: No token found");
      return [];
    }

    final url = Uri.parse('${BaseUrl.apiUrl}goal-contributions/$goalId');
    print("DEBUG: Fetching contributions for goal $goalId from: $url");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print("DEBUG: Response status: ${response.statusCode}");
      print("DEBUG: Response body: ${response.body}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        // Handle different response structures
        List<dynamic> list = [];
        if (json is List) {
          list = json;
        } else if (json is Map) {
          final data = json['data'];
          if (data is List) {
            list = data;
          } else if (data is Map) {
            // Double-nested: { data: { data: [...], total: N } }
            list = data['data'] is List ? data['data'] : [];
          } else if (json.containsKey('contributions')) {
            list = json['contributions'];
          }
        }

        final contributions =
            list.map((e) => GoalContribution.fromJson(e)).toList();
        print("DEBUG: Parsed ${contributions.length} contributions");

        // Sort by date (most recent first)
        contributions.sort((a, b) => b.date.compareTo(a.date));

        return contributions;
      } else if (response.statusCode == 404) {
        print("DEBUG: No contributions found for goal");
        return [];
      } else {
        print("DEBUG: Error fetching contributions: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("DEBUG: Exception fetching contributions: $e");
      return [];
    }
  }

  /// Create a new contribution (abono) to a goal
  Future<GoalContribution?> createContribution({
    required String goalId,
    required double amount,
    required String description,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('toke');

    if (token == null || token.isEmpty) {
      print("DEBUG: No token found");
      throw Exception('No se encontró token de autenticación');
    }

    final url = Uri.parse('${BaseUrl.apiUrl}goal-contributions');
    print("DEBUG: Creating contribution at: $url");

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'goal_id': goalId,
              'amount': amount,
              'description': description,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print("DEBUG: Create response status: ${response.statusCode}");
      print("DEBUG: Create response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);

        // Handle different response structures
        Map<String, dynamic> contributionData;
        if (json is Map) {
          if (json.containsKey('data')) {
            contributionData = Map<String, dynamic>.from(json['data']);
          } else if (json.containsKey('contribution')) {
            contributionData = Map<String, dynamic>.from(json['contribution']);
          } else {
            contributionData = Map<String, dynamic>.from(json);
          }
        } else {
          throw Exception('Formato de respuesta inesperado');
        }

        return GoalContribution.fromJson(contributionData);
      } else if (response.statusCode == 400) {
        final json = jsonDecode(response.body);
        final message = json['message'] ?? 'Datos inválidos';
        throw Exception(message);
      } else if (response.statusCode == 404) {
        throw Exception('Meta no encontrada');
      } else {
        throw Exception('Error al crear el abono');
      }
    } catch (e) {
      print("DEBUG: Exception creating contribution: $e");
      if (e is Exception) rethrow;
      throw Exception('Error de conexión al crear el abono');
    }
  }

  /// Delete a contribution
  Future<bool> deleteContribution(String contributionId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('toke');

    if (token == null || token.isEmpty) {
      print("DEBUG: No token found");
      throw Exception('No se encontró token de autenticación');
    }

    final url =
        Uri.parse('${BaseUrl.apiUrl}goal-contributions/$contributionId');
    print("DEBUG: Deleting contribution at: $url");

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print("DEBUG: Delete response status: ${response.statusCode}");
      print("DEBUG: Delete response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("DEBUG: Contribution deleted successfully");
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Abono no encontrado');
      } else {
        throw Exception('Error al eliminar el abono');
      }
    } catch (e) {
      print("DEBUG: Exception deleting contribution: $e");
      if (e is Exception) rethrow;
      throw Exception('Error de conexión al eliminar el abono');
    }
  }

  /// Get statistics for a goal's contributions
  Future<Map<String, dynamic>> getStats(String goalId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('toke');

    if (token == null || token.isEmpty) {
      print("DEBUG: No token found");
      return {
        'total_contributions': 0,
        'total_amount': 0.0,
        'average_contribution': 0.0,
        'largest_contribution': 0.0,
        'smallest_contribution': 0.0,
        'last_contribution_date': null,
      };
    }

    final url = Uri.parse('${BaseUrl.apiUrl}goal-contributions/$goalId/stats');
    print("DEBUG: Fetching stats for goal $goalId from: $url");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print("DEBUG: Stats response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        // Handle different response structures
        if (json is Map) {
          if (json.containsKey('data')) {
            return Map<String, dynamic>.from(json['data']);
          } else if (json.containsKey('stats')) {
            return Map<String, dynamic>.from(json['stats']);
          } else {
            return Map<String, dynamic>.from(json);
          }
        }
      } else if (response.statusCode == 404) {
        // If stats endpoint doesn't exist, calculate from contributions
        print(
            "DEBUG: Stats endpoint not found, will calculate from contributions");
        return _calculateStatsLocally(goalId);
      }
    } catch (e) {
      print("DEBUG: Exception fetching stats: $e");
      // Fall back to local calculation
      return _calculateStatsLocally(goalId);
    }

    return {
      'total_contributions': 0,
      'total_amount': 0.0,
      'average_contribution': 0.0,
      'largest_contribution': 0.0,
      'smallest_contribution': 0.0,
      'last_contribution_date': null,
    };
  }

  /// Calculate stats locally if backend doesn't provide endpoint
  Future<Map<String, dynamic>> _calculateStatsLocally(String goalId) async {
    try {
      final contributions = await getContributions(goalId);

      if (contributions.isEmpty) {
        return {
          'total_contributions': 0,
          'total_amount': 0.0,
          'average_contribution': 0.0,
          'largest_contribution': 0.0,
          'smallest_contribution': 0.0,
          'last_contribution_date': null,
        };
      }

      final totalAmount =
          contributions.fold<double>(0.0, (sum, c) => sum + c.amount);
      final amounts = contributions.map((c) => c.amount).toList();
      amounts.sort();

      return {
        'total_contributions': contributions.length,
        'total_amount': totalAmount,
        'average_contribution': totalAmount / contributions.length,
        'largest_contribution': amounts.last,
        'smallest_contribution': amounts.first,
        'last_contribution_date': contributions.first.date.toIso8601String(),
      };
    } catch (e) {
      print("DEBUG: Error calculating stats locally: $e");
      return {
        'total_contributions': 0,
        'total_amount': 0.0,
        'average_contribution': 0.0,
        'largest_contribution': 0.0,
        'smallest_contribution': 0.0,
        'last_contribution_date': null,
      };
    }
  }

  /// Get contributions grouped by month
  Future<Map<String, List<GoalContribution>>> getContributionsByMonth(
      String goalId) async {
    final contributions = await getContributions(goalId);
    final grouped = <String, List<GoalContribution>>{};

    for (final contribution in contributions) {
      final key = contribution.monthYear;
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(contribution);
    }

    return grouped;
  }
}
