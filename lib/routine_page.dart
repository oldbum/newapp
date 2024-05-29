// ignore_for_file: library_private_types_in_public_api, unused_element

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:new_app/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'billprovider.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'recurrence': recurrence,
      'icon': icon.codePoint,
      'notes': notes,
      'priority': priority,
      'notificationId': notificationId,
    };
  }

  factory RoutineTask.fromJson(Map<String, dynamic> json) {
    return RoutineTask(
      name: json['name'],
      isCompleted: json['isCompleted'],
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      recurrence: json['recurrence'],
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      notes: json['notes'],
      priority: json['priority'],
      notificationId: json['notificationId'],
    );
  }
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
    _loadTasks();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones(); // Initialize timezone data
  }

  Future<void> _requestPermissions() async {
    await requestExactAlarmPermission();
  }

  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tasksJson = prefs.getStringList('tasks') ?? [];
    setState(() {
      _tasks.clear();
      _tasks.addAll(tasksJson.map((jsonString) => RoutineTask.fromJson(json.decode(jsonString))).toList());
    });
  }

  Future<void> _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tasksJson = _tasks.map((task) => json.encode(task.toJson())).toList();
    await prefs.setStringList('tasks', tasksJson);
  }

  void _addTask() {
    final TextEditingController taskController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    String selectedRecurrence = 'None';
    List<String> recurrenceOptions = ['None', 'Daily', 'Weekly', 'Monthly'];
    IconData selectedIcon = Icons.check_circle_outline;
    int priority = 1;
    DateTime? selectedNotificationDate;
    TimeOfDay? selectedNotificationTime;

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
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text('Select Notification Date and Time'),
                      subtitle: Text(
                        selectedNotificationDate != null && selectedNotificationTime != null
                            ? '${DateFormat('yMMMd').format(selectedNotificationDate!)} ${selectedNotificationTime!.format(context)}'
                            : 'Not set',
                      ),
                      onTap: () => _selectNotificationDateTime(context, setState, selectedNotificationDate, selectedNotificationTime),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                taskController.clear();
                notesController.clear();
              },
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
                  if (selectedNotificationDate != null && selectedNotificationTime != null) {
                    _scheduleNotification(newTask, selectedNotificationDate!, selectedNotificationTime!);
                    final billProvider = Provider.of<BillProvider>(context, listen: false);
                    billProvider.addBill(Bill(
                      name: newTask.name,
                      amount: 0.0,
                      dueDate: selectedNotificationDate!,
                      paymentMethod: '',
                      billingPortalLink: '',
                      recurrence: newTask.recurrence,
                      notificationId: newTask.notificationId,
                      category: 'Routine',
                    ));
                  }
                  _saveTasks();
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
    DateTime? selectedNotificationDate;
    TimeOfDay? selectedNotificationTime;

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
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text('Select Notification Date and Time'),
                      subtitle: Text(
                        selectedNotificationDate != null && selectedNotificationTime != null
                            ? '${DateFormat('yMMMd').format(selectedNotificationDate!)} ${selectedNotificationTime!.format(context)}'
                            : 'Not set',
                      ),
                      onTap: () => _selectNotificationDateTime(context, setState, selectedNotificationDate, selectedNotificationTime),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
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
                _saveTasks();
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
    _saveTasks();
  }

  Future<void> _selectNotificationDateTime(BuildContext context, StateSetter setState, DateTime? selectedDate, TimeOfDay? selectedTime) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: selectedTime ?? TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDate = pickedDate;
          selectedTime = pickedTime;
        });
      }
    }
  }

  Future<void> _scheduleNotification(RoutineTask task, DateTime date, TimeOfDay time) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(date, tz.local)
        .add(Duration(hours: time.hour, minutes: time.minute));

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
                  if (task.notes.isNotEmpty) Text(task.notes),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editTask(task),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _tasks.remove(task);
                      });
                      flutterLocalNotificationsPlugin.cancel(task.notificationId);
                      _saveTasks();
                    },
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
                  if (task.notes.isNotEmpty) Text(task.notes),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
