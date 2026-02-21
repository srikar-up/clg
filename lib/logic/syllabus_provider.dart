import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/syllabus_model.dart';
import 'dart:convert'; // For AI import

class SyllabusProvider extends ChangeNotifier {
  late Box<SyllabusItem> _box;
  List<SyllabusItem> _items = [];

  SyllabusProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox<SyllabusItem>('syllabus');
    _items = _box.values.toList();
    notifyListeners();
  }

  List<SyllabusItem> get items => _items;

  // --- ACTIONS ---

  void addItem({required String name, required String code, DateTime? date}) {
    final item = SyllabusItem(subjectName: name, code: code, examDate: date);
    _box.add(item);
    _refresh();
  }

  void updateProgress(SyllabusItem item, double newVal) {
    item.progress = newVal;
    item.save();
    notifyListeners();
  }

  void updateMarks(SyllabusItem item, double marks, double total) {
    item.marksObtained = marks;
    item.totalMarks = total;
    item.save();
    notifyListeners();
  }

  void deleteItem(SyllabusItem item) {
    item.delete();
    _refresh();
  }

  void _refresh() {
    _items = _box.values.toList();
    // Sort: Exam dates soonest first
    _items.sort((a, b) {
      if (a.examDate == null) return 1;
      if (b.examDate == null) return -1;
      return a.examDate!.compareTo(b.examDate!);
    });
    notifyListeners();
  }

  // --- AI IMPORT ---
  String importJson(String jsonStr) {
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      int count = 0;
      for (var obj in list) {
        String name = obj['subject'] ?? 'Unknown';
        String code = obj['code'] ?? '';
        DateTime? date;
        if (obj['examDate'] != null) {
          date = DateTime.tryParse(obj['examDate']);
        }

        _box.add(SyllabusItem(subjectName: name, code: code, examDate: date));
        count++;
      }
      _refresh();
      return "Imported $count subjects!";
    } catch (e) {
      return "Error parsing JSON.";
    }
  }
}