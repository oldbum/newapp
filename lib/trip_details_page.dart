import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'trip.dart';

class TripDetailsPage extends StatefulWidget {
  final Trip trip;
  final Function(Trip) onSave;

  const TripDetailsPage({super.key, required this.trip, required this.onSave});

  @override
  _TripDetailsPageState createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  late TextEditingController _tripNameController;
  late TextEditingController _destinationController;
  late TextEditingController _notesController;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _tripNameController = TextEditingController(text: widget.trip.tripName);
    _destinationController = TextEditingController(text: widget.trip.destination);
    _notesController = TextEditingController(text: widget.trip.notes);
    _startDate = widget.trip.startDate;
    _endDate = widget.trip.endDate;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              final updatedTrip = Trip(
                tripName: _tripNameController.text,
                destination: _destinationController.text,
                startDate: _startDate,
                endDate: _endDate,
                notes: _notesController.text,
                packingList: widget.trip.packingList,
                preTripChecklist: widget.trip.preTripChecklist,
                inTripChecklist: widget.trip.inTripChecklist,
                postTripChecklist: widget.trip.postTripChecklist,
                expenses: widget.trip.expenses,
              );
              widget.onSave(updatedTrip);
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
                'assets/travel_packing_background.png',
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
                  ...widget.trip.packingList.map((item) => CheckboxListTile(
                        title: Text('${item.name} (${item.quantity})'),
                        subtitle: Text(item.category),
                        value: item.isPacked,
                        onChanged: (bool? value) {
                          setState(() {
                            item.isPacked = value!;
                          });
                        },
                      )),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
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
                                      widget.trip.packingList.add(PackingItem(
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
                      },
                      child: const Text('Add Packing Item'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Travel Checklist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text('Pre-trip Checklist', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ...widget.trip.preTripChecklist.map((item) => CheckboxListTile(
                        title: Text(item.name),
                        value: item.isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            item.isChecked = value!;
                          });
                        },
                      )),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        final TextEditingController nameController = TextEditingController();

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Add Pre-trip Item'),
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
                                      widget.trip.preTripChecklist.add(ChecklistItem(name: nameController.text));
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('Add Pre-trip Item'),
                    ),
                  ),
                  const Text('In-trip Checklist', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ...widget.trip.inTripChecklist.map((item) => CheckboxListTile(
                        title: Text(item.name),
                        value: item.isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            item.isChecked = value!;
                          });
                        },
                      )),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        final TextEditingController nameController = TextEditingController();

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Add In-trip Item'),
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
                                      widget.trip.inTripChecklist.add(ChecklistItem(name: nameController.text));
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('Add In-trip Item'),
                    ),
                  ),
                  const Text('Post-trip Checklist', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ...widget.trip.postTripChecklist.map((item) => CheckboxListTile(
                        title: Text(item.name),
                        value: item.isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            item.isChecked = value!;
                          });
                        },
                      )),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        final TextEditingController nameController = TextEditingController();

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Add Post-trip Item'),
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
                                      widget.trip.postTripChecklist.add(ChecklistItem(name: nameController.text));
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('Add Post-trip Item'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Budget Planner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Total Expenses: \$${widget.trip.expenses.fold(0.0, (sum, item) => (sum as double) + (item['amount'] as double)).toStringAsFixed(2)}'),
                  ...widget.trip.expenses.map((expense) => ListTile(
                        title: Text(expense['category']),
                        subtitle: Text('Amount: \$${(expense['amount'] as double).toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                final TextEditingController categoryController = TextEditingController(text: expense['category']);
                                final TextEditingController amountController = TextEditingController(text: (expense['amount'] as double).toString());

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
                                              expense['category'] = categoryController.text;
                                              expense['amount'] = double.parse(amountController.text);
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
                                  widget.trip.expenses.remove(expense);
                                });
                              },
                            ),
                          ],
                        ),
                      )),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        final TextEditingController categoryController = TextEditingController();
                        final TextEditingController amountController = TextEditingController();

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
                                      widget.trip.expenses.add({
                                        'category': categoryController.text,
                                        'amount': double.parse(amountController.text),
                                      });
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
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
}