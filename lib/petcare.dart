// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class PetCareTask {
  String name;
  String category;
  bool isCompleted;
  DateTime? reminderTime;
  String notes;
  int notificationId;

  PetCareTask({
    required this.name,
    required this.category,
    this.isCompleted = false,
    this.reminderTime,
    this.notes = '',
    required this.notificationId,
  });
}

class PetCarePage extends StatefulWidget {
  const PetCarePage({super.key});

  @override
  _PetCarePageState createState() => _PetCarePageState();
}

class _PetCarePageState extends State<PetCarePage> {
  final List<PetCareTask> _tasks = [];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _addTask() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    String selectedCategory = 'Feeding';
    DateTime? selectedReminderTime;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Pet Care Task'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Task Name'),
                    ),
                    DropdownButton<String>(
                      value: selectedCategory,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue!;
                        });
                      },
                      items: ['Feeding', 'Grooming', 'Vet Appointment', 'Exercise', 'Other']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    ListTile(
                      title: Text('Reminder Time: ${selectedReminderTime != null ? DateFormat('yMMMd').format(selectedReminderTime!) : 'Not set'}'),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedReminderTime ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedReminderTime = picked;
                          });
                        }
                      },
                    ),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: 'Notes'),
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
                if (nameController.text.isNotEmpty) {
                  final int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
                  final PetCareTask newTask = PetCareTask(
                    name: nameController.text,
                    category: selectedCategory,
                    reminderTime: selectedReminderTime,
                    notes: notesController.text,
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

  void _editTask(PetCareTask task) {
    final TextEditingController nameController = TextEditingController(text: task.name);
    final TextEditingController notesController = TextEditingController(text: task.notes);
    String selectedCategory = task.category;
    DateTime? selectedReminderTime = task.reminderTime;

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
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Task Name'),
                    ),
                    DropdownButton<String>(
                      value: selectedCategory,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue!;
                        });
                      },
                      items: ['Feeding', 'Grooming', 'Vet Appointment', 'Exercise', 'Other']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    ListTile(
                      title: Text('Reminder Time: ${selectedReminderTime != null ? DateFormat('yMMMd').format(selectedReminderTime!) : 'Not set'}'),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedReminderTime ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedReminderTime = picked;
                          });
                        }
                      },
                    ),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: 'Notes'),
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
                  task.name = nameController.text;
                  task.category = selectedCategory;
                  task.reminderTime = selectedReminderTime;
                  task.notes = notesController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteTask(PetCareTask task) {
    setState(() {
      _tasks.remove(task);
    });
  }

  void _toggleTaskCompletion(PetCareTask task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
  }

  void _scheduleNotification(PetCareTask task) async {
    if (task.reminderTime != null) {
      final tz.TZDateTime scheduledDate = tz.TZDateTime.from(task.reminderTime!, tz.local);

      var androidDetails = const AndroidNotificationDetails(
        'channelId',
        'channelName',
        channelDescription: 'Notification channel for pet care reminders',
        importance: Importance.high,
        priority: Priority.high,
      );
      var platformDetails = NotificationDetails(android: androidDetails);
      await flutterLocalNotificationsPlugin.zonedSchedule(
        task.notificationId,
        '${task.name} Reminder',
        'It\'s time for ${task.name} (${task.category})',
        scheduledDate,
        platformDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Care'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addTask,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return Card(
            child: ListTile(
              leading: Icon(
                task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                color: task.isCompleted ? Colors.green : Colors.red,
              ),
              title: Text(task.name),
              subtitle: Text('${task.category}\nNotes: ${task.notes}'),
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
                ],
              ),
              isThreeLine: true,
              onTap: () => _toggleTaskCompletion(task),
            ),
          );
        },
      ),
    );
  }
}