import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/reminder.dart';

/// Local cache for reminders using SharedPreferences
class ReminderCache {
  static const String _keyPrefix = 'reminders_cache_';
  static const Duration _cacheExpiration = Duration(hours: 1);

  SharedPreferences? _prefs;

  ReminderCache([SharedPreferences? prefs]) : _prefs = prefs;

  /// Initialize SharedPreferences if not already initialized
  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Generate cache key for a specific month and user
  String _getCacheKey(DateTime date, {String? userId}) {
    final uid = userId ?? 'anonymous';
    return '$_keyPrefix${uid}_${date.year}_${date.month}';
  }

  /// Save reminders to cache
  Future<void> saveReminders(
    DateTime month,
    List<Reminder> reminders, {
    String? userId,
  }) async {
    await _ensureInitialized();
    final key = _getCacheKey(month, userId: userId);
    final data = {
      'timestamp': DateTime.now().toIso8601String(),
      'reminders': reminders.map((r) => r.toJson()).toList(),
    };
    await _prefs!.setString(key, jsonEncode(data));
  }

  /// Get cached reminders for a specific month
  Future<List<Reminder>?> getReminders(
    DateTime month, {
    String? userId,
  }) async {
    await _ensureInitialized();
    final key = _getCacheKey(month, userId: userId);
    final cached = _prefs!.getString(key);
    
    if (cached == null) return null;

    try {
      final data = jsonDecode(cached) as Map<String, dynamic>;
      final timestamp = DateTime.parse(data['timestamp'] as String);
      
      // Check if cache is expired
      if (DateTime.now().difference(timestamp) > _cacheExpiration) {
        await clearMonth(month, userId: userId);
        return null;
      }

      final List<dynamic> remindersList = data['reminders'];
      return remindersList.map((json) => Reminder.fromJson(json)).toList();
    } catch (e) {
      // If parsing fails, clear cache
      await clearMonth(month);
      return null;
    }
  }

  /// Clear cache for a specific month
  Future<void> clearMonth(DateTime month, {String? userId}) async {
    await _ensureInitialized();
    final key = _getCacheKey(month, userId: userId);
    await _prefs!.remove(key);
  }

  /// Clear all cached reminders
  Future<void> clear() async {
    await _ensureInitialized();
    final keys = _prefs!.getKeys().where((k) => k.startsWith(_keyPrefix));
    for (final key in keys) {
      await _prefs!.remove(key);
    }
  }

  /// Invalidate cache (clear all)
  Future<void> invalidate() async {
    await clear();
  }
}
