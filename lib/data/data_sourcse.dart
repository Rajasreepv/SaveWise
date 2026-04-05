
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import '../models/goal_model.dart';



class LocalDataSource {
  static const _txKey        = 'transactions_v1';
  static const _goalKey      = 'goal_v1';
  static const _userNameKey  = 'profile_username';
  static const _darkModeKey  = 'profile_darkmode';

  

  Future<List<TransactionModel>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_txKey);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(transactions.map((t) => t.toJson()).toList());
    await prefs.setString(_txKey, encoded);
  }

  

  Future<GoalModel> loadGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_goalKey);
    if (raw == null || raw.isEmpty) return GoalModel.empty();
    return GoalModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  
  
  Future<GoalModel?> loadGoalOrNull() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_goalKey);
    if (raw == null || raw.isEmpty) return null;
    return GoalModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveGoal(GoalModel goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_goalKey, jsonEncode(goal.toJson()));
  }

  

  Future<String> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'My Account';
  }

  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  

  
  Future<void> clearFinancialData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_txKey);
    await prefs.remove(_goalKey);
  }

  
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  

  
  Future<String> exportTransactionsCsv() async {
    final list = await loadTransactions();
    final buffer = StringBuffer();
    buffer.writeln('id,date,type,category,amount,note');
    for (final t in list) {
      final note = t.note.replaceAll('"', '""'); 
      buffer.writeln(
        '"${t.id}","${t.date.toIso8601String()}",'
        '"${t.type.name}","${t.category.name}",'
        '${t.amount.toStringAsFixed(2)},"$note"',
      );
    }
    return buffer.toString();
  }
}