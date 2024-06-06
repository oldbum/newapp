import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'billprovider.dart';

class Chore {
  String name;
  String frequency;
  DateTime? dueDate;
  bool isCompleted;
  int notificationId;
  bool hasNotification;

  Chore({
    required this.name,
    required this.frequency,
    this.dueDate,
    this.isCompleted = false,
    required this.notificationId,
    this.hasNotification = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'frequency': frequency,
        'dueDate': dueDate?.toIso8601String(),
        'isCompleted': isCompleted,
        'notificationId': notificationId,
        'hasNotification': hasNotification,
      };

  factory Chore.fromJson(Map<String, dynamic> json) => Chore(
        name: json['name'],
        frequency: json['frequency'],
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        isCompleted: json['isCompleted'],
        notificationId: json['notificationId'],
        hasNotification: json['hasNotification'],
      );
}

class ChoresPage extends StatefulWidget {
  const ChoresPage({super.key});

  @override
  _ChoresPageState createState() => _ChoresPageState();
}

class _ChoresPageState extends State<ChoresPage> {
  final List<Chore> _chores = [];
  final List<Map<String, String>> _suggestedChores = [
    {'name': 'Clean the Fridge', 'frequency': 'Monthly'},
    {'name': 'Clean the Oven', 'frequency': 'Monthly'},
    {'name': 'Dust Ceiling Fans', 'frequency': 'Monthly'},
    {'name': 'Change Air Filters', 'frequency': 'Monthly'},
    {'name': 'Clean Windows', 'frequency': 'Monthly'},
    {'name': 'Vacuum Under Furniture', 'frequency': 'Weekly'},
    {'name': 'Mop Floors', 'frequency': 'Weekly'},
  ];

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _initializeNotifications();
    _loadData();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final choresJson = _chores.map((chore) => json.encode(chore.toJson())).toList();
    await prefs.setStringList('chores', choresJson);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final choresJson = prefs.getStringList('chores') ?? [];
    setState(() {
      _chores.addAll(choresJson.map((jsonString) => Chore.fromJson(json.decode(jsonString))));
    });
  }

  void _addChore() {
    final TextEditingController nameController = TextEditingController();
    String selectedFrequency = 'Daily';
    DateTime? selectedDateTime;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Chore'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Chore Name'),
                    ),
                    DropdownButton<String>(
                      value: selectedFrequency,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedFrequency = newValue!;
                        });
                      },
                      items: ['Daily', 'Weekly', 'Monthly', 'Yearly']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    ListTile(
                      title: Text(selectedDateTime != null ? DateFormat('yMMMd').add_jm().format(selectedDateTime!) : 'Set Notification'),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );

                        if (pickedDate != null) {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                          );

                          if (pickedTime != null) {
                            setState(() {
                              selectedDateTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
                            });
                          }
                        }
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
                if (nameController.text.isNotEmpty) {
                  final int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
                  DateTime dueDate = _calculateNextDueDate(selectedFrequency);
                  setState(() {
                    _chores.add(Chore(
                      name: nameController.text,
                      frequency: selectedFrequency,
                      dueDate: dueDate,
                      notificationId: notificationId,
                      hasNotification: selectedDateTime != null,
                    ));
                  });
                  if (selectedDateTime != null) {
                    _scheduleNotification(context, notificationId, nameController.text, selectedDateTime!);
                  }
                  _saveData();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _editChore(Chore chore) {
    final TextEditingController nameController = TextEditingController(text: chore.name);
    String selectedFrequency = chore.frequency;
    DateTime? selectedDateTime = chore.dueDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Chore'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Chore Name'),
                    ),
                    DropdownButton<String>(
                      value: selectedFrequency,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedFrequency = newValue!;
                        });
                      },
                      items: ['Daily', 'Weekly', 'Monthly', 'Yearly']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    ListTile(
                      title: Text(selectedDateTime != null ? DateFormat('yMMMd').add_jm().format(selectedDateTime!) : 'Set Notification'),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );

                        if (pickedDate != null) {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                          );

                          if (pickedTime != null) {
                            setState(() {
                              selectedDateTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
                            });
                          }
                        }
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
                  chore.name = nameController.text;
                  chore.frequency = selectedFrequency;
                  chore.dueDate = _calculateNextDueDate(selectedFrequency);
                  chore.hasNotification = selectedDateTime != null;
                });
                if (selectedDateTime != null) {
                  _updateNotification(context, chore.notificationId, chore.name, selectedDateTime!);
                } else {
                  _cancelNotification(context, chore.notificationId);
                }
                _saveData();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteChore(Chore chore) {
    setState(() {
      _chores.remove(chore);
    });
    _cancelNotification(context, chore.notificationId);
    _saveData();
  }

  DateTime _calculateNextDueDate(String frequency) {
    if (frequency == 'Daily') {
      return DateTime.now().add(const Duration(days: 1));
    } else if (frequency == 'Weekly') {
      return DateTime.now().add(const Duration(days: 7));
    } else if (frequency == 'Monthly') {
      return DateTime.now().add(const Duration(days: 30));
    } else {
      return DateTime.now().add(const Duration(days: 365));
    }
  }

  void _scheduleNotification(BuildContext context, int id, String title, DateTime dueDate) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(dueDate, tz.local);
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'chore_channel', // channelId
      'Chore Reminders', // channelName
      channelDescription: 'Channel for chore reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    final provider = Provider.of<BillProvider>(context, listen: false);
    provider.addNotification(MyNotification(
      title: 'Chore Reminder',
      body: 'It\'s time to complete your chore: $title',
      dateTime: scheduledDate,
      notificationId: id,
    ));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Chore Reminder',
      'It\'s time to complete your chore: $title',
      scheduledDate,
      platformDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void _updateNotification(BuildContext context, int id, String title, DateTime dueDate) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    _scheduleNotification(context, id, title, dueDate);
  }

  void _cancelNotification(BuildContext context, int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);

    final provider = Provider.of<BillProvider>(context, listen: false);
    provider.removeNotification(MyNotification(
      title: '',
      body: '',
      dateTime: DateTime.now(),
      notificationId: id,
    ));
  }

  void _toggleChoreCompletion(Chore chore) {
    setState(() {
      chore.isCompleted = !chore.isCompleted;
      if (chore.isCompleted) {
        final DateTime nextDueDate = _calculateNextDueDate(chore.frequency);
        chore.dueDate = nextDueDate;
        if (chore.hasNotification) {
          _scheduleNotification(context, chore.notificationId, chore.name, nextDueDate);
        }
      } else {
        _cancelNotification(context, chore.notificationId);
      }
    });
    _saveData();
  }

  void _showSuggestedChores() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Suggested Chores'),
          content: SingleChildScrollView(
            child: Column(
              children: _suggestedChores.map((chore) {
                return ListTile(
                  title: Text(chore['name']!),
                  subtitle: Text('Frequency: ${chore['frequency']}'),
                  trailing: ElevatedButton(
                    child: const Text('Add'),
                    onPressed: () {
                      final int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
                      DateTime dueDate = _calculateNextDueDate(chore['frequency']!);
                      setState(() {
                        _chores.add(Chore(
                          name: chore['name']!,
                          frequency: chore['frequency']!,
                          dueDate: dueDate,
                          notificationId: notificationId,
                        ));
                      });
                      _scheduleNotification(context, notificationId, chore['name']!, dueDate);
                      Navigator.of(context).pop();
                      _saveData();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb),
            onPressed: _showSuggestedChores,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.2, // Adjust the opacity as needed
              child: Image.asset(
                'assets/chores.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          _chores.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No chores added yet!',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Press the + to add a new chore',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _chores.length,
                  itemBuilder: (context, index) {
                    final chore = _chores[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(chore.name),
                        subtitle: Text('Due: ${DateFormat('yMMMd').format(chore.dueDate!)} - ${chore.frequency}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: chore.isCompleted,
                              onChanged: (bool? value) {
                                _toggleChoreCompletion(chore);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editChore(chore),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteChore(chore),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addChore,
        child: const Icon(Icons.add),
        backgroundColor: Colors.purple.shade100, // Light purple color
      ),
    );
  }
}