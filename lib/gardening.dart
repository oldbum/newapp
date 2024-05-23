import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;

class Plant {
  String name;
  String species;
  DateTime plantingDate;
  DateTime? lastWateredDate;
  String notes;
  int notificationId;

  Plant({
    required this.name,
    required this.species,
    required this.plantingDate,
    this.lastWateredDate,
    this.notes = '',
    required this.notificationId,
  });
}

class GardeningPage extends StatefulWidget {
  const GardeningPage({super.key});

  @override
  _GardeningPageState createState() => _GardeningPageState();
}

class _GardeningPageState extends State<GardeningPage> {
  final List<Plant> _plants = [];
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

  void _addPlant() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController speciesController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    DateTime plantingDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Plant'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Plant Name'),
                    ),
                    TextField(
                      controller: speciesController,
                      decoration: const InputDecoration(labelText: 'Species'),
                    ),
                    ListTile(
                      title: Text('Planting Date: ${DateFormat('yMMMd').format(plantingDate)}'),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: plantingDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != plantingDate) {
                          setState(() {
                            plantingDate = picked;
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
                if (nameController.text.isNotEmpty && speciesController.text.isNotEmpty) {
                  final int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
                  final Plant newPlant = Plant(
                    name: nameController.text,
                    species: speciesController.text,
                    plantingDate: plantingDate,
                    notes: notesController.text,
                    notificationId: notificationId,
                  );
                  setState(() {
                    _plants.add(newPlant);
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

  void _editPlant(Plant plant) {
    final TextEditingController nameController = TextEditingController(text: plant.name);
    final TextEditingController speciesController = TextEditingController(text: plant.species);
    final TextEditingController notesController = TextEditingController(text: plant.notes);
    DateTime plantingDate = plant.plantingDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Plant'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Plant Name'),
                    ),
                    TextField(
                      controller: speciesController,
                      decoration: const InputDecoration(labelText: 'Species'),
                    ),
                    ListTile(
                      title: Text('Planting Date: ${DateFormat('yMMMd').format(plantingDate)}'),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: plantingDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != plantingDate) {
                          setState(() {
                            plantingDate = picked;
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
                  plant.name = nameController.text;
                  plant.species = speciesController.text;
                  plant.plantingDate = plantingDate;
                  plant.notes = notesController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deletePlant(Plant plant) {
    setState(() {
      _plants.remove(plant);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gardening'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addPlant,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _plants.length,
        itemBuilder: (context, index) {
          final plant = _plants[index];
          return Card(
            child: ListTile(
              leading: Icon(
                plant.lastWateredDate != null ? Icons.check_circle : Icons.radio_button_unchecked,
                color: plant.lastWateredDate != null ? Colors.green : Colors.red,
              ),
              title: Text(plant.name),
              subtitle: Text('${plant.species}\nNotes: ${plant.notes}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editPlant(plant),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deletePlant(plant),
                  ),
                ],
              ),
              isThreeLine: true,
              onTap: () {
                setState(() {
                  plant.lastWateredDate = DateTime.now();
                });
              },
            ),
          );
        },
      ),
    );
  }
}