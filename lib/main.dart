import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models.dart';
import 'data/syllabus_model.dart'; // Import the new model file

import 'logic/timetable_provider.dart';
import 'logic/life_provider.dart';
import 'logic/expense_provider.dart'; // New
import 'logic/syllabus_provider.dart'; // New

import 'screens/timetable_screen.dart';
import 'screens/life_os_screen.dart';
import 'screens/expense_screen.dart'; // New
import 'screens/syllabus_screen.dart'; // New

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Register Adapters
  Hive.registerAdapter(ScheduleItemAdapter());
  Hive.registerAdapter(LifeGoalAdapter());
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(SyllabusItemAdapter()); // Register Syllabus

  runApp(const StudentLifeOS());
}

class StudentLifeOS extends StatelessWidget {
  const StudentLifeOS({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimetableProvider()),
        ChangeNotifierProvider(create: (_) => LifeProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()), // New
        ChangeNotifierProvider(create: (_) => SyllabusProvider()), // New
      ],
      child: MaterialApp(
        title: 'Student OS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
          scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        ),
        home: const MainDashboard(),
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
  
  final List<Widget> _screens = [
    const TimetableScreen(),
    const LifeOsScreen(),
    const ExpenseScreen(), // Now connected
    const SyllabusScreen(), // Now connected
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        indicatorColor: Colors.red.shade600,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Timetable'),
          NavigationDestination(icon: Icon(Icons.check_circle_outline), label: 'Life OS'),
          NavigationDestination(icon: Icon(Icons.attach_money), label: 'Expenses'),
          NavigationDestination(icon: Icon(Icons.school_outlined), label: 'Syllabus'),
        ],
      ),
    );
  }
}