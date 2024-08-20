import 'dart:async';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:expenza/models/expense.dart'; // Assuming this is your Expense model
import 'package:path_provider/path_provider.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;
  List<Expense> _allExpense = [];

  // Setup

  // Initialize db
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

  // Getters
  List<Expense> get allExpense => _allExpense;

  // Operations

  // Create
  Future<void> createNewExpense(Expense newExpense) async {
    await isar.writeTxn(() => isar.expenses.put(newExpense));
    await readExpenses();
  }

  // Read
  Future<void> readExpenses() async {
    List<Expense> fetchedExpenses = await isar.expenses.where().findAll();
    _allExpense.clear();
    _allExpense.addAll(fetchedExpenses);
    notifyListeners();
  }

  // Update
  Future<void> updateExpense(int id, Expense updatedExpense) async {
    updatedExpense.id = id;
    await isar.writeTxn(() => isar.expenses.put(updatedExpense));
    await readExpenses();
  }

  // Delete
  Future<void> deleteExpense(int id) async { // Added the id parameter
    await isar.writeTxn(() => isar.expenses.delete(id));
    await readExpenses();
  }

  // Helper



  // Calculate total expense
  Future<Map<String, double>> calculateMonthlyTotals() async {
    await readExpenses();

    Map<String, double> monthlyTotals = {};

    for (var expense in _allExpense) {

      String yearMonth = '${expense.date.year.toString()} - ${expense.date.month.toString()}';

      if (!monthlyTotals.containsKey(yearMonth)) {
        monthlyTotals[yearMonth] = 0;
      }
      monthlyTotals[yearMonth] = monthlyTotals[yearMonth]! + expense.amount;
    }

    return monthlyTotals;
  }

  // Calculate Current month total
  Future<double> calculateCurrentMonthTotal() async{
    await readExpenses();

    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    List<Expense> currentMonthExpense = _allExpense.where((expense) {
      return expense.date.month == currentMonth && expense.date.year == currentYear;
    }).toList();

    double total = currentMonthExpense.fold(0, (sum,expense) => sum + expense.amount);

    return total;
  }

  // Get start month
  int getStartMonth() {
    if (_allExpense.isEmpty) {
      return DateTime.now().month;
    }

    _allExpense.sort((a, b) => a.date.compareTo(b.date));

    return _allExpense.first.date.month;
  }

  // Get start year
  int getStartYear() {
    if (_allExpense.isEmpty) {
      return DateTime.now().year;
    }

    _allExpense.sort((a, b) => a.date.compareTo(b.date));

    return _allExpense.first.date.year;
  }
}