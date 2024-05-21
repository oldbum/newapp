import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Guest {
  String name;
  bool isAttending;

  Guest({
    required this.name,
    this.isAttending = false,
  });
}

class EventTask {
  String name;
  bool isCompleted;

  EventTask({
    required this.name,
    this.isCompleted = false,
  });
}

class EventExpense {
  String category;
  double amount;
  DateTime date;

  EventExpense({
    required this.category,
    required this.amount,
    required this.date,
  });
}

class EventPlanningPage extends StatefulWidget {
  const EventPlanningPage({super.key});

  @override
  _EventPlanningPageState createState() => _EventPlanningPageState();
}

class _EventPlanningPageState extends State<EventPlanningPage> {
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime? _eventDate;

  final List<Guest> _guestList = [];
  final List<EventTask> _taskList = [];
  final List<EventExpense> _expenses = [];

  void _addGuest() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Guest'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Guest Name'),
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
                  _guestList.add(Guest(name: nameController.text));
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _editGuest(Guest guest) {
    final TextEditingController nameController = TextEditingController(text: guest.name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Guest'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Guest Name'),
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
                  guest.name = nameController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteGuest(Guest guest) {
    setState(() {
      _guestList.remove(guest);
    });
  }

  void _toggleAttendance(Guest guest) {
    setState(() {
      guest.isAttending = !guest.isAttending;
    });
  }

  void _addTask() {
    final TextEditingController taskController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: TextField(
            controller: taskController,
            decoration: const InputDecoration(labelText: 'Task Name'),
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
                  _taskList.add(EventTask(name: taskController.text));
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _editTask(EventTask task) {
    final TextEditingController taskController = TextEditingController(text: task.name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: taskController,
            decoration: const InputDecoration(labelText: 'Task Name'),
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
                  task.name = taskController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteTask(EventTask task) {
    setState(() {
      _taskList.remove(task);
    });
  }

  void _toggleTaskCompletion(EventTask task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
  }

  void _addExpense() {
    final TextEditingController categoryController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Expense'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(labelText: 'Amount'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    ListTile(
                      title: Text('Select Date: ${selectedDate != null ? DateFormat('yMMMd').format(selectedDate!) : 'Not set'}'),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
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
                setState(() {
                  _expenses.add(EventExpense(
                    category: categoryController.text,
                    amount: double.parse(amountController.text),
                    date: selectedDate ?? DateTime.now(),
                  ));
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _editExpense(EventExpense expense) {
    final TextEditingController categoryController = TextEditingController(text: expense.category);
    final TextEditingController amountController = TextEditingController(text: expense.amount.toString());
    DateTime? selectedDate = expense.date;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Expense'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(labelText: 'Amount'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    ListTile(
                      title: Text('Select Date: ${selectedDate != null ? DateFormat('yMMMd').format(selectedDate!) : 'Not set'}'),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
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
              child: const Text('Update'),
              onPressed: () {
                setState(() {
                  expense.category = categoryController.text;
                  expense.amount = double.parse(amountController.text);
                  expense.date = selectedDate ?? DateTime.now();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteExpense(EventExpense expense) {
    setState(() {
      _expenses.remove(expense);
    });
  }

  void _selectEventDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _eventDate) {
      setState(() {
        _eventDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalExpenses = _expenses.fold(0.0, (sum, item) => sum + item.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Planning'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Event Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(
                controller: _eventNameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
              ),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              GestureDetector(
                onTap: _selectEventDate,
                child: AbsorbPointer(
                  child: TextField(
                    controller: TextEditingController(text: _eventDate != null ? DateFormat('yMMMd').format(_eventDate!) : ''),
                    decoration: const InputDecoration(labelText: 'Event Date'),
                    readOnly: true,
                  ),
                ),
              ),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 20),
              const Text('Guest List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ..._guestList.map((guest) => CheckboxListTile(
                    title: Text(guest.name),
                    value: guest.isAttending,
                    onChanged: (bool? value) {
                      _toggleAttendance(guest);
                    },
                    secondary: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editGuest(guest),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteGuest(guest),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: _addGuest,
                  child: const Text('Add Guest'),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Task List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ..._taskList.map((task) => CheckboxListTile(
                    title: Text(task.name),
                    value: task.isCompleted,
                    onChanged: (bool? value) {
                      _toggleTaskCompletion(task);
                    },
                    secondary: Row(
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
                  )),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: _addTask,
                  child: const Text('Add Task'),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Budget Planner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Total Expenses: \$${totalExpenses.toStringAsFixed(2)}'),
              ..._expenses.map((expense) => ListTile(
                    title: Text(expense.category),
                    subtitle: Text('Amount: \$${expense.amount.toStringAsFixed(2)}, Date: ${DateFormat('yMMMd').format(expense.date)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editExpense(expense),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteExpense(expense),
                        ),
                      ],
                    ),
                  )),
              Center(
                child: ElevatedButton(
                  onPressed: _addExpense,
                  child: const Text('Add Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}