// lib/controllers/scheduled_transaction_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:MyPocket/api/scheduled_transaction_api.dart';
import 'package:MyPocket/models/transaction_occurrence.dart';
import 'package:MyPocket/Widgets/common/CustomAlert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduledTransactionController {
  final ScheduledTransactionApi _api = ScheduledTransactionApi();

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('toke');
    if (token == null)
      throw Exception('Token no disponible. Inicia sesión de nuevo.');
    return token;
  }

  void _showErrorAlert(BuildContext context, String title, String message) {
    if (context.mounted) {
      CustomAlert.show(
          context: context,
          title: title,
          message: message.replaceFirst('Exception: ', ''),
          icon: Icons.error_outline,
          color: Colors.red);
    }
  }

  Future<List<TransactionOccurrence>> getOccurrencesForMonth(
      int month, int year, BuildContext context) async {
    try {
      final token = await _getToken();
      final response = await _api.getScheduledTransactions(token, month, year);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .cast<Map<String, dynamic>>()
            .map((json) => TransactionOccurrence.fromJson(json))
            .toList();
      } else {
        throw Exception(
            jsonDecode(response.body)['message'] ?? 'Error al cargar datos');
      }
    } catch (e) {
      _showErrorAlert(context, 'Error de Calendario', e.toString());
      return [];
    }
  }

  Future<bool> updatePaidStatus(
      {required int transactionId,
      required String date,
      required bool isPaid,
      required BuildContext context}) async {
    try {
      final token = await _getToken();
      final response =
          await _api.togglePaidStatus(token, transactionId, date, isPaid);
      return response.statusCode == 200;
    } catch (e) {
      _showErrorAlert(context, 'Error de Actualización', e.toString());
      return false;
    }
  }

  Future<TransactionOccurrence?> createScheduledTransaction(
      {required Map<String, dynamic> data,
      required BuildContext context}) async {
    try {
      final token = await _getToken();
      final response = await _api.createScheduledTransaction(token, data);
      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return TransactionOccurrence.fromJson({
          'id': jsonResponse['id'],
          'title': jsonResponse['title'],
          'amount': jsonResponse['amount'],
          'type': jsonResponse['type'],
          'category': jsonResponse['category'],
          'date': DateFormat('y-MM-dd')
              .format(DateTime.parse(jsonResponse['start_date'])),
          'is_paid': false,
        });
      } else {
        throw Exception(
            jsonDecode(response.body)['message'] ?? 'Error al guardar');
      }
    } catch (e) {
      _showErrorAlert(context, 'Error al Crear', e.toString());
      return null;
    }
  }

  Future<bool> updateScheduledTransaction(
      int id, Map<String, dynamic> data, BuildContext context) async {
    try {
      final token = await _getToken();
      final response = await _api.updateScheduledTransaction(token, id, data);
      if (response.statusCode == 200) {
        if (context.mounted)
          CustomAlert.show(
              context: context,
              title: 'Éxito',
              message: 'La transacción ha sido actualizada.',
              icon: Icons.check_circle_outline,
              color: Colors.green);
        return true;
      } else {
        throw Exception(
            jsonDecode(response.body)['message'] ?? 'Error al actualizar');
      }
    } catch (e) {
      _showErrorAlert(context, 'Error de Actualización', e.toString());
      return false;
    }
  }

  Future<bool> deleteScheduledTransaction(int id, BuildContext context) async {
    try {
      final token = await _getToken();
      final response = await _api.deleteScheduledTransaction(token, id);
      if (response.statusCode == 204) {
        if (context.mounted)
          CustomAlert.show(
              context: context,
              title: 'Eliminado',
              message: 'La transacción ha sido eliminada.',
              icon: Icons.check_circle_outline,
              color: Colors.green);
        return true;
      } else {
        throw Exception('Error al eliminar');
      }
    } catch (e) {
      _showErrorAlert(context, 'Error al Eliminar', e.toString());
      return false;
    }
  }
}
