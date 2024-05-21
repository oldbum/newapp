import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'main.dart'; // Adjust this import based on your project structure

class RoutineTask {
  String name;
  bool isCompleted;
  DateTime? completedAt;
  String recurrence;
  IconData icon;
  String notes;
  int priority;
  int notificationId;

  RoutineTask({
    required this.name,
    this.isCompleted = false,
    this.completedAt,
    required this.recurrence,
    required this.icon,
    this.notes = '',
    this.priority = 1,
    required this.notificationId,
  });
}

class RoutinePage extends StatefulWidget {
  const RoutinePage({super.key});

  @override
  _RoutinePageState createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  final List<RoutineTask> _tasks = [];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _requestPermissions();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _requestPermissions() async {
    await requestExactAlarmPermission();
  }

  void _addTask() {
    final TextEditingController taskController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    String selectedRecurrence = 'None';
    List<String> recurrenceOptions = ['None', 'Daily', 'Weekly', 'Monthly'];
    IconData selectedIcon = Icons.check_circle_outline;
    int priority = 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: taskController,
                      decoration: const InputDecoration(labelText: 'Task Name'),
                    ),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: 'Notes'),
                    ),
                    DropdownButton<String>(
                      value: selectedRecurrence,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedRecurrence = newValue!;
                        });
                      },
                      items: recurrenceOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    DropdownButton<IconData>(
                      value: selectedIcon,
                      onChanged: (IconData? newValue) {
                        setState(() {
                          selectedIcon = newValue!;
                        });
                      },
                      items: [
                        Icons.check_circle_outline,
                        Icons.home,
                        Icons.work,
                        Icons.pets,
                        Icons.shopping_cart,
                      ].map((IconData value) {
                        return DropdownMenuItem<IconData>(
                          value: value,
                          child: Icon(value),
                        );
                      }).toList(),
                    ),
                    const Text(
                      'Priority',
                      style: TextStyle(fontSize: 16),
                    ),
                    Slider(
                      value: priority.toDouble(),
                      min: 1,
                      max: 3,
                      divisions: 2,
                      label: priority == 1 ? 'Low' : priority == 2 ? 'Medium' : 'High',
                      onChanged: (double value) {
                        setState(() {
                          priority = value.toInt();
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (taskController.text.isNotEmpty) {
                  final int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
                  final RoutineTask newTask = RoutineTask(
                    name: taskController.text,
                    recurrence: selectedRecurrence,
                    icon: selectedIcon,
                    notes: notesController.text,
                    priority: priority,
                    notificationId: notificationId,
                  );
                  setState(() {
                    _tasks.add(newTask);
                  });
                  _scheduleNotification(newTask);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _editTask(RoutineTask task) {
    final TextEditingController taskController = TextEditingController(text: task.name);
    final TextEditingController notesController = TextEditingController(text: task.notes);
    String selectedRecurrence = task.recurrence;
    List<String> recurrenceOptions = ['None', 'Daily', 'Weekly', 'Monthly'];
    IconData selectedIcon = task.icon;
    int priority = task.priority;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: taskController,
                      decoration: const InputDecoration(labelText: 'Task Name'),
                    ),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: 'Notes'),
                    ),
                    DropdownButton<String>(
                      value: selectedRecurrence,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedRecurrence = newValue!;
                        });
                      },
                      items: recurrenceOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    DropdownButton<IconData>(
                      value: selectedIcon,
                      onChanged: (IconData? newValue) {
                        setState(() {
                          selectedIcon = newValue!;
                        });
                      },
                      items: [
                        Icons.check_circle_outline,
                        Icons.home,
                        Icons.work,
                        Icons.pets,
                        Icons.shopping_cart,
                      ].map((IconData value) {
                        return DropdownMenuItem<IconData>(
                          value: value,
                          child: Icon(value),
                        );
                      }).toList(),
                    ),
                    const Text(
                      'Priority',
                      style: TextStyle(fontSize: 16),
                    ),
                    Slider(
                      value: priority.toDouble(),
                      min: 1,
                      max: 3,
                      divisions: 2,
                      label: priority == 1 ? 'Low' : priority == 2 ? 'Medium' : 'High',
                      onChanged: (double value) {
                        setState(() {
                          priority = value.toInt();
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                setState(() {
                  task.name = taskController.text;
                  task.notes = notesController.text;
                  task.recurrence = selectedRecurrence;
                  task.icon = selectedIcon;
                  task.priority = priority;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleTaskCompletion(RoutineTask task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
      task.completedAt = task.isCompleted ? DateTime.now() : null;
    });
  }

  void _scheduleNotification(RoutineTask task) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)); // Placeholder for the demo

    var androidDetails = const AndroidNotificationDetails(
      'channelId',
      'channelName',
      channelDescription: 'Notification channel for routine reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    var iOSDetails = const IOSNotificationDetails();
    var platformDetails = NotificationDetails(android: androidDetails, iOS: iOSDetails);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.notificationId,
      '${task.name} Reminder',
      'It\'s time to complete your task: ${task.name}',
      scheduledDate,
      platformDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  void _resetTaskCompletion(RoutineTask task) {
    setState(() {
      task.isCompleted = false;
      task.completedAt = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Routine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RoutineHistoryPage(tasks: _tasks)),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return Card(
            color: task.isCompleted ? Colors.green[100] : Colors.red[100],
            child: ListTile(
              leading: Icon(task.icon),
              title: Text(task.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Priority: ${task.priority == 1 ? 'Low' : task.priority == 2 ? 'Medium' : 'High'}'),
                  if (task.notes.isNotEmpty) Text('Notes: ${task.notes}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editTask(task),
                  ),
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: (bool? value) {
                      _toggleTaskCompletion(task);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class RoutineHistoryPage extends StatelessWidget {
  final List<RoutineTask> tasks;

  const RoutineHistoryPage({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final completedTasks = tasks.where((task) => task.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Routine History'),
      ),
      body: ListView.builder(
        itemCount: completedTasks.length,
        itemBuilder: (context, index) {
          final task = completedTasks[index];
          return Card(
            child: ListTile(
              leading: Icon(task.icon),
              title: Text(task.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Completed at: ${DateFormat('yMMMd').format(task.completedAt!)} ${DateFormat('jm').format(task.completedAt!)}'),
                  if (task.notes.isNotEmpty) Text('Notes: ${task.notes}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}