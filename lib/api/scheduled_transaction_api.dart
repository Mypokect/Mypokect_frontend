// lib/api/scheduled_transaction_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Services/base_url.dart';

class ScheduledTransactionApi {
  Future<http.Response> getScheduledTransactions(
      String token, int month, int year) async {
    final url = Uri.parse(
        '${BaseUrl.apiUrl}scheduled-transactions?month=$month&year=$year');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });
    return response;
  }

  Future<http.Response> togglePaidStatus(
      String token, int transactionId, String date, bool isPaid) async {
    final url = Uri.parse(
        '${BaseUrl.apiUrl}scheduled-transactions/$transactionId/toggle-paid');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'date': date,
        'is_paid': isPaid,
      }),
    );
    return response;
  }

  Future<http.Response> createScheduledTransaction(
      String token, Map<String, dynamic> data) async {
    final url = Uri.parse('${BaseUrl.apiUrl}scheduled-transactions');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    return response;
  }

  Future<http.Response> updateScheduledTransaction(
      String token, int id, Map<String, dynamic> data) async {
    final url = Uri.parse('${BaseUrl.apiUrl}scheduled-transactions/$id');
    return await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
  }

  Future<http.Response> deleteScheduledTransaction(String token, int id) async {
    final url = Uri.parse('${BaseUrl.apiUrl}scheduled-transactions/$id');
    return await http.delete(url, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });
  }
}
