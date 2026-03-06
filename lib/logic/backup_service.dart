import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive.dart';
import '../data/models.dart';
import '../data/syllabus_model.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'timetable_provider.dart';
import 'life_provider.dart';
import 'expense_provider.dart';
import 'syllabus_provider.dart';

class BackupService {
  
  static Future<void> exportBackup(BuildContext context) async {
    final config = Provider.of<ThemeProvider>(context, listen: false).config;
    try {
      final scheduleBox = await Hive.openBox<ScheduleItem>('timetable');
      final goalBox = await Hive.openBox<LifeGoal>('life_goals');
      final expenseBox = await Hive.openBox<Expense>('expenses');
      final questBox = await Hive.openBox<Quest>('life_quests_v2');
      final counterBox = await Hive.openBox<WorkCounter>('life_counters_v2');
      final noteBox = await Hive.openBox<Note>('life_notes_v2');
      final eventBox = await Hive.openBox<LifeEvent>('life_events_v2');
      final subBox = await Hive.openBox<SyllabusSubject>('syllabus_subjects_v1');
      final semBox = await Hive.openBox<String>('syllabus_semesters_v1');

      Map<String, dynamic> rawData = {
        'version': 1,
        'schedule': scheduleBox.values.map((e) => {
          'id': e.id, 'title': e.title, 'location': e.location, 'weekday': e.weekday,
          'startHour': e.startHour, 'startMinute': e.startMinute, 'endHour': e.endHour, 'endMinute': e.endMinute,
          'type': e.type, 'attended': e.attended
        }).toList(),
        'life_goals': goalBox.values.map((e) => {
          'title': e.title, 'isCompleted': e.isCompleted, 'rewardPoints': e.rewardPoints,
          'endDate': e.endDate?.millisecondsSinceEpoch
        }).toList(),
        'expenses': expenseBox.values.map((e) => {
          'title': e.title, 'amount': e.amount, 'category': e.category, 'date': e.date.millisecondsSinceEpoch,
          'isDebt': e.isDebt, 'interestRate': e.interestRate, 'isCompound': e.isCompound
        }).toList(),
        'quests': questBox.values.map((e) => {
          'id': e.id, 'title': e.title, 'rank': e.rank, 'type': e.type, 'currentProgress': e.currentProgress,
          'targetProgress': e.targetProgress, 'reward': e.reward, 'isCompleted': e.isCompleted,
          'createdAt': e.createdAt.millisecondsSinceEpoch, 'completedAt': e.completedAt?.millisecondsSinceEpoch,
          'deadline': e.deadline?.millisecondsSinceEpoch, 'xpPenalty': e.xpPenalty
        }).toList(),
        'work_counters': counterBox.values.map((e) => {
          'id': e.id, 'title': e.title, 'count': e.count, 'createdAt': e.createdAt.millisecondsSinceEpoch,
          'xpReward': e.xpReward, 'iconData': e.iconData
        }).toList(),
        'notes': noteBox.values.map((e) => {
          'id': e.id, 'content': e.content, 'noteType': e.noteType, 'createdAt': e.createdAt.millisecondsSinceEpoch,
          'expiresAt': e.expiresAt?.millisecondsSinceEpoch
        }).toList(),
        'life_events': eventBox.values.map((e) => {
          'id': e.id, 'name': e.name, 'eventType': e.eventType, 'date': e.date.millisecondsSinceEpoch,
          'isRecurring': e.isRecurring
        }).toList(),
        'syllabus_subjects': subBox.values.map((e) => {
          'code': e.code, 'name': e.name, 'credits': e.credits, 'semester': e.semester,
          'units': e.units.map((u) => {
            'id': u.id, 'title': u.title, 'topics': u.topics.map((t) => {'name': t.name, 'isCompleted': t.isCompleted}).toList()
          }).toList(),
          'exams': e.exams.map((ex) => {
            'id': ex.id, 'name': ex.name, 'date': ex.date.millisecondsSinceEpoch, 'maxMarks': ex.maxMarks,
            'marksObtained': ex.marksObtained, 
            'scope': ex.scope.map((key, val) => MapEntry(key.toString(), (val as List).map((k) => k.toString()).toList())),
            'weightageGroupId': ex.weightageGroupId
          }).toList(),
          'weightageGroups': e.weightageGroups.map((wg) => {
            'id': wg.id, 'name': wg.name, 'percentage': wg.percentage
          }).toList()
        }).toList(),
        'semesters': Map.fromEntries(semBox.keys.map((k) => MapEntry(k.toString(), semBox.get(k)))),
      };

      String jsonString = jsonEncode(rawData);
      List<int> compressedBytes = GZipEncoder().encode(utf8.encode(jsonString))!;

      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory != null) {
        String fileName = 'life_os_backup_${DateTime.now().millisecondsSinceEpoch}.okso';
        File file = File('$selectedDirectory/$fileName');
        await file.writeAsBytes(compressedBytes);
        
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup Saved to $selectedDirectory/$fileName', style: TextStyle(color: config.cardColor)), backgroundColor: config.primaryAccent));
      }
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export Failed: \$e', style: TextStyle(color: config.cardColor)), backgroundColor: Colors.red));
    }
  }

  static Future<void> importBackup(BuildContext context) async {
    final config = Provider.of<ThemeProvider>(context, listen: false).config;
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['okso'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        List<int> compressedBytes = await file.readAsBytes();
        
        List<int> decompressedBytes = GZipDecoder().decodeBytes(compressedBytes);
        String jsonString = utf8.decode(decompressedBytes);
        Map<String, dynamic> rawData = jsonDecode(jsonString);

        if (rawData['version'] == 1) {
             // We can now clear and seed boxes. 
             final scheduleBox = await Hive.openBox<ScheduleItem>('timetable');
             await scheduleBox.clear();
             for (var map in rawData['schedule'] ?? []) {
                scheduleBox.add(ScheduleItem(
                  id: map['id'], title: map['title'], location: map['location'], weekday: map['weekday'],
                  startHour: map['startHour'], startMinute: map['startMinute'], endHour: map['endHour'], endMinute: map['endMinute'],
                  type: map['type'], attended: map['attended']
                ));
             }

             final goalBox = await Hive.openBox<LifeGoal>('life_goals');
             await goalBox.clear();
             for (var map in rawData['life_goals'] ?? []) {
                goalBox.add(LifeGoal(
                  title: map['title'], isCompleted: map['isCompleted'] ?? false, rewardPoints: map['rewardPoints'],
                  endDate: map['endDate'] != null ? DateTime.fromMillisecondsSinceEpoch(map['endDate']) : null
                ));
             }

             final expenseBox = await Hive.openBox<Expense>('expenses');
             await expenseBox.clear();
             for (var map in rawData['expenses'] ?? []) {
                expenseBox.add(Expense(
                  title: map['title'], amount: map['amount'], category: map['category'], 
                  date: DateTime.fromMillisecondsSinceEpoch(map['date']),
                  isDebt: map['isDebt'] ?? false, interestRate: map['interestRate'] ?? 0.0, isCompound: map['isCompound'] ?? false
                ));
             }

             final questBox = await Hive.openBox<Quest>('life_quests_v2');
             await questBox.clear();
             for (var map in rawData['quests'] ?? []) {
                questBox.add(Quest(
                  id: map['id'], title: map['title'], rank: map['rank'], type: map['type'],
                  currentProgress: map['currentProgress'] ?? 0, targetProgress: map['targetProgress'] ?? 1,
                  reward: map['reward'], isCompleted: map['isCompleted'] ?? false,
                  createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
                  completedAt: map['completedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['completedAt']) : null,
                  deadline: map['deadline'] != null ? DateTime.fromMillisecondsSinceEpoch(map['deadline']) : null,
                  xpPenalty: map['xpPenalty'] ?? 0
                ));
             }

             final counterBox = await Hive.openBox<WorkCounter>('life_counters_v2');
             await counterBox.clear();
             for (var map in rawData['work_counters'] ?? []) {
                counterBox.add(WorkCounter(
                  id: map['id'], title: map['title'], count: map['count'] ?? 0,
                  createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
                  xpReward: map['xpReward'] ?? 10, iconData: map['iconData'] ?? 'bolt'
                ));
             }

             final noteBox = await Hive.openBox<Note>('life_notes_v2');
             await noteBox.clear();
             for (var map in rawData['notes'] ?? []) {
                noteBox.add(Note(
                  id: map['id'], content: map['content'], noteType: map['noteType'],
                  createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
                  expiresAt: map['expiresAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['expiresAt']) : null
                ));
             }

             final eventBox = await Hive.openBox<LifeEvent>('life_events_v2');
             await eventBox.clear();
             for (var map in rawData['life_events'] ?? []) {
                eventBox.add(LifeEvent(
                  id: map['id'], name: map['name'], eventType: map['eventType'],
                  date: DateTime.fromMillisecondsSinceEpoch(map['date']), isRecurring: map['isRecurring'] ?? false
                ));
             }

             final subBox = await Hive.openBox<SyllabusSubject>('syllabus_subjects_v1');
             await subBox.clear();
             for (var map in rawData['syllabus_subjects'] ?? []) {
                subBox.add(SyllabusSubject(
                  code: map['code'], name: map['name'], credits: map['credits'] ?? 4, semester: map['semester'] ?? 1,
                  units: (map['units'] as List? ?? []).map((u) => SyllabusUnit(
                    id: u['id'], title: u['title'], 
                    topics: (u['topics'] as List? ?? []).map((t) => SyllabusTopic(name: t['name'], isCompleted: t['isCompleted'] ?? false)).toList()
                  )).toList(),
                  exams: (map['exams'] as List? ?? []).map((ex) => SyllabusExam(
                    id: ex['id'], name: ex['name'], date: DateTime.fromMillisecondsSinceEpoch(ex['date']),
                  maxMarks: (ex['maxMarks'] as num?)?.toDouble() ?? 100.0, 
                  marksObtained: (ex['marksObtained'] as num?)?.toDouble(),
                  scope: ex['scope'] != null ? Map.fromEntries((ex['scope'] as Map).entries.map((e) => MapEntry(e.key.toString(), (e.value as List).map((i) => i.toString()).toList()))) : {},
                  weightageGroupId: ex['weightageGroupId']
                  )).toList(),
                  weightageGroups: (map['weightageGroups'] as List? ?? []).map((wg) => WeightageGroup(
                    id: wg['id'], name: wg['name'], percentage: wg['percentage'] ?? 0.0
                  )).toList()
                ));
             }

             final semBox = await Hive.openBox<String>('syllabus_semesters_v1');
             await semBox.clear();
             if (rawData['semesters'] != null) {
                final sMap = rawData['semesters'] as Map;
                for (var keyStr in sMap.keys) {
                  int? k = int.tryParse(keyStr);
                  if (k != null) {
                    semBox.put(k, sMap[keyStr]);
                  } else {
                    semBox.put(keyStr, sMap[keyStr]);
                  }
                }
             }
             
             // Refresh all providers
             if (context.mounted) {
               Provider.of<TimetableProvider>(context, listen: false).loadData();
               Provider.of<LifeProvider>(context, listen: false).loadData();
               Provider.of<ExpenseProvider>(context, listen: false).loadData();
               Provider.of<SyllabusProvider>(context, listen: false).loadData();
             }
             
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup Restored Successfully!', style: TextStyle(color: config.cardColor)), backgroundColor: Colors.green));
        } else {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid backup version', style: TextStyle(color: config.cardColor)), backgroundColor: Colors.red));
        }
      }
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import Failed: \$e', style: TextStyle(color: config.cardColor)), backgroundColor: Colors.red));
    }
  }

}
