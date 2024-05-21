import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class StudyTask {
  String title;
  String description;
  bool isImportant;
  bool isCompleted;
  DateTime? dueDate;
  int notificationId;

  StudyTask({
    required this.title,
    required this.description,
    this.isImportant = false,
    this.isCompleted = false,
    this.dueDate,
    required this.notificationId,
  });
}

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  _StudyPageState createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  final List<StudyTask> _tasks = [];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    tz.initializeTimeZones();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _addTask() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    bool isImportant = false;
    DateTime? dueDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Study Task'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    Row(
                      children: <Widget>[
                        const Text('Important: '),
                        Switch(
                          value: isImportant,
                          onChanged: (bool value) {
                            setState(() {
                              isImportant = value;
                            });
                          },
                        ),
                      ],
                    ),
                    ListTile(
                      title: Text('Due Date: ${dueDate != null ? DateFormat('yMMMd').format(dueDate!) : 'Not set'}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: dueDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null && pickedDate != dueDate) {
                            setState(() {
                              dueDate = pickedDate;
                            });
                          }
                        },
                      ),
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
                if (titleController.text.isNotEmpty) {
                  final int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
                  final StudyTask newTask = StudyTask(
                    title: titleController.text,
                    description: descriptionController.text,
                    isImportant: isImportant,
                    dueDate: dueDate,
                    notificationId: notificationId,
                  );
                  setState(() {
                    _tasks.add(newTask);
                  });
                  if (dueDate != null) {
                    _scheduleNotification(newTask);
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _editTask(StudyTask task) {
    final TextEditingController titleController = TextEditingController(text: task.title);
    final TextEditingController descriptionController = TextEditingController(text: task.description);
    bool isImportant = task.isImportant;
    DateTime? dueDate = task.dueDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Study Task'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    Row(
                      children: <Widget>[
                        const Text('Important: '),
                        Switch(
                          value: isImportant,
                          onChanged: (bool value) {
                            setState(() {
                              isImportant = value;
                            });
                          },
                        ),
                      ],
                    ),
                    ListTile(
                      title: Text('Due Date: ${dueDate != null ? DateFormat('yMMMd').format(dueDate!) : 'Not set'}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: dueDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null && pickedDate != dueDate) {
                            setState(() {
                              dueDate = pickedDate;
                            });
                          }
                        },
                      ),
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
                  task.title = titleController.text;
                  task.description = descriptionController.text;
                  task.isImportant = isImportant;
                  task.dueDate = dueDate;
                });
                if (dueDate != null) {
                  _scheduleNotification(task);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteTask(StudyTask task) {
    setState(() {
      _tasks.remove(task);
    });
    flutterLocalNotificationsPlugin.cancel(task.notificationId);
  }

  void _toggleTaskCompletion(StudyTask task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
  }

  void _scheduleNotification(StudyTask task) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(task.dueDate!, tz.local);

    var androidDetails = const AndroidNotificationDetails(
      'channelId',
      'channelName',
      channelDescription: 'Notification channel for study task reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    var iOSDetails = const IOSNotificationDetails();
    var platformDetails = NotificationDetails(android: androidDetails, iOS: iOSDetails);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.notificationId,
      'Study Task Reminder',
      'It\'s time to work on your task: ${task.title}',
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
        title: const Text('Study Tasks'),
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return Card(
            color: task.isImportant ? Colors.orange[100] : Colors.white,
            child: ListTile(
              title: Text(task.title, style: TextStyle(decoration: task.isCompleted ? TextDecoration.lineThrough : null)),
              subtitle: Text(task.description),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editTask(task),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteTask(task),
                  ),
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: (bool? value) {
                      _toggleTaskCompletion(task);
                    },
                  ),
                ],
              ),
              leading: task.dueDate != null ? Text(DateFormat('yMMMd').format(task.dueDate!)) : null,
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