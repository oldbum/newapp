// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;

class Habit {
  String name;
  bool isCompleted;
  DateTime? completedDate;

  Habit({required this.name, this.isCompleted = false, this.completedDate});
}

class Goal {
  String name;
  DateTime deadline;
  bool isCompleted;
  DateTime? completedDate;

  Goal({required this.name, required this.deadline, this.isCompleted = false, this.completedDate});
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
  final List<Habit> _habitHistory = [];
  final List<Goal> _goalHistory = [];
  final List<Reflection> _reflections = [];

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _scheduleDailyReset();
  }

  void _scheduleDailyReset() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final duration = tomorrow.difference(now);

    Future.delayed(duration, () {
      setState(() {
        for (var habit in _habits) {
          if (habit.isCompleted) {
            habit.completedDate = DateTime.now();
            _habitHistory.add(habit);
          }
          habit.isCompleted = false;
        }
      });
      _scheduleDailyReset();
    });
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

  void _editHabit(Habit habit) {
    final TextEditingController nameController = TextEditingController(text: habit.name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Habit'),
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
              child: const Text('Save'),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    habit.name = nameController.text;
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

  void _deleteHabit(Habit habit) {
    setState(() {
      _habits.remove(habit);
    });
  }

  void _toggleHabitCompletion(Habit habit) {
    setState(() {
      habit.isCompleted = !habit.isCompleted;
      if (habit.isCompleted) {
        habit.completedDate = DateTime.now();
        _habitHistory.add(habit);
      }
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

  void _editGoal(Goal goal) {
    final TextEditingController nameController = TextEditingController(text: goal.name);
    DateTime deadline = goal.deadline;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Goal'),
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
              child: const Text('Save'),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    goal.name = nameController.text;
                    goal.deadline = deadline;
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

  void _deleteGoal(Goal goal) {
    setState(() {
      _goals.remove(goal);
    });
  }

  void _toggleGoalCompletion(Goal goal) {
    setState(() {
      goal.isCompleted = !goal.isCompleted;
      if (goal.isCompleted) {
        goal.completedDate = DateTime.now();
        _goalHistory.add(goal);
        _goals.remove(goal);
      }
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

  void _editReflection(Reflection reflection) {
    final TextEditingController contentController = TextEditingController(text: reflection.content);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Reflection'),
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
              child: const Text('Save'),
              onPressed: () {
                if (contentController.text.isNotEmpty) {
                  setState(() {
                    reflection.content = contentController.text;
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

  void _deleteReflection(Reflection reflection) {
    setState(() {
      _reflections.remove(reflection);
    });
  }

  void _showMindfulnessExercises() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mindfulness Exercises'),
          content: const SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  title: Text('Guided Meditation'),
                  subtitle: Text('A 10-minute guided meditation to help you relax and focus.'),
                ),
                ListTile(
                  title: Text('Breathing Exercise'),
                  subtitle: Text('1. Breathe in through your nose\n2. Place your hands on your stomach to feel your belly rise\n3. Breathe out through your mouth for two to three times longer than you inhale\n4. Relax your shoulders and neck'),
                ),
                ListTile(
                  title: Text('Body Scan'),
                  subtitle: Text('A 15-minute body scan to release tension and improve awareness.'),
                ),
              ],
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

  void _navigateToHistoryPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => HistoryPage(_habitHistory, _goalHistory)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Self Care'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _navigateToHistoryPage,
          ),
          IconButton(
            icon: const Icon(Icons.self_improvement),
            onPressed: _showMindfulnessExercises,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/selfcare.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.white54, BlendMode.lighten),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Daily Habits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ..._habits.map((habit) => Card(
                      elevation: 2.0,
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        title: Text(habit.name),
                        leading: Checkbox(
                          value: habit.isCompleted,
                          onChanged: (bool? value) {
                            _toggleHabitCompletion(habit);
                          },
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editHabit(habit),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteHabit(habit),
                            ),
                          ],
                        ),
                      ),
                    )),
                Center(
                  child: ElevatedButton(
                    onPressed: _addHabit,
                    child: const Text('Add Habit'),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Goals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ..._goals.map((goal) => Card(
                      elevation: 2.0,
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        title: Text(goal.name),
                        subtitle: Text('Deadline: ${DateFormat('yMMMd').format(goal.deadline)}'),
                        leading: Checkbox(
                          value: goal.isCompleted,
                          onChanged: (bool? value) {
                            _toggleGoalCompletion(goal);
                          },
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editGoal(goal),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteGoal(goal),
                            ),
                          ],
                        ),
                      ),
                    )),
                Center(
                  child: ElevatedButton(
                    onPressed: _addGoal,
                    child: const Text('Add Goal'),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Reflection Journal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ..._reflections.map((reflection) => Card(
                      elevation: 2.0,
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ExpansionTile(
                        title: Text(DateFormat('yMMMd').format(reflection.date)),
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Text(reflection.content),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editReflection(reflection),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteReflection(reflection),
                              ),
                            ],
                          ),
                        ],
                      ),
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
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  final List<Habit> habitHistory;
  final List<Goal> goalHistory;

  const HistoryPage(this.habitHistory, this.goalHistory, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Habit History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...habitHistory.map((habit) => ListTile(
                    title: Text(habit.name),
                    subtitle: Text('Completed on: ${DateFormat('yMMMd').format(habit.completedDate!)}'),
                  )),
              const SizedBox(height: 20),
              const Text('Goal History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...goalHistory.map((goal) => ListTile(
                    title: Text(goal.name),
                    subtitle: Text('Completed on: ${DateFormat('yMMMd').format(goal.completedDate!)}'),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
