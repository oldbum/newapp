import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _scheduleDailyNotification(int id, String title, String body, Time time) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(time),
      const NotificationDetails(
        android: AndroidNotificationDetails('daily notification channel id', 'daily notification channel name',
            channelDescription: 'daily notification description'),
      ),
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(Time time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute, time.second);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  void _addPrescription() {
    final TextEditingController prescriptionController = TextEditingController();
    final TextEditingController dosageController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

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
                    TextButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (picked != null && picked != selectedTime) {
                          setState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                      child: Text("Select Notification Time: ${selectedTime.format(context)}"),
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
                  final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
                  _prescriptionLogs.add({
                    'name': prescriptionController.text,
                    'dosage': dosageController.text,
                    'time': selectedTime.format(context),
                    'taken': false,
                    'notificationId': notificationId,
                  });

                  _scheduleDailyNotification(
                    notificationId,
                    'Prescription Reminder',
                    'It\'s time to take your ${prescriptionController.text}',
                    Time(selectedTime.hour, selectedTime.minute),
                  );
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _editPrescription(int index) {
    final log = _prescriptionLogs[index];
    final TextEditingController prescriptionController = TextEditingController(text: log['name']);
    final TextEditingController dosageController = TextEditingController(text: log['dosage']);
    TimeOfDay selectedTime = TimeOfDay(
      hour: int.parse(log['time'].split(":")[0]),
      minute: int.parse(log['time'].split(":")[1].split(" ")[0]),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Prescription'),
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
                    TextButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (picked != null && picked != selectedTime) {
                          setState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                      child: Text("Select Notification Time: ${selectedTime.format(context)}"),
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
                  final notificationId = log['notificationId'];

                  _scheduleDailyNotification(
                    notificationId,
                    'Prescription Reminder',
                    'It\'s time to take your ${prescriptionController.text}',
                    Time(selectedTime.hour, selectedTime.minute),
                  );

                  _prescriptionLogs[index] = {
                    'name': prescriptionController.text,
                    'dosage': dosageController.text,
                    'time': selectedTime.format(context),
                    'taken': log['taken'],
                    'notificationId': notificationId,
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

  void _deletePrescription(int index) {
    setState(() {
      final log = _prescriptionLogs[index];
      flutterLocalNotificationsPlugin.cancel(log['notificationId']);
      _prescriptionLogs.removeAt(index);
    });
  }

  void _logPrescription(int index) {
    setState(() {
      final now = DateTime.now();
      final date = DateFormat('yMMMd').format(now);
      final prescription = _prescriptionLogs[index];

      if (prescription['taken']) {
        _history[date]?.removeWhere((log) =>
            log['type'] == 'prescription' && log['name'] == prescription['name'] && log['time'] == prescription['time']);
        prescription['taken'] = false;
      } else {
        if (!_history.containsKey(date)) {
          _history[date] = [];
        }
        _history[date]!.add({
          'type': 'prescription',
          'name': prescription['name'],
          'dosage': prescription['dosage'],
          'time': DateFormat('HH:mm').format(now),
        });
        prescription['taken'] = true;
      }
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
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editPrescription(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deletePrescription(index),
                                ),
                                Checkbox(
                                  value: log['taken'],
                                  onChanged: (bool? value) => _logPrescription(index),
                                ),
                              ],
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
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Prescriptions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              ...entry.value
                  .where((log) => log['type'] == 'prescription')
                  .map((log) => ListTile(
                        title: Text('${log['name']} - ${log['dosage']}'),
                        subtitle: Text('Time: ${log['time']}'),
                      )),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Exercises', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              ...entry.value
                  .where((log) => log['type'] == 'exercise')
                  .map((log) => ListTile(
                        title: Text('${log['exercise']} - ${log['duration']} mins'),
                        subtitle: Text('Intensity: ${log['intensity']}'),
                      )),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Meals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              ...entry.value
                  .where((log) => log['type'] == 'meal')
                  .map((log) => ListTile(
                        title: Text('${log['meal']} - ${log['calories']} kcal'),
                        subtitle: Text('Time: ${log['time']}'),
                      )),
            ],
          );
        }).toList(),
      ),
    );
  }
}