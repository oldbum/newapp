import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class PackingItem {
  String name;
  int quantity;
  String category;
  bool isPacked;

  PackingItem({
    required this.name,
    required this.quantity,
    required this.category,
    this.isPacked = false,
  });
}

class ChecklistItem {
  String name;
  bool isChecked;

  ChecklistItem({
    required this.name,
    this.isChecked = false,
  });
}

class TravelPackingPage extends StatefulWidget {
  const TravelPackingPage({super.key});

  @override
  _TravelPackingPageState createState() => _TravelPackingPageState();
}

class _TravelPackingPageState extends State<TravelPackingPage> {
  final TextEditingController _tripNameController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  final List<PackingItem> _packingList = [];
  final List<ChecklistItem> _preTripChecklist = [];
  final List<ChecklistItem> _inTripChecklist = [];
  final List<ChecklistItem> _postTripChecklist = [];
  final List<Map<String, dynamic>> _expenses = [];

  void _addPackingItem() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    String selectedCategory = 'Clothes';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Packing Item'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Item Name'),
                    ),
                    TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                    DropdownButton<String>(
                      value: selectedCategory,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue!;
                        });
                      },
                      items: ['Clothes', 'Toiletries', 'Electronics', 'Documents', 'Other']
                          .map<DropdownMenuItem<String>>((String value) {
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
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                setState(() {
                  _packingList.add(PackingItem(
                    name: nameController.text,
                    quantity: int.parse(quantityController.text),
                    category: selectedCategory,
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

  void _editPackingItem(PackingItem item) {
    final TextEditingController nameController = TextEditingController(text: item.name);
    final TextEditingController quantityController = TextEditingController(text: item.quantity.toString());
    String selectedCategory = item.category;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Packing Item'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Item Name'),
                    ),
                    TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                    DropdownButton<String>(
                      value: selectedCategory,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue!;
                        });
                      },
                      items: ['Clothes', 'Toiletries', 'Electronics', 'Documents', 'Other']
                          .map<DropdownMenuItem<String>>((String value) {
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
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                setState(() {
                  item.name = nameController.text;
                  item.quantity = int.parse(quantityController.text);
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

  void _deletePackingItem(PackingItem item) {
    setState(() {
      _packingList.remove(item);
    });
  }

  void _togglePacked(PackingItem item) {
    setState(() {
      item.isPacked = !item.isPacked;
    });
  }

  void _addChecklistItem(List<ChecklistItem> checklist, String title) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add $title Item'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Item Name'),
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
                  checklist.add(ChecklistItem(name: nameController.text));
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleChecklistItem(ChecklistItem item) {
    setState(() {
      item.isChecked = !item.isChecked;
    });
  }

  void _addExpense() {
    final TextEditingController categoryController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
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
                          dateController.text = DateFormat('yMMMd').format(picked);
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
                  _expenses.add({
                    'category': categoryController.text,
                    'amount': double.parse(amountController.text),
                    'date': selectedDate ?? DateTime.now(),
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

  void _editExpense(Map<String, dynamic> expense) {
    final TextEditingController categoryController = TextEditingController(text: expense['category']);
    final TextEditingController amountController = TextEditingController(text: expense['amount'].toString());
    final TextEditingController dateController = TextEditingController();
    DateTime? selectedDate = expense['date'];

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
                          dateController.text = DateFormat('yMMMd').format(picked);
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
                  expense['category'] = categoryController.text;
                  expense['amount'] = double.parse(amountController.text);
                  expense['date'] = selectedDate ?? DateTime.now();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteExpense(Map<String, dynamic> expense) {
    setState(() {
      _expenses.remove(expense);
    });
  }

  void _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalExpenses = _expenses.fold(0.0, (sum, item) => sum + item['amount']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel & Packing'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Trip Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(
                controller: _tripNameController,
                decoration: const InputDecoration(labelText: 'Trip Name'),
              ),
              TextField(
                controller: _destinationController,
                decoration: const InputDecoration(labelText: 'Destination'),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectStartDate,
                      child: AbsorbPointer(
                        child: TextField(
                          controller: TextEditingController(text: _startDate != null ? DateFormat('yMMMd').format(_startDate!) : ''),
                          decoration: const InputDecoration(labelText: 'Start Date'),
                          readOnly: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectEndDate,
                      child: AbsorbPointer(
                        child: TextField(
                          controller: TextEditingController(text: _endDate != null ? DateFormat('yMMMd').format(_endDate!) : ''),
                          decoration: const InputDecoration(labelText: 'End Date'),
                          readOnly: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 20),
              const Text('Packing List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ..._packingList.map((item) => CheckboxListTile(
                    title: Text('${item.name} (${item.quantity})'),
                    subtitle: Text(item.category),
                    value: item.isPacked,
                    onChanged: (bool? value) {
                      _togglePacked(item);
                    },
                    secondary: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editPackingItem(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deletePackingItem(item),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: _addPackingItem,
                  child: const Text('Add Packing Item'),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Travel Checklist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Text('Pre-trip Checklist', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ..._preTripChecklist.map((item) => CheckboxListTile(
                    title: Text(item.name),
                    value: item.isChecked,
                    onChanged: (bool? value) {
                      _toggleChecklistItem(item);
                    },
                  )),
              Center(
                child: ElevatedButton(
                  onPressed: () => _addChecklistItem(_preTripChecklist, 'Pre-trip'),
                  child: const Text('Add Pre-trip Item'),
                ),
              ),
              const Text('In-trip Checklist', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ..._inTripChecklist.map((item) => CheckboxListTile(
                    title: Text(item.name),
                    value: item.isChecked,
                    onChanged: (bool? value) {
                      _toggleChecklistItem(item);
                    },
                  )),
              Center(
                child: ElevatedButton(
                  onPressed: () => _addChecklistItem(_inTripChecklist, 'In-trip'),
                  child: const Text('Add In-trip Item'),
                ),
              ),
              const Text('Post-trip Checklist', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ..._postTripChecklist.map((item) => CheckboxListTile(
                    title: Text(item.name),
                    value: item.isChecked,
                    onChanged: (bool? value) {
                      _toggleChecklistItem(item);
                    },
                  )),
              Center(
                child: ElevatedButton(
                  onPressed: () => _addChecklistItem(_postTripChecklist, 'Post-trip'),
                  child: const Text('Add Post-trip Item'),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Budget Planner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Total Expenses: \$${totalExpenses.toStringAsFixed(2)}'),
              ..._expenses.map((expense) => ListTile(
                    title: Text(expense['category']),
                    subtitle: Text('Amount: \$${expense['amount'].toStringAsFixed(2)}, Date: ${DateFormat('yMMMd').format(expense['date'])}'),
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