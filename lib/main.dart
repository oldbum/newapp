import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'routine_page.dart';
import 'loginsupercenter_page.dart';
import 'finance_page.dart';
import 'groceryshopping.dart';
import 'mealplanning.dart';
import 'workprojects.dart';
import 'home_improvement.dart';
import 'travelpacking.dart';
import 'eventplanning.dart';
import 'healthwellness.dart';
import 'study.dart';
import 'petcare.dart';
import 'gardening.dart';
import 'selfcare.dart';
import 'chores.dart';
import 'onboarding.dart';
import 'signup.dart';
import 'login.dart';
import 'profile_page.dart';

int notificationCounter = 0;
int generateNotificationId() {
  return notificationCounter++;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeNotifications();
  tz.initializeTimeZones();
  runApp(const MyApp());
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> requestExactAlarmPermission() async {
  if (await Permission.scheduleExactAlarm.request().isGranted) {
    // Permission is granted
  } else {
    // Permission is denied
    openAppSettings();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chore Score',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/home': (context) => const TaskManagerPage(),
        '/signup': (context) => SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}

class TaskManagerPage extends StatelessWidget {
  const TaskManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tasks = [
      {'name': 'Finance', 'icon': Icons.attach_money},
      {'name': 'Daily Routine', 'icon': Icons.check_circle_outline},
      {'name': 'Grocery Shopping', 'icon': Icons.shopping_cart},
      {'name': 'Meal Planning', 'icon': Icons.restaurant},
      {'name': 'Work Projects', 'icon': Icons.work},
      {'name': 'Home Improvements', 'icon': Icons.home_repair_service},
      {'name': 'Travel/Packing', 'icon': Icons.card_travel},
      {'name': 'Event Planning', 'icon': Icons.event},
      {'name': 'Health and Wellness', 'icon': Icons.health_and_safety},
      {'name': 'Study', 'icon': Icons.school},
      {'name': 'Pet Care', 'icon': Icons.pets},
      {'name': 'Gardening', 'icon': Icons.grass},
      {'name': 'Self Care', 'icon': Icons.self_improvement},
      {'name': 'Chores', 'icon': Icons.cleaning_services},
      {'name': 'Login Supercenter', 'icon': Icons.lock},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo.png',
          height: 50,
        ),
        centerTitle: true,
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer(); // Open the end drawer
                },
              );
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            // Add other menu items here
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Wrap(
              spacing: 20, // Horizontal space between buttons
              runSpacing: 20, // Vertical space between buttons
              alignment: WrapAlignment.spaceEvenly,
              children: tasks.map((task) => TaskButton(task: task, context: context)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget TaskButton({required Map<String, dynamic> task, required BuildContext context}) {
    return ElevatedButton.icon(
      onPressed: () {
        if (task['name'] == 'Finance') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const FinancePage()));
        } else if (task['name'] == 'Daily Routine') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const RoutinePage()));
        } else if (task['name'] == 'Grocery Shopping') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const GroceryPage(initialItems: [])));
        } else if (task['name'] == 'Meal Planning') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => MealPlanningPage(addToGroceryList: (items) {
            // Logic to add items to grocery list
          })));
        } else if (task['name'] == 'Work Projects') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkProjectsPage()));
        } else if (task['name'] == 'Home Improvements') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeImprovementsPage()));
        } else if (task['name'] == 'Travel/Packing') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TravelPackingPage()));
        } else if (task['name'] == 'Event Planning') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const EventPlanningPage()));
        } else if (task['name'] == 'Health and Wellness') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const HealthAndWellnessPage()));
        } else if (task['name'] == 'Gardening') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const GardeningPage()));
        } else if (task['name'] == 'Chores') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ChoresPage()));
        } else if (task['name'] == 'Self Care') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SelfCarePage()));
        } else if (task['name'] == 'Pet Care') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PetCarePage()));
        } else if (task['name'] == 'Study') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const StudyPage()));
        } else if (task['name'] == 'Login Supercenter') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginSupercenterPage()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${task['name']} was tapped. No specific page for this task.')));
        }
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue, // Text color
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      icon: Icon(task['icon']),
      label: Text(task['name']),
    );
  }
}
