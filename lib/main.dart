import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models.dart';
import 'data/syllabus_model.dart'; // Import the new model file

import 'logic/timetable_provider.dart';
import 'logic/life_provider.dart';
import 'logic/expense_provider.dart'; // New
import 'logic/syllabus_provider.dart'; // New
import 'logic/theme_provider.dart'; // New

import 'screens/timetable_screen.dart';
import 'screens/life_os_screen.dart';
import 'screens/expense_screen.dart'; // New
import 'screens/syllabus_screen.dart'; // New
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Register Adapters
  Hive.registerAdapter(ScheduleItemAdapter());
  Hive.registerAdapter(LifeGoalAdapter());
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(QuestAdapter());
  Hive.registerAdapter(WorkCounterAdapter());
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(LifeEventAdapter());
  Hive.registerAdapter(SyllabusSubjectAdapter());
  Hive.registerAdapter(SyllabusUnitAdapter());
  Hive.registerAdapter(SyllabusTopicAdapter());
  Hive.registerAdapter(SyllabusExamAdapter());
  Hive.registerAdapter(WeightageGroupAdapter());
  runApp(const StudentLifeOS());
}

class StudentLifeOS extends StatelessWidget {
  const StudentLifeOS({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TimetableProvider()),
        ChangeNotifierProvider(create: (_) => LifeProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()), // New
        ChangeNotifierProvider(create: (_) => SyllabusProvider()), // New
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProv, child) {
          if (!themeProv.isInit) return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
          final config = themeProv.config;
          return MaterialApp(
            title: 'Student OS',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              brightness: config.brightness,
              colorSchemeSeed: config.seedColor,
              scaffoldBackgroundColor: config.scaffoldBg,
            ),
            home: const MainDashboard(),
          );
        },
      ),
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _index = 0;
  
  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(onNavigateToTimetable: () => setState(() => _index = 1)),
      const TimetableScreen(),
      const LifeOsScreen(),
      const ExpenseScreen(),
      const SyllabusScreen(),
    ];

    final themeProv = context.watch<ThemeProvider>();
    final config = themeProv.config;

    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: NavigationBar(
        backgroundColor: config.navBarBg,
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        indicatorColor: config.navIndicatorBg,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: 'Status'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Timetable'),
          NavigationDestination(icon: Icon(Icons.check_circle_outline), label: 'Life OS'),
          NavigationDestination(icon: Icon(Icons.attach_money), label: 'Expenses'),
          NavigationDestination(icon: Icon(Icons.school_outlined), label: 'Syllabus'),
        ],
      ),
    );
  }
}
