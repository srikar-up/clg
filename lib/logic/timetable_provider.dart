import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models.dart';

class TimetableProvider extends ChangeNotifier {
  late Box<ScheduleItem> _box;
  List<ScheduleItem> _items = [];
  Timer? _timer;

  bool _isBoxOpen = false;

  TimetableProvider() {
    _init();
  }

  Future<void> _init() async {
    // Open Hive Box
    _box = await Hive.openBox<ScheduleItem>('timetable');
    _items = _box.values.toList();
    _isBoxOpen = true;
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    // Update every minute to refresh "Now/Next" and Lunch Alerts
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => notifyListeners());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<ScheduleItem> get items => _items;

  // --- CRUD ---
  void addItem(ScheduleItem item) {
    _box.add(item);
    _items = _box.values.toList();
    notifyListeners();
  }

  void deleteItem(ScheduleItem item) {
    item.delete(); // Delete from Hive
    _items = _box.values.toList();
    notifyListeners();
  }

  void toggleAttendance(ScheduleItem item, bool status) {
    item.attended = status;
    item.save(); // Update in Hive
    notifyListeners();
  }

  // --- LOGIC ---
  List<ScheduleItem> getItemsForDay(int weekday) {
    final list = _items.where((i) => i.weekday == weekday).toList();
    list.sort((a, b) {
      final aMin = a.startHour * 60 + a.startMinute;
      final bMin = b.startHour * 60 + b.startMinute;
      return aMin.compareTo(bMin);
    });
    return list;
  }

  Map<String, ScheduleItem?> getNowAndNext() {
    if (!_isBoxOpen) return {'current': null, 'next': null};
    
    final now = TimeOfDay.now();
    final today = DateTime.now().weekday;
    final dayItems = getItemsForDay(today);
    
    int nowMin = now.hour * 60 + now.minute;
    ScheduleItem? current;
    ScheduleItem? next;

    for (var item in dayItems) {
      int startMin = item.startHour * 60 + item.startMinute;
      int endMin = item.endHour * 60 + item.endMinute;

      if (nowMin >= startMin && nowMin < endMin) {
        current = item;
      } else if (nowMin < startMin) {
        next ??= item;
      }
    }
    return {'current': current, 'next': next};
  }

  // GAP DETECTION (12 PM - 3 PM)
  bool isLunchGap() {
    final now = TimeOfDay.now();
    int nowMin = now.hour * 60 + now.minute;
    int startGap = 12 * 60;
    int endGap = 15 * 60;

    // 1. Are we in the time range?
    if (nowMin >= startGap && nowMin < endGap) {
      // 2. Do we have a class?
      final status = getNowAndNext();
      if (status['current'] == null) {
        return true; // We are in the gap AND free
      }
    }
    return false;
  }

  // JSON IMPORT
  String importJson(String jsonStr) {
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      int count = 0;
      for (var obj in list) {
        // Parsing logic
        String title = obj['title'] ?? 'Unknown';
        String loc = obj['location'] ?? 'Online';
        int day = _parseDay(obj['day']);
        
        // Time parsing "09:00"
        var startParts = (obj['startTime'] as String).split(':');
        var endParts = (obj['endTime'] as String).split(':');

        String type = obj['type'] ?? 'class';

        final item = ScheduleItem(
          id: DateTime.now().millisecondsSinceEpoch.toString() + count.toString(),
          title: title,
          location: loc,
          weekday: day,
          startHour: int.parse(startParts[0]),
          startMinute: int.parse(startParts[1]),
          endHour: int.parse(endParts[0]),
          endMinute: int.parse(endParts[1]),
          type: type,
        );
        _box.add(item);
        count++;
      }
      _items = _box.values.toList();
      notifyListeners();
      return "Imported $count items successfully!";
    } catch (e) {
      return "Error parsing JSON. Check format.";
    }
  }

  int _parseDay(dynamic d) {
    if (d is int) return d;
    String s = d.toString().toLowerCase();
    if (s.startsWith('m')) return 1;
    if (s.startsWith('tu')) return 2;
    if (s.startsWith('w')) return 3;
    if (s.startsWith('th')) return 4;
    if (s.startsWith('f')) return 5;
    if (s.startsWith('sa')) return 6;
    return 7;
  }
}