import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models.dart';

class LifeProvider extends ChangeNotifier {
  late Box<LifeGoal> _box;
  List<LifeGoal> _goals = [];
  int _total = 0;

  LifeProvider() {
    _init();
  }

  Future<void> _init() async {
    // Open the Hive box for goals
    _box = await Hive.openBox<LifeGoal>('life_goals');
    _goals = _box.values.toList();
    _calculateScore();
    notifyListeners();
  }

  // --- GETTERS ---
  List<LifeGoal> get goals => _goals;
  int get totalPoints => _total;
  
  // Calculate Level (Example: Every 100 points is a level)
  int get currentLevel => (_total / 100).floor() + 1;
  
  // Progress to next level (0.0 to 1.0)
  double get levelProgress => (_total % 100) / 100;

  void _calculateScore() {
    _total = 0;
    for (var goal in _goals) {
      if (goal.isCompleted) {
        _total += goal.rewardPoints;
      }
    }
  }

  // --- ACTIONS ---
  
  void addGoal(String title, int points) {
    final newGoal = LifeGoal(
      title: title, 
      rewardPoints: points, 
      isCompleted: false
    );
    _box.add(newGoal);
    _refresh();
  }

  void toggleGoal(LifeGoal goal, bool? value) {
    goal.isCompleted = value ?? false;
    goal.save(); // Save to database
    _calculateScore();
    notifyListeners();
  }

  void deleteGoal(LifeGoal goal) {
    goal.delete();
    _refresh();
  }

  void _refresh() {
    _goals = _box.values.toList();
    _calculateScore();
    notifyListeners();
  }
}