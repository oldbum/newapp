import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:new_app/main.dart';
import 'package:timezone/timezone.dart' as tz;

class GroceryItem {
  String name;
  bool isCompleted;
  DateTime? completedAt;
  String category;
  String notes;
  int notificationId;
  int quantity;
  String unit;

  GroceryItem({
    required this.name,
    this.isCompleted = false,
    this.completedAt,
    required this.category,
    this.notes = '',
    required this.notificationId,
    this.quantity = 1,
    this.unit = 'pcs',
  });
}

class GroceryPage extends StatefulWidget {
  const GroceryPage({super.key, required List initialItems});

  @override
  _GroceryPageState createState() => _GroceryPageState();
}

class _GroceryPageState extends State<GroceryPage> {
  final List<GroceryItem> _items = [];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  String _filterCategory = 'All';
  String _sortOption = 'None';

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _requestPermissions();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _requestPermissions() async {
    await requestExactAlarmPermission();
  }

  void _addItem() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    final TextEditingController quantityController = TextEditingController(text: '1');
    String selectedCategory = 'Grains';
    String selectedUnit = 'pcs';
    List<String> categories = ['Grains', 'Dairy', 'Meat', 'Vegetables', 'Fruits', 'Snacks', 'Drinks', 'Other'];
    List<String> units = ['pcs', 'lbs', 'oz', 'kg', 'g', 'L', 'mL'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add New Item', style: TextStyle(fontFamily: 'Shadows Into Light')),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Item Name'),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: quantityController,
                            decoration: const InputDecoration(labelText: 'Quantity'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: DropdownButton<String>(
                            value: selectedUnit,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedUnit = newValue!;
                              });
                            },
                            items: units.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: 'Notes'),
                    ),
                    DropdownButton<String>(
                      value: selectedCategory,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue!;
                        });
                      },
                      items: categories.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(fontFamily: 'Shadows Into Light')),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add', style: TextStyle(fontFamily: 'Shadows Into Light')),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
                  final int quantity = int.parse(quantityController.text);
                  final GroceryItem newItem = GroceryItem(
                    name: nameController.text,
                    category: selectedCategory,
                    notes: notesController.text,
                    notificationId: notificationId,
                    quantity: quantity,
                    unit: selectedUnit,
                  );
                  setState(() {
                    _items.add(newItem);
                  });
                  _scheduleNotification(newItem);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _editItem(GroceryItem item) {
    final TextEditingController nameController = TextEditingController(text: item.name);
    final TextEditingController notesController = TextEditingController(text: item.notes);
    final TextEditingController quantityController = TextEditingController(text: item.quantity.toString());
    String selectedCategory = item.category;
    String selectedUnit = item.unit;
    List<String> categories = ['Grains', 'Dairy', 'Meat', 'Vegetables', 'Fruits', 'Snacks', 'Drinks', 'Other'];
    List<String> units = ['pcs', 'lbs', 'oz', 'kg', 'g', 'L', 'mL'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Edit Item', style: TextStyle(fontFamily: 'Shadows Into Light')),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Item Name'),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: quantityController,
                            decoration: const InputDecoration(labelText: 'Quantity'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: DropdownButton<String>(
                            value: selectedUnit,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedUnit = newValue!;
                              });
                            },
                            items: units.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: 'Notes'),
                    ),
                    DropdownButton<String>(
                      value: selectedCategory,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue!;
                        });
                      },
                      items: categories.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(fontFamily: 'Shadows Into Light')),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Update', style: TextStyle(fontFamily: 'Shadows Into Light')),
              onPressed: () {
                setState(() {
                  item.name = nameController.text;
                  item.quantity = int.parse(quantityController.text);
                  item.unit = selectedUnit;
                  item.notes = notesController.text;
                  item.category = selectedCategory;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _clearList() {
    setState(() {
      _items.clear();
    });
  }

  void _scheduleNotification(GroceryItem item) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)); // Placeholder for the demo

    var androidDetails = const AndroidNotificationDetails(
      'channelId',
      'channelName',
      channelDescription: 'Notification channel for grocery reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    var iOSDetails = const IOSNotificationDetails();
    var platformDetails = NotificationDetails(android: androidDetails, iOS: iOSDetails);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      item.notificationId,
      '${item.name} Reminder',
      'It\'s time to buy: ${item.name}',
      scheduledDate,
      platformDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  void _sortItems() {
    setState(() {
      if (_sortOption == 'Alphabetically') {
        _items.sort((a, b) => a.name.compareTo(b.name));
      } else if (_sortOption == 'By Category') {
        _items.sort((a, b) => a.category.compareTo(b.category));
      } else if (_sortOption == 'By Completion Status') {
        _items.sort((a, b) => a.isCompleted ? 1 : -1);
      }
    });
  }

  void _filterItems() {
    setState(() {
      // Update the state to filter items by selected category
    });
  }

  @override
  Widget build(BuildContext context) {
    List<GroceryItem> filteredItems = _filterCategory == 'All'
        ? _items
        : _items.where((item) => item.category == _filterCategory).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              setState(() {
                _sortOption = result;
                _sortItems();
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'None',
                child: Text('None'),
              ),
              const PopupMenuItem<String>(
                value: 'Alphabetically',
                child: Text('Alphabetically'),
              ),
              const PopupMenuItem<String>(
                value: 'By Category',
                child: Text('By Category'),
              ),
              const PopupMenuItem<String>(
                value: 'By Completion Status',
                child: Text('By Completion Status'),
              ),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: (String result) {
              setState(() {
                _filterCategory = result;
                _filterItems();
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'All',
                child: Text('All'),
              ),
              const PopupMenuItem<String>(
                value: 'Grains',
                child: Text('Grains'),
              ),
              const PopupMenuItem<String>(
                value: 'Dairy',
                child: Text('Dairy'),
              ),
              const PopupMenuItem<String>(
                value: 'Meat',
                child: Text('Meat'),
              ),
              const PopupMenuItem<String>(
                value: 'Vegetables',
                child: Text('Vegetables'),
              ),
              const PopupMenuItem<String>(
                value: 'Fruits',
                child: Text('Fruits'),
              ),
              const PopupMenuItem<String>(
                value: 'Snacks',
                child: Text('Snacks'),
              ),
              const PopupMenuItem<String>(
                value: 'Drinks',
                child: Text('Drinks'),
              ),
              const PopupMenuItem<String>(
                value: 'Other',
                child: Text('Other'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _clearList,
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: filteredItems.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container(
                  padding: const EdgeInsets.only(top: 80.0), // Position "Grocery Shopping" just above the red line
                  child: const Text('Grocery Shopping', style: TextStyle(fontFamily: 'Shadows Into Light', fontSize: 32)),
                );
              }
              return _buildListItem(filteredItems[index - 1], index);
            },
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: NotepadPainter(lineCount: filteredItems.length + 2),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListItem(GroceryItem item, int index) {
    return Container(
      key: ValueKey(item.name),
      padding: const EdgeInsets.only(left: 30.0),
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        child: ListTile(
          leading: Text(
            '$index.',
            style: const TextStyle(fontFamily: 'Shadows Into Light', fontSize: 24, color: Colors.black),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.name} (${item.quantity} ${item.unit})',
                style: const TextStyle(fontFamily: 'Shadows Into Light', fontSize: 20, color: Colors.black),
              ),
              if (item.notes.isNotEmpty)
                Text(
                  item.notes,
                  style: const TextStyle(fontFamily: 'Shadows Into Light', fontSize: 18, color: Colors.black54),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editItem(item),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteItem(index - 1),
              ),
              Checkbox(
                value: item.isCompleted,
                onChanged: (bool? value) {
                  _toggleItemCompletion(item);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleItemCompletion(GroceryItem item) {
    setState(() {
      item.isCompleted = !item.isCompleted;
      item.completedAt = item.isCompleted ? DateTime.now() : null;
    });
  }
}

class NotepadPainter extends CustomPainter {
  final int lineCount;

  NotepadPainter({required this.lineCount});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 2;

    final Paint redLinePaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 3;

    const double lineSpacing = 60.0;
    const double leftMargin = 50.0;

    for (int i = 0; i < lineCount; i++) {
      final double y = lineSpacing * (i + 1);
      canvas.drawLine(Offset(leftMargin, y), Offset(size.width, y), linePaint);
    }

    canvas.drawLine(const Offset(leftMargin, 0), Offset(leftMargin, size.height), redLinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

void main() => runApp(MaterialApp(
  home: const GroceryPage(initialItems: [],),
  theme: ThemeData(
    primarySwatch: Colors.purple,
    fontFamily: 'Shadows Into Light',
  ),
));