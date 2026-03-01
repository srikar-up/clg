import 'package:hive/hive.dart';

@HiveType(typeId: 10)
class SyllabusSubject extends HiveObject {
  @HiveField(0)
  String code;
  @HiveField(1)
  String name;
  @HiveField(2)
  int credits;
  @HiveField(3)
  int semester;
  @HiveField(4)
  List<SyllabusUnit> units;
  @HiveField(5)
  List<SyllabusExam> exams;
  @HiveField(6)
  List<WeightageGroup> weightageGroups;

  SyllabusSubject({
    required this.code,
    required this.name,
    this.credits = 4,
    this.semester = 1,
    List<SyllabusUnit>? units,
    List<SyllabusExam>? exams,
    List<WeightageGroup>? weightageGroups,
  })  : units = units ?? [],
        exams = exams ?? [],
        weightageGroups = weightageGroups ?? [];

  int get totalTopics => units.fold(0, (sum, u) => sum + u.topics.length);
  int get completedTopics => units.fold(0, (sum, u) => sum + u.topics.where((t) => t.isCompleted).length);
  double get masterProgress => totalTopics == 0 ? 0 : completedTopics / totalTopics;

  bool get hasRedAlert {
    final now = DateTime.now();
    for (var exam in exams) {
      final diff = exam.date.difference(now).inDays;
      if (diff >= 0 && diff <= 3) {
        int scopedTotal = 0;
        int scopedDone = 0;
        for (var unit in units) {
          final scopedTopics = exam.scope[unit.title];
          if (scopedTopics != null) {
            for (var topicName in scopedTopics) {
              final topicList = unit.topics.where((t) => t.name == topicName);
              if (topicList.isNotEmpty) {
                scopedTotal++;
                if (topicList.first.isCompleted) scopedDone++;
              }
            }
          }
        }
        if (scopedTotal > 0 && (scopedDone / scopedTotal) < 0.85) {
          return true;
        }
      }
    }
    return false;
  }
}

@HiveType(typeId: 11)
class SyllabusUnit {
  @HiveField(0)
  int id;
  @HiveField(1)
  String title;
  @HiveField(2)
  List<SyllabusTopic> topics;

  SyllabusUnit({required this.id, required this.title, List<SyllabusTopic>? topics}) : topics = topics ?? [];
}

@HiveType(typeId: 12)
class SyllabusTopic {
  @HiveField(0)
  String name;
  @HiveField(1)
  bool isCompleted;

  SyllabusTopic({required this.name, this.isCompleted = false});
}

@HiveType(typeId: 13)
class SyllabusExam {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  DateTime date;
  @HiveField(3)
  double maxMarks;
  @HiveField(4)
  double? marksObtained;
  @HiveField(5) // Map format in code: unitTitle -> List of topic names
  Map<dynamic, dynamic> scope; 
  @HiveField(6)
  String? weightageGroupId;

  SyllabusExam({
    required this.id,
    required this.name,
    required this.date,
    required this.maxMarks,
    this.marksObtained,
    Map<dynamic, dynamic>? scope,
    this.weightageGroupId,
  }) : scope = scope ?? {};
}

@HiveType(typeId: 14)
class WeightageGroup {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  double percentage;

  WeightageGroup({required this.id, required this.name, required this.percentage});
}

// --- Manual Adapters ---

class SyllabusSubjectAdapter extends TypeAdapter<SyllabusSubject> {
  @override
  final int typeId = 10;
  @override
  SyllabusSubject read(BinaryReader reader) {
    return SyllabusSubject(
      code: reader.readString(),
      name: reader.readString(),
      credits: reader.readInt(),
      semester: reader.readInt(),
      units: reader.readList().cast<SyllabusUnit>(),
      exams: reader.readList().cast<SyllabusExam>(),
      weightageGroups: reader.readList().cast<WeightageGroup>(),
    );
  }
  @override
  void write(BinaryWriter writer, SyllabusSubject obj) {
    writer.writeString(obj.code);
    writer.writeString(obj.name);
    writer.writeInt(obj.credits);
    writer.writeInt(obj.semester);
    writer.writeList(obj.units);
    writer.writeList(obj.exams);
    writer.writeList(obj.weightageGroups);
  }
}

class SyllabusUnitAdapter extends TypeAdapter<SyllabusUnit> {
  @override
  final int typeId = 11;
  @override
  SyllabusUnit read(BinaryReader reader) {
    return SyllabusUnit(
      id: reader.readInt(),
      title: reader.readString(),
      topics: reader.readList().cast<SyllabusTopic>(),
    );
  }
  @override
  void write(BinaryWriter writer, SyllabusUnit obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.title);
    writer.writeList(obj.topics);
  }
}

class SyllabusTopicAdapter extends TypeAdapter<SyllabusTopic> {
  @override
  final int typeId = 12;
  @override
  SyllabusTopic read(BinaryReader reader) {
    return SyllabusTopic(
      name: reader.readString(),
      isCompleted: reader.readBool(),
    );
  }
  @override
  void write(BinaryWriter writer, SyllabusTopic obj) {
    writer.writeString(obj.name);
    writer.writeBool(obj.isCompleted);
  }
}

class SyllabusExamAdapter extends TypeAdapter<SyllabusExam> {
  @override
  final int typeId = 13;
  @override
  SyllabusExam read(BinaryReader reader) {
    return SyllabusExam(
      id: reader.readString(),
      name: reader.readString(),
      date: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      maxMarks: reader.readDouble(),
      marksObtained: reader.readBool() ? reader.readDouble() : null,
      scope: reader.readMap(),
      weightageGroupId: reader.readBool() ? reader.readString() : null,
    );
  }
  @override
  void write(BinaryWriter writer, SyllabusExam obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeDouble(obj.maxMarks);
    writer.writeBool(obj.marksObtained != null);
    if (obj.marksObtained != null) writer.writeDouble(obj.marksObtained!);
    writer.writeMap(obj.scope);
    writer.writeBool(obj.weightageGroupId != null);
    if (obj.weightageGroupId != null) writer.writeString(obj.weightageGroupId!);
  }
}

class WeightageGroupAdapter extends TypeAdapter<WeightageGroup> {
  @override
  final int typeId = 14;
  @override
  WeightageGroup read(BinaryReader reader) {
    return WeightageGroup(
      id: reader.readString(),
      name: reader.readString(),
      percentage: reader.readDouble(),
    );
  }
  @override
  void write(BinaryWriter writer, WeightageGroup obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeDouble(obj.percentage);
  }
}