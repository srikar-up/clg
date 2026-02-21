import 'package:hive/hive.dart';

// We need to generate a TypeAdapter for Hive manually since we aren't using code generation
// to keep things simple for you.

// 1. TIMETABLE MODEL
@HiveType(typeId: 0)
class ScheduleItem extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String location;
  @HiveField(3)
  int weekday; // 1=Mon, 7=Sun
  @HiveField(4)
  int startHour;
  @HiveField(5)
  int startMinute;
  @HiveField(6)
  int endHour;
  @HiveField(7)
  int endMinute;
  @HiveField(8)
  String type; // 'class', 'exam', 'event'
  @HiveField(9)
  bool? attended; // null=pending, true=yes, false=no

  ScheduleItem({
    required this.id,
    required this.title,
    required this.location,
    required this.weekday,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.type,
    this.attended,
  });
}

// 2. GOAL / REWARD MODEL
@HiveType(typeId: 1)
class LifeGoal extends HiveObject {
  @HiveField(0)
  String title;
  @HiveField(1)
  bool isCompleted;
  @HiveField(2)
  int rewardPoints;

  LifeGoal({required this.title, this.isCompleted = false, required this.rewardPoints});
}

// 3. EXPENSE MODEL
@HiveType(typeId: 2)
class Expense extends HiveObject {
  @HiveField(0)
  String title;
  @HiveField(1)
  double amount;
  @HiveField(2)
  String category;
  @HiveField(3)
  DateTime date;
  @HiveField(4)
  bool isDebt; // True if money owed

  Expense({required this.title, required this.amount, required this.category, required this.date, this.isDebt = false});
}

// --- ADAPTERS (Manual Wiring for Hive) ---
class ScheduleItemAdapter extends TypeAdapter<ScheduleItem> {
  @override
  final int typeId = 0;
  @override
  ScheduleItem read(BinaryReader reader) {
    return ScheduleItem(
      id: reader.readString(),
      title: reader.readString(),
      location: reader.readString(),
      weekday: reader.readInt(),
      startHour: reader.readInt(),
      startMinute: reader.readInt(),
      endHour: reader.readInt(),
      endMinute: reader.readInt(),
      type: reader.readString(),
      attended: reader.readBool(), // handles null
    );
  }
  @override
  void write(BinaryWriter writer, ScheduleItem obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.location);
    writer.writeInt(obj.weekday);
    writer.writeInt(obj.startHour);
    writer.writeInt(obj.startMinute);
    writer.writeInt(obj.endHour);
    writer.writeInt(obj.endMinute);
    writer.writeString(obj.type);
    writer.writeBool(obj.attended ?? false); // simplistic handling for demo
  }
}

class LifeGoalAdapter extends TypeAdapter<LifeGoal> {
  @override
  final int typeId = 1;
  @override
  LifeGoal read(BinaryReader reader) {
    return LifeGoal(
      title: reader.readString(),
      isCompleted: reader.readBool(),
      rewardPoints: reader.readInt(),
    );
  }
  @override
  void write(BinaryWriter writer, LifeGoal obj) {
    writer.writeString(obj.title);
    writer.writeBool(obj.isCompleted);
    writer.writeInt(obj.rewardPoints);
  }
}

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 2;
  @override
  Expense read(BinaryReader reader) {
    return Expense(
      title: reader.readString(),
      amount: reader.readDouble(),
      category: reader.readString(),
      date: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      isDebt: reader.readBool(),
    );
  }
  @override
  void write(BinaryWriter writer, Expense obj) {
    writer.writeString(obj.title);
    writer.writeDouble(obj.amount);
    writer.writeString(obj.category);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeBool(obj.isDebt);
  }
}