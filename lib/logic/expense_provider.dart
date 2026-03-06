import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:math';
import '../data/models.dart';

class ExpenseProvider extends ChangeNotifier {
  late Box<Expense> _box;
  List<Expense> _expenses = [];

  String _filterYear = 'All';
  String _filterMonth = 'All';

  String get filterYear => _filterYear;
  String get filterMonth => _filterMonth;

  ExpenseProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox<Expense>('expenses');
    _expenses = _box.values.toList();
    _expenses.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  List<Expense> get allExpenses => _expenses;

  List<Expense> get filteredExpenses {
    return _expenses.where((e) {
      bool matchYear = _filterYear == 'All' || e.date.year.toString() == _filterYear;
      bool matchMonth = _filterMonth == 'All' || DateFormat('MMMM').format(e.date) == _filterMonth;
      return matchYear && matchMonth;
    }).toList();
  }

  void setFilter(String year, String month) {
    _filterYear = year;
    _filterMonth = month;
    notifyListeners();
  }

  // --- KPI LOGIC ---
  double get totalIncome => filteredExpenses.where((e) => e.title == 'Savings').fold(0, (sum, e) => sum + e.amount);
  double get totalExpense => filteredExpenses.where((e) => e.title == 'Expense').fold(0, (sum, e) => sum + e.amount);
  double get totalInvestment => filteredExpenses.where((e) => e.title == 'Investment').fold(0, (sum, e) => sum + e.amount);
  double get totalDebtTaken => filteredExpenses.where((e) => e.title == 'Debt Taken').fold(0, (sum, e) => sum + e.amount);
  double get totalDebtRepaid => filteredExpenses.where((e) => e.title == 'Debt Repayment').fold(0, (sum, e) => sum + e.amount);

  double get netCashFlow => (totalIncome + totalDebtTaken) - (totalExpense + totalInvestment + totalDebtRepaid);

  double get totalDebtTakenAmount {
    return _expenses.where((e) => e.title == 'Debt Taken').fold(0.0, (sum, e) => sum + e.amount);
  }

  double get accumulatedInterest {
    double interest = 0.0;
    final now = DateTime.now();
    for (var e in _expenses.where((e) => e.title == 'Debt Taken')) {
      if (e.interestRate > 0) {
        final days = now.difference(e.date).inDays;
        final years = days / 365.25;
        if (years > 0) {
          double totalForThisDebt = 0.0;
          if (e.isCompound) {
            totalForThisDebt = e.amount * pow((1 + e.interestRate / 100), years);
          } else {
            totalForThisDebt = e.amount * (1 + (e.interestRate / 100) * years);
          }
          interest += (totalForThisDebt - e.amount);
        }
      }
    }
    return interest;
  }

  double get outstandingDebt {
    double tTaken = totalDebtTakenAmount + accumulatedInterest;
    double tRepaid = _expenses.where((e) => e.title == 'Debt Repayment').fold(0.0, (sum, e) => sum + e.amount);
    return tTaken - tRepaid;
  }

  double get savingsRate {
    if (totalIncome == 0) return 0;
    return ((totalIncome - totalExpense - totalDebtRepaid) / totalIncome) * 100;
  }

  double get investRate {
    if (totalIncome == 0) return 0;
    return (totalInvestment / totalIncome) * 100;
  }

  String get advisorMessage {
    double income = totalIncome;
    double rate = savingsRate;
    double debtRepaidPeriod = totalDebtRepaid;
    double investment = totalInvestment;

    if (income == 0) return "Awaiting income data for this period.";
    else if (debtRepaidPeriod > (income * 0.3)) return "⚠️ Debt repayment is over 30% of income.";
    else if (investment < (income * 0.1) && rate > 30) return "💡 You're saving cash, consider investing more.";
    else if (investment > (income * 0.2)) return "🌟 Excellent investing habits detected!";
    return "Stable finances. Keep it up!";
  }

  void addTx(String type, String category, double amount, DateTime date, {double interestRate = 0.0, bool isCompound = false}) {
    final expense = Expense(
      title: type, // Store type in title field mapping
      amount: amount,
      category: category,
      date: date,
      isDebt: (type == 'Debt Taken' || type == 'Debt Repayment'),
      interestRate: interestRate,
      isCompound: isCompound,
    );
    _box.add(expense);
    loadData();
  }

  void deleteExpense(Expense expense) {
    expense.delete();
    loadData();
  }

  void loadData() {
    _expenses = _box.values.toList();
    _expenses.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  // --- IMPORT / EXPORT ---
  String exportToCsv() {
    StringBuffer csv = StringBuffer();
    csv.writeln("id,year,month,type,category,amount,interestRate,isCompound");
    for (var e in _expenses) {
      csv.writeln("${e.key},${e.date.year},${DateFormat('MMMM').format(e.date)},${e.title},${e.category},${e.amount},${e.interestRate},${e.isCompound}");
    }
    Clipboard.setData(ClipboardData(text: csv.toString()));
    return "CSV Copied to Clipboard!";
  }

  void importJson(String jsonStr) {
    try {
      final List<dynamic> parsed = jsonDecode(jsonStr);
      _box.clear();
      for (var row in parsed) {
        String type = row['type'] ?? 'Expense';
        _box.add(Expense(
          title: type,
          amount: (row['amount'] as num).toDouble(),
          category: row['category'] ?? 'Other',
          date: _parseDate(row['year']?.toString() ?? '2024', row['month'] ?? 'January'),
          isDebt: (type == 'Debt Taken' || type == 'Debt Repayment'),
          interestRate: (row['interestRate'] as num?)?.toDouble() ?? 0.0,
          isCompound: row['isCompound'] as bool? ?? false,
        ));
      }
      loadData();
    } catch (e) {
      debugPrint("Import error: $e");
    }
  }

  DateTime _parseDate(String yearStr, String monthStr) {
    int year = int.tryParse(yearStr) ?? DateTime.now().year;
    const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    int month = months.indexOf(monthStr) + 1;
    if (month == 0) month = 1;
    return DateTime(year, month, 1);
  }
}