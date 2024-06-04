import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'event.dart'; // Make sure you have this import for Event class

class EventDetailsPage extends StatefulWidget {
  final Event event;
  final Function(Event) onSave;

  const EventDetailsPage({Key? key, required this.event, required this.onSave}) : super(key: key);

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  late TextEditingController _eventNameController;
  late TextEditingController _locationController;
  late TextEditingController _notesController;
  DateTime? _eventDate;

  @override
  void initState() {
    super.initState();
    _eventNameController = TextEditingController(text: widget.event.name);
    _locationController = TextEditingController(text: widget.event.location);
    _notesController = TextEditingController(text: widget.event.notes);
    _eventDate = widget.event.date;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              final updatedEvent = Event(
                name: _eventNameController.text,
                location: _locationController.text,
                date: _eventDate,
                notes: _notesController.text,
                guests: widget.event.guests,
                tasks: widget.event.tasks,
                expenses: widget.event.expenses,
              );
              widget.onSave(updatedEvent);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/eventbackground.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
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
                  ...widget.event.guests.map((guest) => CheckboxListTile(
                        title: Text(guest.name),
                        value: guest.isAttending,
                        onChanged: (bool? value) {
                          setState(() {
                            guest.isAttending = value!;
                          });
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
                  Center(
                    child: ElevatedButton(
                      onPressed: _addGuest,
                      child: const Text('Add Guest'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Task List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ...widget.event.tasks.map((task) => CheckboxListTile(
                        title: Text(task.name),
                        value: task.isCompleted,
                        onChanged: (bool? value) {
                          setState(() {
                            task.isCompleted = value!;
                          });
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
                  Center(
                    child: ElevatedButton(
                      onPressed: _addTask,
                      child: const Text('Add Task'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Budget Planner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Total Expenses: \$${widget.event.expenses.fold(0.0, (sum, item) => (sum as double) + (item.amount as double)).toStringAsFixed(2)}'),
                  ...widget.event.expenses.map((expense) => ListTile(
                        title: Text(expense.category),
                        subtitle: Text('Amount: \$${(expense.amount as double).toStringAsFixed(2)}, Date: ${DateFormat('yMMMd').format(expense.date)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                final TextEditingController categoryController = TextEditingController(text: expense.category);
                                final TextEditingController amountController = TextEditingController(text: (expense.amount as double).toString());

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
                                            });
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  widget.event.expenses.remove(expense);
                                });
                              },
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
        ],
      ),
    );
  }

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
                  widget.event.guests.add(Guest(name: nameController.text));
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
      widget.event.guests.remove(guest);
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
                  widget.event.tasks.add(EventTask(name: taskController.text));
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
      widget.event.tasks.remove(task);
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
                  widget.event.expenses.add(EventExpense(
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
      widget.event.expenses.remove(expense);
    });
  }
}
