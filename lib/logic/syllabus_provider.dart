import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import '../data/syllabus_model.dart';
import 'notification_service.dart';

class SyllabusProvider extends ChangeNotifier {
  late Box<SyllabusSubject> _box;
  late Box<String> _semBox;
  List<SyllabusSubject> _items = [];
  int _activeSemester = 1;
  bool _isInit = false;

  SyllabusProvider() {
    _init();
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    if (_isInit) {
      NotificationService().syncSyllabusNotifications(_items);
    }
  }

  int get activeSemester => _activeSemester;

  Future<void> _init() async {
    _box = await Hive.openBox<SyllabusSubject>('syllabus_subjects_v1');
    _semBox = await Hive.openBox<String>('syllabus_semesters_v1');
    
    final savedActive = _semBox.get('active_semester_id');
    if (savedActive != null) {
      _activeSemester = int.tryParse(savedActive) ?? 1;
    }
    
    _isInit = true;
    loadData();
  }

  List<SyllabusSubject> get subjects => _items.where((s) => s.semester == _activeSemester).toList();

  void setActiveSemester(int sem) {
    _activeSemester = sem;
    _semBox.put('active_semester_id', sem.toString());
    notifyListeners();
  }

  List<Map<String, dynamic>> get semesters {
    Set<int> activeIds = {1}; // Default at least 1 semester
    
    // Add all semesters that have subjects
    for(var s in _items) activeIds.add(s.semester);
    
    if (_isInit) {
      // Add all explicitly created semesters
      for(var key in _semBox.keys) {
        if (key is int) activeIds.add(key);
      }
    }
    
    List<int> sortedIds = activeIds.toList()..sort();
    return sortedIds.map<Map<String, dynamic>>((id) {
       return <String, dynamic>{
         'id': id,
         'name': _isInit ? (_semBox.get(id) ?? 'SEMESTER $id') : 'SEMESTER $id',
       };
    }).toList();
  }

  String get activeSemesterName {
    if (!_isInit) return 'SEMESTER $_activeSemester';
    return _semBox.get(_activeSemester) ?? 'SEMESTER $_activeSemester';
  }

  void addSemester(String name) {
    int maxId = 0;
    for(var s in semesters) {
      final sId = s['id'] as int;
      if (sId > maxId) maxId = sId;
    }
    int nextId = maxId + 1;
    _semBox.put(nextId, name);
    _activeSemester = nextId;
    _semBox.put('active_semester_id', nextId.toString());
    notifyListeners();
  }

  void renameSemester(int id, String newName) {
    _semBox.put(id, newName);
    notifyListeners();
  }

  void loadData() {
    _items = _box.values.toList();
    notifyListeners();
  }

  void addSubject({required String name, required String code, required int credits, required int semester}) {
    final sub = SyllabusSubject(code: code, name: name, credits: credits, semester: semester);
    _box.add(sub);
    loadData();
  }

  void deleteSubject(SyllabusSubject sub) {
    sub.delete();
    loadData();
  }

  void toggleTopic(SyllabusSubject subject, SyllabusTopic topic) {
    HapticFeedback.lightImpact();
    topic.isCompleted = !topic.isCompleted;
    subject.save();
    notifyListeners();
  }

  void addExam(SyllabusSubject subject, String name, DateTime date, double maxMarks, Map<String, List<String>> scope) {
    subject.exams.add(
      SyllabusExam(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        date: date,
        maxMarks: maxMarks,
        scope: scope,
      )
    );
    subject.save();
    notifyListeners();
  }

  void deleteExam(SyllabusSubject subject, SyllabusExam exam) {
    subject.exams.remove(exam);
    subject.save();
    notifyListeners();
  }

  void updateExamMarks(SyllabusSubject subject, SyllabusExam exam, double marksObtained) {
    exam.marksObtained = marksObtained;
    subject.save();
    notifyListeners();
  }

  void addWeightageGroup(SyllabusSubject subject, String name, double percentage) {
    subject.weightageGroups.add(
      WeightageGroup(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        percentage: percentage,
      )
    );
    subject.save();
    notifyListeners();
  }

  void deleteWeightageGroup(SyllabusSubject subject, WeightageGroup group) {
    subject.weightageGroups.remove(group);
    for (var ex in subject.exams) {
      if (ex.weightageGroupId == group.id) ex.weightageGroupId = null;
    }
    subject.save();
    notifyListeners();
  }

  void assignExamToGroup(SyllabusSubject subject, SyllabusExam exam, String? groupId) {
    exam.weightageGroupId = groupId;
    subject.save();
    notifyListeners();
  }

  double predictSGPA() {
    double totalCredits = 0;
    double totalPoints = 0;

    for (var subject in subjects) {
      if (subject.credits <= 0) continue;

      double subjectPercentage = 0;
      double configuredWeightage = 0;

      for (var group in subject.weightageGroups) {
        final groupExams = subject.exams.where((e) => e.weightageGroupId == group.id).toList();
        if (groupExams.isEmpty) continue;

        double scored = 0;
        double max = 0;
        for (var e in groupExams) {
          if (e.marksObtained != null) {
            scored += e.marksObtained!;
            max += e.maxMarks;
          }
        }
        if (max > 0) {
          subjectPercentage += (scored / max) * group.percentage;
        }
        configuredWeightage += group.percentage;
      }

      double finalPercentage = 0;
      if (configuredWeightage > 0) {
        finalPercentage = (subjectPercentage / configuredWeightage) * 100;
      } else {
        finalPercentage = subject.masterProgress * 100;
      }

      double gp = 0;
      if (finalPercentage >= 90) {
        gp = 10;
      } else if (finalPercentage >= 80) {
        gp = 9;
      } else if (finalPercentage >= 70) {
        gp = 8;
      } else if (finalPercentage >= 60) {
        gp = 7;
      } else if (finalPercentage >= 50) {
        gp = 6;
      } else if (finalPercentage >= 40) {
        gp = 5;
      } else {
        gp = 0;
      }

      totalPoints += (gp * subject.credits);
      totalCredits += subject.credits;
    }

    if (totalCredits == 0) return 0.0;
    return totalPoints / totalCredits;
  }

  String importJson(String jsonStr) {
    try {
      final obj = jsonDecode(jsonStr);
      List<dynamic> list = obj is List ? obj : [obj];

      int count = 0;
      for (var s in list) {
        List<SyllabusUnit> parsedUnits = [];
        if (s['units'] != null) {
          for (var u in s['units']) {
            List<SyllabusTopic> parsedTopics = [];
            if (u['topics'] != null) {
              for (var t in u['topics']) {
                parsedTopics.add(SyllabusTopic(name: t.toString()));
              }
            }
            parsedUnits.add(SyllabusUnit(
              id: (u['id'] as num?)?.toInt() ?? parsedUnits.length + 1,
              title: u['title'] ?? 'Unit',
              topics: parsedTopics,
            ));
          }
        }
        final sub = SyllabusSubject(
          code: s['code']?.toString() ?? 'SUBJ',
          name: s['name']?.toString() ?? 'Subject',
          credits: (s['credits'] as num?)?.toInt() ?? 4,
          semester: _activeSemester,
          units: parsedUnits,
        );
        _box.add(sub);
        count++;
      }
      loadData();
      return "Imported $count subjects!";
    } catch (e) {
      return "Error parsing JSON: $e";
    }
  }
}