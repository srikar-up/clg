import 'package:hive/hive.dart';

@HiveType(typeId: 3)
class SyllabusItem extends HiveObject {
  @HiveField(0)
  String subjectName;
  @HiveField(1)
  String code;
  @HiveField(2)
  DateTime? examDate;
  @HiveField(3)
  double progress; // 0.0 to 1.0
  @HiveField(4)
  double? marksObtained; // Null if exam not taken
  @HiveField(5)
  double? totalMarks;

  SyllabusItem({
    required this.subjectName,
    required this.code,
    this.examDate,
    this.progress = 0.0,
    this.marksObtained,
    this.totalMarks,
  });
}

// Manual Adapter
class SyllabusItemAdapter extends TypeAdapter<SyllabusItem> {
  @override
  final int typeId = 3;

  @override
  SyllabusItem read(BinaryReader reader) {
    return SyllabusItem(
      subjectName: reader.readString(),
      code: reader.readString(),
      examDate: reader.read() as DateTime?, // DateTime is nullable
      progress: reader.readDouble(),
      marksObtained: reader.read() as double?,
      totalMarks: reader.read() as double?,
    );
  }

  @override
  void write(BinaryWriter writer, SyllabusItem obj) {
    writer.writeString(obj.subjectName);
    writer.writeString(obj.code);
    writer.write(obj.examDate);
    writer.writeDouble(obj.progress);
    writer.write(obj.marksObtained);
    writer.write(obj.totalMarks);
  }
}