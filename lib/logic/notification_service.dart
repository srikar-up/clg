import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../data/models.dart';
import '../data/syllabus_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      linux: LinuxInitializationSettings(
        defaultActionName: 'Open notification',
        defaultIcon: AssetsLinuxIcon('lib/logic/icons/icon.jpg'),
      ),
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tapped
      },
    );
  }

  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    if (scheduledTime.isBefore(DateTime.now())) return;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'life_os_channel_id',
          'Life OS Notifications',
          channelDescription: 'Reminders for quests and events',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Used for daily repeating quests reminder
  Future<void> scheduleDailyQuestReminder(int questCount) async {
    if (questCount == 0) {
      await flutterLocalNotificationsPlugin.cancel(id: 1000); // Fixed ID for daily quest
      return;
    }

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 9, 0); // 9:00 AM
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: 1000,
      title: 'Quest Reminder',
      body: 'You have $questCount active quests! Stay productive today.',
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'quest_channel_id',
          'Quest Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> syncNotifications(
      List<Quest> quests, List<LifeEvent> events) async {
    await requestPermissions();

    // 1. Quests Reminder (Daily if there are active quests)
    int activeQuests = quests.where((q) => !q.isCompleted).length;
    await scheduleDailyQuestReminder(activeQuests);

    // Cancel dynamic ones if we want to ensure clean state (optional, but let's cancel event ones)
    // For safety, only overwrite specific IDs, but canceling all except daily is hard without DB.
    // Instead, we just schedule over existing deterministic IDs.
    
    // 2. Event Reminders: "pop up in notifications when they are near like 5 days"
    for (var event in events) {
      // Deterministic ID per event base
      int baseId = (event.id.hashCode.abs() % 100000) * 10 + 2000;
      
      final daysUntil = event.daysUntil;
      
      // If the event is exactly 5, 4, 3, 2, 1, or 0 days away, show a notification.
      // Wait, let's schedule for 5 days before, and up to the event date.
      // Since `daysUntil` is dynamic relative to today, we can just schedule exactly for
      // today + offset if it falls within the 5 days. 
      // Actually, we can schedule 5 days before at 9:00AM. 
      final now = DateTime.now();
      
      // Calculate the next occurrence exactly
      DateTime nextOccurrence;
      final today = DateTime(now.year, now.month, now.day);
      if (event.isRecurring) {
        final eventThisYear = DateTime(now.year, event.date.month, event.date.day);
        if (eventThisYear.isBefore(today)) {
          nextOccurrence = DateTime(now.year + 1, event.date.month, event.date.day);
        } else {
          nextOccurrence = eventThisYear;
        }
      } else {
        nextOccurrence = event.date;
      }
      
      // We want to remind 5 days before, 3 days before, 1 day before, and day of.
      List<int> remindOffsets = [5, 3, 1, 0];
      
      for (int offset in remindOffsets) {
        DateTime remindDay = nextOccurrence.subtract(Duration(days: offset));
        
        int hour = 9;
        int minute = 0;
        if (offset == 0 && (event.date.hour != 0 || event.date.minute != 0)) {
          hour = event.date.hour;
          minute = event.date.minute;
        }
        
        DateTime remindTime = DateTime(remindDay.year, remindDay.month, remindDay.day, hour, minute);
        
        // If remindTime is in the past, maybe we should push it to 'now' just to pop up if it hasn't popped up?
        // Or if it's already today and we missed 9 AM, we could show it soon. For now, schedule properly.
        if (remindTime.isBefore(now)) {
           // if it's today but past 9 AM, we don't schedule, unless it's literally the same day, then maybe show immediately?
           if (remindDay.year == now.year && remindDay.month == now.month && remindDay.day == now.day) {
             remindTime = now.add(const Duration(minutes: 1)); // notify shortly after opening the app today
           } else {
             continue; // truly in the past
           }
        }
        
        String title = '';
        String body = '';
        if (offset == 5) {
          title = 'Upcoming Event: ${event.name}';
          body = 'Your event is starting in 5 days!';
        } else if (offset == 3) {
          title = 'Upcoming Event: ${event.name}';
          body = 'Your event is starting in 3 days!';
        } else if (offset == 1) {
          title = 'Reminder: ${event.name} is Tomorrow!';
          body = 'Get ready for your event tomorrow.';
        } else {
          title = 'Today: ${event.name}';
          body = 'Your event is happening today!';
        }
        
        await scheduleNotification(
          id: baseId + offset,
          title: title,
          body: body,
          scheduledTime: remindTime,
        );
      }
    }
  }

  Future<void> syncSyllabusNotifications(List<SyllabusSubject> subjects) async {
    await requestPermissions();

    final now = DateTime.now();
    for (var subject in subjects) {
      for (var exam in subject.exams) {
        // Deterministic ID per exam base
        int baseId = (exam.id.hashCode.abs() % 100000) * 10 + 3000;
        
        final diff = exam.date.difference(now).inDays;
        
        // "sylabus trackiification like exam date is near and the sylabus isnt full comleted from 3 days its should spam twise a day"
        if (diff >= 0 && diff <= 3) {
          int scopedTotal = 0;
          int scopedDone = 0;
          for (var unit in subject.units) {
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

          double completionPercent = 0.0;
          if (scopedTotal > 0) {
            completionPercent = (scopedDone / scopedTotal) * 100;
          } else if (subject.totalTopics > 0) {
            completionPercent = subject.masterProgress * 100;
          } else {
            completionPercent = 100.0; // Assume completed if no syllabus mapped
          }

          if (completionPercent < 100.0) {
            String title = 'Urgent: ${exam.name} Approach!';
            // Text requested: "ur x subject only 20 % comleted sylabus 2 days left"
            String body = 'Your ${subject.name} subject syllabus is only ${completionPercent.toStringAsFixed(0)}% completed. $diff days left!';
            
            // Spam twice a day. We will schedule for 8:00 AM and 6:00 PM (18:00) during the remaining days.
            List<int> hours = [8, 18];
            
            for (int d = diff; d >= 0; d--) {
               DateTime targetDay = exam.date.subtract(Duration(days: d));
               for (int h = 0; h < hours.length; h++) {
                 DateTime remindTime = DateTime(targetDay.year, targetDay.month, targetDay.day, hours[h], 0);
                 
                 // if remind time already passed, skip scheduling.
                 if (remindTime.isAfter(now)) {
                   await scheduleNotification(
                     id: baseId + (d * 10) + h,
                     title: title,
                     body: body,
                     scheduledTime: remindTime,
                   );
                 }
               }
            }
          }
        }
      }
    }
  }
}
