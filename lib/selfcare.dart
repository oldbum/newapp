import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class Habit {
  String name;
  bool isCompleted;

  Habit({required this.name, this.isCompleted = false});
}

class Goal {
  String name;
  DateTime deadline;
  bool isCompleted;

  Goal({required this.name, required this.deadline, this.isCompleted = false});
}

class Reflection {
  String content;
  DateTime date;

  Reflection({required this.content, required this.date});
}

class SelfCarePage extends StatefulWidget {
  const SelfCarePage({super.key});

  @override
  _SelfCarePageState createState() => _SelfCarePageState();
}

class _SelfCarePageState extends State<SelfCarePage> {
  final List<Habit> _habits = [];
  final List<Goal> _goals = [];
  final List<Reflection> _reflections = [];
  final List<String> _moods = ['Happy', 'Sad', 'Neutral', 'Excited', 'Stressed'];
  String? _selectedMood;
  DateTime? _moodDate;

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

  void _addHabit() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Habit'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Habit Name'),
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
                  setState(() {
                    _habits.add(Habit(name: nameController.text));
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleHabitCompletion(Habit habit) {
    setState(() {
      habit.isCompleted = !habit.isCompleted;
    });
  }

  void _addGoal() {
    final TextEditingController nameController = TextEditingController();
    DateTime deadline = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Goal'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Goal Name'),
                    ),
                    ListTile(
                      title: Text('Deadline: ${DateFormat('yMMMd').format(deadline)}'),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: deadline,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != deadline) {
                          setState(() {
                            deadline = picked;
                          });
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
                  setState(() {
                    _goals.add(Goal(name: nameController.text, deadline: deadline));
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleGoalCompletion(Goal goal) {
    setState(() {
      goal.isCompleted = !goal.isCompleted;
    });
  }

  void _addReflection() {
    final TextEditingController contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Reflection'),
          content: TextField(
            controller: contentController,
            decoration: const InputDecoration(labelText: 'Reflection'),
            maxLines: 5,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (contentController.text.isNotEmpty) {
                  setState(() {
                    _reflections.add(Reflection(content: contentController.text, date: DateTime.now()));
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _addMood() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Record Mood'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DropdownButton<String>(
                    value: _selectedMood,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedMood = newValue;
                      });
                    },
                    items: _moods.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  ListTile(
                    title: Text('Select Date: ${_moodDate != null ? DateFormat('yMMMd').format(_moodDate!) : 'Not set'}'),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _moodDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != _moodDate) {
                        setState(() {
                          _moodDate = picked;
                        });
                      }
                    },
                  ),
                ],
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
                if (_selectedMood != null && _moodDate != null) {
                  // Store mood information
                  Navigator.of(context).pop();
                }
              },
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
        title: const Text('Self Care'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addMood,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Daily Habits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ..._habits.map((habit) => CheckboxListTile(
                    title: Text(habit.name),
                    value: habit.isCompleted,
                    onChanged: (bool? value) {
                      _toggleHabitCompletion(habit);
                    },
                  )),
              Center(
                child: ElevatedButton(
                  onPressed: _addHabit,
                  child: const Text('Add Habit'),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Goals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ..._goals.map((goal) => CheckboxListTile(
                    title: Text(goal.name),
                    subtitle: Text('Deadline: ${DateFormat('yMMMd').format(goal.deadline)}'),
                    value: goal.isCompleted,
                    onChanged: (bool? value) {
                      _toggleGoalCompletion(goal);
                    },
                  )),
              Center(
                child: ElevatedButton(
                  onPressed: _addGoal,
                  child: const Text('Add Goal'),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Reflection Journal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ..._reflections.map((reflection) => ListTile(
                    title: Text(DateFormat('yMMMd').format(reflection.date)),
                    subtitle: Text(reflection.content),
                  )),
              Center(
                child: ElevatedButton(
                  onPressed: _addReflection,
                  child: const Text('Add Reflection'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}