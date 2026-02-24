import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../data/models.dart';

class ExpenseProvider extends ChangeNotifier {
  late Box<Expense> _box;
  List<Expense> _expenses = [];
  bool _isInitialized = false;

  ExpenseProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox<Expense>('expenses');
    _expenses = _box.values.toList();
    // Sort by date (newest first)
    _expenses.sort((a, b) => b.date.compareTo(a.date));
    _isInitialized = true;
    notifyListeners();
  }

  List<Expense> get expenses => _expenses;
  
  // Calculate Totals
  double get totalSpent => _expenses
      .where((e) => !e.isDebt)
      .fold(0, (sum, item) => sum + item.amount);

  double get totalDebt => _expenses
      .where((e) => e.isDebt)
      .fold(0, (sum, item) => sum + item.amount);

  // --- ACTIONS ---

  void addExpense(String title, double amount, String category, bool isDebt) {
    final expense = Expense(
      title: title,
      amount: amount,
      category: category,
      date: DateTime.now(),
      isDebt: isDebt,
    );
    _box.add(expense);
    _refresh();
  }

  void deleteExpense(Expense expense) {
    expense.delete();
    _refresh();
  }

  void _refresh() {
    _expenses = _box.values.toList();
    _expenses.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  // --- EXCEL / CSV EXPORT ---
  // Generates a CSV string and copies it to clipboard (Works offline without extra plugins)
  String exportToCsv() {
    StringBuffer csv = StringBuffer();
    csv.writeln("Date,Title,Category,Type,Amount"); // Headers

    for (var e in _expenses) {
      String date = DateFormat('yyyy-MM-dd').format(e.date);
      String type = e.isDebt ? "DEBT" : "EXPENSE";
      csv.writeln("$date,${e.title},${e.category},$type,${e.amount}");
    }

    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: csv.toString()));
    return "Data copied to Clipboard! Paste into Excel.";
  }
}