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
  @HiveField(3)
  DateTime? endDate;

  LifeGoal({required this.title, this.isCompleted = false, required this.rewardPoints, this.endDate});
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
  @HiveField(5)
  double interestRate;
  @HiveField(6)
  bool isCompound;

  Expense({
    required this.title, 
    required this.amount, 
    required this.category, 
    required this.date, 
    this.isDebt = false,
    this.interestRate = 0.0,
    this.isCompound = false,
  });
}

// 4. QUEST MODEL
@HiveType(typeId: 3)
class Quest extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String rank; // 'gold', 'silver', 'bronze', 'steel'
  @HiveField(3)
  String type; // 'repeating', 'daily', 'monthly', 'reminder'
  @HiveField(4)
  int currentProgress;
  @HiveField(5)
  int targetProgress;
  @HiveField(6)
  String? reward; // e.g., "Ice Cream"
  @HiveField(7)
  bool isCompleted;
  @HiveField(8)
  DateTime createdAt;
  @HiveField(9)
  DateTime? completedAt;
  @HiveField(10)
  DateTime? deadline;
  @HiveField(11)
  int xpPenalty;

  int get xpReward {
    switch (rank) {
      case 'gold': return 150;
      case 'silver': return 100;
      case 'bronze': return 50;
      case 'steel': return 20;
      default: return 0;
    }
  }

  Quest({
    required this.id,
    required this.title,
    required this.rank,
    required this.type,
    this.currentProgress = 0,
    this.targetProgress = 1,
    this.reward,
    this.isCompleted = false,
    DateTime? createdAt,
    this.completedAt,
    this.deadline,
    this.xpPenalty = 0,
  }) : createdAt = createdAt ?? DateTime.now();
}

// 5. WORK COUNTER MODEL
@HiveType(typeId: 4)
class WorkCounter extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  int count;
  @HiveField(3)
  DateTime createdAt;
  @HiveField(4)
  int xpReward;
  @HiveField(5)
  String iconData;

  WorkCounter({
    required this.id,
    required this.title,
    this.count = 0,
    DateTime? createdAt,
    this.xpReward = 10,
    this.iconData = 'bolt',
  }) : createdAt = createdAt ?? DateTime.now();
}

// 6. NOTE MODEL
@HiveType(typeId: 5)
class Note extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String content;
  @HiveField(2)
  String noteType; // 'permanent' or 'temporary'
  @HiveField(3)
  DateTime createdAt;
  @HiveField(4)
  DateTime? expiresAt;

  Note({
    required this.id,
    required this.content,
    required this.noteType,
    DateTime? createdAt,
    this.expiresAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isExpired => noteType == 'temporary' && expiresAt != null && DateTime.now().isAfter(expiresAt!);
}

// 7. EVENT MODEL
@HiveType(typeId: 6)
class LifeEvent extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String eventType; // 'birthday' or 'other'
  @HiveField(3)
  DateTime date;
  @HiveField(4)
  bool isRecurring;

  LifeEvent({
    required this.id,
    required this.name,
    required this.eventType,
    required this.date,
    this.isRecurring = false,
  });

  int get daysUntil {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime nextOccurrence;
    
    if (isRecurring) {
      final eventThisYear = DateTime(now.year, date.month, date.day);
      if (eventThisYear.isBefore(today)) {
        nextOccurrence = DateTime(now.year + 1, date.month, date.day);
      } else {
        nextOccurrence = eventThisYear;
      }
    } else {
      nextOccurrence = date;
    }
    
    return nextOccurrence.difference(today).inDays;
  }

  bool get isWithin10Days => daysUntil >= 0 && daysUntil <= 10;
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
      endDate: reader.readBool() ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null,
    );
  }
  @override
  void write(BinaryWriter writer, LifeGoal obj) {
    writer.writeString(obj.title);
    writer.writeBool(obj.isCompleted);
    writer.writeInt(obj.rewardPoints);
    writer.writeBool(obj.endDate != null);
    if (obj.endDate != null) {
      writer.writeInt(obj.endDate!.millisecondsSinceEpoch);
    }
  }
}

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 2;
  @override
  Expense read(BinaryReader reader) {
    String title = reader.readString();
    double amount = reader.readDouble();
    String category = reader.readString();
    DateTime date = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    bool isDebt = reader.readBool();
    double interestRate = 0.0;
    bool isCompound = false;
    try {
      interestRate = reader.readDouble();
      isCompound = reader.readBool();
    } catch (e) {
      // old format
    }
    return Expense(
      title: title,
      amount: amount,
      category: category,
      date: date,
      isDebt: isDebt,
      interestRate: interestRate,
      isCompound: isCompound,
    );
  }
  @override
  void write(BinaryWriter writer, Expense obj) {
    writer.writeString(obj.title);
    writer.writeDouble(obj.amount);
    writer.writeString(obj.category);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeBool(obj.isDebt);
    writer.writeDouble(obj.interestRate);
    writer.writeBool(obj.isCompound);
  }
}

class QuestAdapter extends TypeAdapter<Quest> {
  @override
  final int typeId = 3;
  @override
  Quest read(BinaryReader reader) {
    return Quest(
      id: reader.readString(),
      title: reader.readString(),
      rank: reader.readString(),
      type: reader.readString(),
      currentProgress: reader.readInt(),
      targetProgress: reader.readInt(),
      reward: reader.readString(),
      isCompleted: reader.readBool(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      completedAt: reader.readBool() ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null,
      deadline: reader.readBool() ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null,
      xpPenalty: reader.readInt(),
    );
  }
  @override
  void write(BinaryWriter writer, Quest obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.rank);
    writer.writeString(obj.type);
    writer.writeInt(obj.currentProgress);
    writer.writeInt(obj.targetProgress);
    writer.writeString(obj.reward ?? '');
    writer.writeBool(obj.isCompleted);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeBool(obj.completedAt != null);
    if (obj.completedAt != null) {
      writer.writeInt(obj.completedAt!.millisecondsSinceEpoch);
    }
    writer.writeBool(obj.deadline != null);
    if (obj.deadline != null) {
      writer.writeInt(obj.deadline!.millisecondsSinceEpoch);
    }
    writer.writeInt(obj.xpPenalty);
  }
}

class WorkCounterAdapter extends TypeAdapter<WorkCounter> {
  @override
  final int typeId = 4;
  @override
  WorkCounter read(BinaryReader reader) {
    return WorkCounter(
      id: reader.readString(),
      title: reader.readString(),
      count: reader.readInt(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      xpReward: reader.readInt(),
      iconData: reader.readString(),
    );
  }
  @override
  void write(BinaryWriter writer, WorkCounter obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeInt(obj.count);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeInt(obj.xpReward);
    writer.writeString(obj.iconData);
  }
}

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 5;
  @override
  Note read(BinaryReader reader) {
    return Note(
      id: reader.readString(),
      content: reader.readString(),
      noteType: reader.readString(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      expiresAt: reader.readBool() ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null,
    );
  }
  @override
  void write(BinaryWriter writer, Note obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.content);
    writer.writeString(obj.noteType);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeBool(obj.expiresAt != null);
    if (obj.expiresAt != null) {
      writer.writeInt(obj.expiresAt!.millisecondsSinceEpoch);
    }
  }
}

class LifeEventAdapter extends TypeAdapter<LifeEvent> {
  @override
  final int typeId = 6;
  @override
  LifeEvent read(BinaryReader reader) {
    return LifeEvent(
      id: reader.readString(),
      name: reader.readString(),
      eventType: reader.readString(),
      date: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      isRecurring: reader.readBool(),
    );
  }
  @override
  void write(BinaryWriter writer, LifeEvent obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.eventType);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeBool(obj.isRecurring);
  }
}