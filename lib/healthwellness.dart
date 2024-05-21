import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HealthAndWellnessPage extends StatefulWidget {
  const HealthAndWellnessPage({super.key});

  @override
  _HealthAndWellnessPageState createState() => _HealthAndWellnessPageState();
}

class _HealthAndWellnessPageState extends State<HealthAndWellnessPage> {
  final List<Map<String, dynamic>> _exerciseLogs = [];
  final List<Map<String, dynamic>> _mealLogs = [];

  void _addExerciseLog() {
    final TextEditingController exerciseController = TextEditingController();
    final TextEditingController durationController = TextEditingController();
    final TextEditingController intensityController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Exercise Log'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: exerciseController,
                      decoration: const InputDecoration(labelText: 'Exercise Type'),
                    ),
                    TextField(
                      controller: durationController,
                      decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: intensityController,
                      decoration: const InputDecoration(labelText: 'Intensity'),
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
                setState(() {
                  _exerciseLogs.add({
                    'exercise': exerciseController.text,
                    'duration': int.parse(durationController.text),
                    'intensity': intensityController.text,
                    'date': DateTime.now(),
                  });
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addMealLog() {
    final TextEditingController mealController = TextEditingController();
    final TextEditingController caloriesController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Meal Log'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: mealController,
                      decoration: const InputDecoration(labelText: 'Meal'),
                    ),
                    TextField(
                      controller: caloriesController,
                      decoration: const InputDecoration(labelText: 'Calories'),
                      keyboardType: TextInputType.number,
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
                setState(() {
                  _mealLogs.add({
                    'meal': mealController.text,
                    'calories': int.parse(caloriesController.text),
                    'date': DateTime.now(),
                  });
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _editExerciseLog(int index) {
    final log = _exerciseLogs[index];
    final TextEditingController exerciseController = TextEditingController(text: log['exercise']);
    final TextEditingController durationController = TextEditingController(text: log['duration'].toString());
    final TextEditingController intensityController = TextEditingController(text: log['intensity']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Exercise Log'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: exerciseController,
                      decoration: const InputDecoration(labelText: 'Exercise Type'),
                    ),
                    TextField(
                      controller: durationController,
                      decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: intensityController,
                      decoration: const InputDecoration(labelText: 'Intensity'),
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
                  _exerciseLogs[index] = {
                    'exercise': exerciseController.text,
                    'duration': int.parse(durationController.text),
                    'intensity': intensityController.text,
                    'date': log['date'],
                  };
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _editMealLog(int index) {
    final log = _mealLogs[index];
    final TextEditingController mealController = TextEditingController(text: log['meal']);
    final TextEditingController caloriesController = TextEditingController(text: log['calories'].toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Meal Log'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: mealController,
                      decoration: const InputDecoration(labelText: 'Meal'),
                    ),
                    TextField(
                      controller: caloriesController,
                      decoration: const InputDecoration(labelText: 'Calories'),
                      keyboardType: TextInputType.number,
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
                  _mealLogs[index] = {
                    'meal': mealController.text,
                    'calories': int.parse(caloriesController.text),
                    'date': log['date'],
                  };
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteExerciseLog(int index) {
    setState(() {
      _exerciseLogs.removeAt(index);
    });
  }

  void _deleteMealLog(int index) {
    setState(() {
      _mealLogs.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health and Wellness'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Exercise Tracker', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ..._exerciseLogs.map((log) {
                int index = _exerciseLogs.indexOf(log);
                return Card(
                  child: ListTile(
                    title: Text('${log['exercise']} - ${log['duration']} mins'),
                    subtitle: Text('Intensity: ${log['intensity']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editExerciseLog(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteExerciseLog(index),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              Center(
                child: ElevatedButton(
                  onPressed: _addExerciseLog,
                  child: const Text('Add Exercise Log'),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Diet and Nutrition', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ..._mealLogs.map((log) {
                int index = _mealLogs.indexOf(log);
                return Card(
                  child: ListTile(
                    title: Text('${log['meal']} - ${log['calories']} kcal'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editMealLog(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteMealLog(index),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              Center(
                child: ElevatedButton(
                  onPressed: _addMealLog,
                  child: const Text('Add Meal Log'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}