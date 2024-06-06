import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'billprovider.dart';
import 'chores.dart';
import 'event_planning_page.dart';
import 'event_planning_provider.dart';
import 'finance_page.dart';
import 'grocery_provider.dart';
import 'grocery_item.dart';
import 'groceryshopping.dart';
import 'healthwellness.dart';
import 'home_improvement.dart';
import 'homeimprovementprovider.dart' as home_improvement_provider;
import 'loginsupercenter_page.dart';
import 'mealplanning.dart';
import 'notificationspage.dart';
import 'onboarding.dart';
import 'recipe_provider.dart';
import 'routine_page.dart';
import 'selfcare.dart';
import 'travel_packing_provider.dart';
import 'travelpacking.dart';
import 'workprojects.dart';

int notificationCounter = 0;

int generateNotificationId() {
  return notificationCounter++;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeNotifications();
  tz.initializeTimeZones();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BillProvider()),
        ChangeNotifierProvider(create: (_) => home_improvement_provider.HomeImprovementProvider()),
        ChangeNotifierProvider(create: (_) => GroceryProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => TravelPackingProvider()),
        ChangeNotifierProvider(create: (_) => EventPlanningProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

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
        '/': (context) => OnboardingScreen(),
        '/home': (context) => const TaskManagerPage(),
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
      {'name': 'Shopping List', 'icon': Icons.shopping_cart},
      {'name': 'Meal Planning', 'icon': Icons.restaurant},
      {'name': 'Work Projects', 'icon': Icons.work},
      {'name': 'Home Improvements', 'icon': Icons.home_repair_service},
      {'name': 'Travel/Packing', 'icon': Icons.card_travel},
      {'name': 'Event Planning', 'icon': Icons.event},
      {'name': 'Health and Wellness', 'icon': Icons.health_and_safety},
      {'name': 'Self Care', 'icon': Icons.self_improvement},
      {'name': 'Chores', 'icon': Icons.cleaning_services},
      {'name': 'Login Supercenter', 'icon': Icons.login},
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
                  Scaffold.of(context).openEndDrawer();
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
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return TaskButton(task: tasks[index], context: context);
        },
      ),
    );
  }

  Widget TaskButton({required Map<String, dynamic> task, required BuildContext context}) {
    return GestureDetector(
      onTap: () {
        if (task['name'] == 'Finance') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const FinancePage()));
        } else if (task['name'] == 'Daily Routine') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => RoutinePage()));
        } else if (task['name'] == 'Shopping List') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const GroceryPage(initialItems: [])));
        } else if (task['name'] == 'Meal Planning') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => MealPlanningPage(addToGroceryList: (items) {
            // Logic to add items to grocery list
            final groceryProvider = Provider.of<GroceryProvider>(context, listen: false);
            items.forEach((item) {
              final groceryItem = GroceryItem(
                name: item,
                category: 'Other',
                notificationId: generateNotificationId(),
                quantity: 1,
                unit: 'pcs',
              );
              groceryProvider.addItem(groceryItem);
            });
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
        } else if (task['name'] == 'Chores') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ChoresPage()));
        } else if (task['name'] == 'Self Care') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SelfCarePage()));
        } else if (task['name'] == 'Login Supercenter') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginSupercenterPage()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${task['name']} was tapped. No specific page for this task.')));
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(task['icon'], size: 40, color: Colors.blue),
              const SizedBox(height: 8),
              Text(task['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
