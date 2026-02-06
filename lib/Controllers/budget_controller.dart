import 'package:flutter/material.dart';

import '../api/budget_api.dart';

class BudgetController {
  final BudgetApi _budgetApi = BudgetApi();

  // --- STATE ---
  bool isLoading = false;
  bool isSaving = false;
  Map<String, dynamic>? budgetResult;
  List<Map<String, dynamic>> categories = [];

  final List<Color> colors = [
    const Color(0xFF4E9F3D),
    const Color(0xFFD83A56),
    const Color(0xFFFF8E00),
    const Color(0xFF27496D),
    const Color(0xFF9A0680),
    const Color(0xFF00ADB5),
    const Color(0xFFFFC75F),
  ];

  // --- BUDGET OPERATIONS ---

  Future<Map<String, dynamic>> generateBudgetPlan(
      String title, double amount, String description) async {
    try {
      isLoading = true;
      final result =
          await _budgetApi.generateBudgetPlan(title, amount, description);
      isLoading = false;
      return result;
    } catch (e) {
      isLoading = false;
      rethrow;
    }
  }

  Future<void> createManualBudget(String title, double amount,
      String description, List<Map<String, dynamic>> categoriesList) async {
    try {
      isSaving = true;
      await _budgetApi.createManualBudget(
          title, amount, description, categoriesList);
      isSaving = false;
    } catch (e) {
      isSaving = false;
      rethrow;
    }
  }

  Future<void> saveAIBudget(String title, double amount, String description,
      List<Map<String, dynamic>> categoriesList) async {
    try {
      isSaving = true;
      await _budgetApi.saveAIBudget(title, amount, description, categoriesList);
      isSaving = false;
    } catch (e) {
      isSaving = false;
      rethrow;
    }
  }

  Future<void> saveBudgetPlan(
      String title,
      double totalAmount,
      String description,
      List<Map<String, dynamic>> categoriesList,
      String mode) async {
    try {
      isSaving = true;
      await _budgetApi.saveBudgetPlan(
          title, totalAmount, description, categoriesList, mode);
      isSaving = false;
    } catch (e) {
      isSaving = false;
      rethrow;
    }
  }

  Future<List<dynamic>> getBudgets() async {
    try {
      return await _budgetApi.getBudgets();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBudget(int id, String title, double amount,
      String description, List<Map<String, dynamic>> categoriesList) async {
    try {
      isSaving = true;
      await _budgetApi.updateBudget(
          id, title, amount, description, categoriesList);
      isSaving = false;
    } catch (e) {
      isSaving = false;
      rethrow;
    }
  }

  Future<void> deleteBudget(int id) async {
    try {
      await _budgetApi.deleteBudget(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> processVoiceCommand(String text) async {
    try {
      return await _budgetApi.processVoiceCommand(text);
    } catch (e) {
      rethrow;
    }
  }

  // --- CATEGORY OPERATIONS ---
  void addCategory({
    required String name,
    required double amount,
  }) {
    final colorIndex = categories.length % colors.length;

    categories.add({
      'name': name,
      'amount': amount,
      'color': colors[colorIndex].value.toRadixString(16).substring(2),
    });
  }

  void removeCategory(int index) {
    if (index >= 0 && index < categories.length) {
      categories.removeAt(index);
    }
  }

  void clearCategories() {
    categories.clear();
  }
}
