import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class HealthAndWellnessPage extends StatefulWidget {
  const HealthAndWellnessPage({super.key});

  @override
  HealthAndWellnessPageState createState() => HealthAndWellnessPageState();
}

class HealthAndWellnessPageState extends State<HealthAndWellnessPage> {
  final List<Map<String, dynamic>> _exerciseLogs = [];
  final List<Map<String, dynamic>> _mealLogs = [];
  final List<Map<String, dynamic>> _prescriptionLogs = [];
  final Map<String, List<Map<String, dynamic>>> _history = {};

  void _addPrescription() {
    final TextEditingController prescriptionController = TextEditingController();
    final TextEditingController dosageController = TextEditingController();
    final TextEditingController timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Prescription'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: prescriptionController,
                      decoration: const InputDecoration(labelText: 'Prescription Name'),
                    ),
                    TextField(
                      controller: dosageController,
                      decoration: const InputDecoration(labelText: 'Dosage'),
                    ),
                    TextField(
                      controller: timeController,
                      decoration: const InputDecoration(labelText: 'Time'),
                      keyboardType: TextInputType.datetime,
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
                  _prescriptionLogs.add({
                    'name': prescriptionController.text,
                    'dosage': dosageController.text,
                    'time': timeController.text,
                    'taken': false,
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

  void _logPrescription(int index) {
    setState(() {
      final now = DateTime.now();
      final date = DateFormat('yMMMd').format(now);
      if (!_history.containsKey(date)) {
        _history[date] = [];
      }
      _history[date]!.add({
        'type': 'prescription',
        'name': _prescriptionLogs[index]['name'],
        'dosage': _prescriptionLogs[index]['dosage'],
        'time': DateFormat('HH:mm').format(now),
      });
      _prescriptionLogs[index]['taken'] = !_prescriptionLogs[index]['taken'];
    });
  }

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
                  final now = DateTime.now();
                  final date = DateFormat('yMMMd').format(now);
                  _exerciseLogs.add({
                    'exercise': exerciseController.text,
                    'duration': int.parse(durationController.text),
                    'intensity': intensityController.text,
                    'date': now,
                  });
                  if (!_history.containsKey(date)) {
                    _history[date] = [];
                  }
                  _history[date]!.add({
                    'type': 'exercise',
                    'exercise': exerciseController.text,
                    'duration': int.parse(durationController.text),
                    'intensity': intensityController.text,
                    'time': DateFormat('HH:mm').format(now),
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

  void _deleteExerciseLog(int index) {
    setState(() {
      _exerciseLogs.removeAt(index);
    });
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
                  final now = DateTime.now();
                  final date = DateFormat('yMMMd').format(now);
                  _mealLogs.add({
                    'meal': mealController.text,
                    'calories': int.parse(caloriesController.text),
                    'date': now,
                  });
                  if (!_history.containsKey(date)) {
                    _history[date] = [];
                  }
                  _history[date]!.add({
                    'type': 'meal',
                    'meal': mealController.text,
                    'calories': int.parse(caloriesController.text),
                    'time': DateFormat('HH:mm').format(now),
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

  void _deleteMealLog(int index) {
    setState(() {
      _mealLogs.removeAt(index);
    });
  }

  Widget _buildBarChart(List<Map<String, dynamic>> logs, String id, String domainField, String measureField) {
    if (logs.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < logs.length; i++) {
      spots.add(FlSpot(i.toDouble(), (logs[i][measureField] ?? 0).toDouble()));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: const Color(0xff37434d),
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                final date = logs[value.toInt()]['date'];
                return Text(DateFormat('E').format(date));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xff4af699),
            barWidth: 4,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalExercise = _exerciseLogs.fold<int>(0, (sum, log) => sum + (log['duration'] as int? ?? 0));
    final totalCalories = _mealLogs.fold<int>(0, (sum, log) => sum + (log['calories'] as int? ?? 0));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health and Wellness'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryPage(history: _history)),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Card(
                elevation: 2.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Weekly Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text('Total Exercise Duration: $totalExercise mins'),
                      Text('Total Calories Consumed: $totalCalories kcal'),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 200,
                        child: _buildBarChart(_exerciseLogs, 'Exercise', 'date', 'duration'),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 200,
                        child: _buildBarChart(_mealLogs, 'Calories', 'date', 'calories'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 2.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Prescription Tracker', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ..._prescriptionLogs.map((log) {
                        int index = _prescriptionLogs.indexOf(log);
                        return Card(
                          child: ListTile(
                            title: Text(log['name']),
                            subtitle: Text('Dosage: ${log['dosage']} at ${log['time']}'),
                            trailing: Checkbox(
                              value: log['taken'],
                              onChanged: (_) => _logPrescription(index),
                            ),
                          ),
                        );
                      }).toList(),
                      Center(
                        child: ElevatedButton(
                          onPressed: _addPrescription,
                          child: const Text('Add Prescription'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 2.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 2.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
            ],
          ),
        ),
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> history;

  const HistoryPage({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: ListView(
        children: history.entries.map((entry) {
          return ExpansionTile(
            title: Text(entry.key),
            children: entry.value.map((log) {
              return ListTile(
                title: Text(log['type'] == 'exercise'
                    ? '${log['exercise']} - ${log['duration']} mins'
                    : log['type'] == 'meal'
                        ? '${log['meal']} - ${log['calories']} kcal'
                        : '${log['name']} - ${log['dosage']}'),
                subtitle: Text('Time: ${log['time']}'),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}