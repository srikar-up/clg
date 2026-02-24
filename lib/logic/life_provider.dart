import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models.dart';

class LifeProvider extends ChangeNotifier {
  late Box<LifeGoal> _goalsBox;
  late Box<Quest> _questsBox;
  late Box<WorkCounter> _countersBox;
  late Box<Note> _notesBox;
  late Box<LifeEvent> _eventsBox;
  
  List<LifeGoal> _goals = [];
  List<Quest> _quests = [];
  List<WorkCounter> _counters = [];
  List<Note> _notes = [];
  List<LifeEvent> _events = [];
  
  int _total = 0;

  LifeProvider() {
    _init();
  }

  Future<void> _init() async {
    // Open all Hive boxes
    _goalsBox = await Hive.openBox<LifeGoal>('life_goals');
    _questsBox = await Hive.openBox<Quest>('life_quests');
    _countersBox = await Hive.openBox<WorkCounter>('life_counters');
    _notesBox = await Hive.openBox<Note>('life_notes');
    _eventsBox = await Hive.openBox<LifeEvent>('life_events');
    
    _goals = _goalsBox.values.toList();
    _quests = _questsBox.values.toList();
    _counters = _countersBox.values.toList();
    _notes = _notesBox.values.toList();
    _events = _eventsBox.values.toList();
    
    _calculateScore();
    notifyListeners();
  }

  // --- GETTERS ---
  List<LifeGoal> get goals => _goals;
  List<Quest> get quests => _quests;
  List<WorkCounter> get counters => _counters;
  List<Note> get notes => _notes.where((n) => !n.isExpired).toList();
  List<LifeEvent> get events => _events;
  
  int get totalPoints => _total;
  int get currentLevel => (_total / 100).floor() + 1;
  double get levelProgress => (_total % 100) / 100;
  
  int get totalQuestsCompleted => _quests.where((q) => q.isCompleted).length;
  double get successRate => _quests.isEmpty ? 0 : (totalQuestsCompleted / _quests.length) * 100;

  void _calculateScore() {
    _total = 0;
    // From completed goals
    for (var goal in _goals) {
      if (goal.isCompleted) {
        _total += goal.rewardPoints;
      }
    }
    // From completed quests
    for (var quest in _quests) {
      if (quest.isCompleted) {
        _total += quest.xpReward;
      }
    }
    // From work counter increments (10 XP per increment)
    for (var counter in _counters) {
      _total += counter.count * 10;
    }
  }

  // --- QUEST ACTIONS ---
  void addQuest(String title, String rank, String type, int targetProgress, String? reward) {
    final newQuest = Quest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      rank: rank,
      type: type,
      targetProgress: targetProgress,
      reward: reward,
    );
    _questsBox.add(newQuest);
    _refresh();
  }

  void updateQuestProgress(Quest quest, int newProgress) {
    quest.currentProgress = newProgress;
    if (quest.currentProgress >= quest.targetProgress) {
      quest.isCompleted = true;
      quest.completedAt = DateTime.now();
    }
    quest.save();
    _refresh();
  }

  void deleteQuest(Quest quest) {
    quest.delete();
    _refresh();
  }

  // --- WORK COUNTER ACTIONS ---
  void addWorkCounter(String title) {
    final newCounter = WorkCounter(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
    );
    _countersBox.add(newCounter);
    _refresh();
  }

  void incrementCounter(WorkCounter counter) {
    counter.count++;
    counter.save();
    _refresh();
  }

  void decrementCounter(WorkCounter counter) {
    if (counter.count > 0) {
      counter.count--;
      counter.save();
      _refresh();
    }
  }

  void deleteCounter(WorkCounter counter) {
    counter.delete();
    _refresh();
  }

  // --- NOTE ACTIONS ---
  void addNote(String content, String noteType, DateTime? expiresAt) {
    final newNote = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      noteType: noteType,
      expiresAt: expiresAt,
    );
    _notesBox.add(newNote);
    _refresh();
  }

  void deleteNote(Note note) {
    note.delete();
    _refresh();
  }

  // --- EVENT ACTIONS ---
  void addEvent(String name, String eventType, DateTime date, bool isRecurring) {
    final newEvent = LifeEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      eventType: eventType,
      date: date,
      isRecurring: isRecurring,
    );
    _eventsBox.add(newEvent);
    _refresh();
  }

  void deleteEvent(LifeEvent event) {
    event.delete();
    _refresh();
  }

  List<LifeEvent> get upcomingEvents => _events
      .where((e) => e.isWithin10Days)
      .toList()
      ..sort((a, b) => a.daysUntil.compareTo(b.daysUntil));

  // --- LEGACY GOAL ACTIONS ---
  void addGoal(String title, int points) {
    final newGoal = LifeGoal(
      title: title, 
      rewardPoints: points, 
      isCompleted: false
    );
    _goalsBox.add(newGoal);
    _refresh();
  }

  void toggleGoal(LifeGoal goal, bool? value) {
    goal.isCompleted = value ?? false;
    goal.save();
    _calculateScore();
    notifyListeners();
  }

  void deleteGoal(LifeGoal goal) {
    goal.delete();
    _refresh();
  }

  void _refresh() {
    _goals = _goalsBox.values.toList();
    _quests = _questsBox.values.toList();
    _counters = _countersBox.values.toList();
    _notes = _notesBox.values.toList();
    _events = _eventsBox.values.toList();
    _calculateScore();
    notifyListeners();
  }
}