import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:reorderables/reorderables.dart';

class GroceryItem {
  String name;
  String category;
  bool isChecked;

  GroceryItem({required this.name, required this.category, this.isChecked = false});
}

class GroceryShoppingPage extends StatefulWidget {
  final List<GroceryItem> initialItems;

  const GroceryShoppingPage({super.key, required this.initialItems});

  @override
  _GroceryShoppingPageState createState() => _GroceryShoppingPageState();
}

class _GroceryShoppingPageState extends State<GroceryShoppingPage> {
  final List<GroceryItem> _groceryList = [];

  @override
  void initState() {
    super.initState();
    _groceryList.addAll(widget.initialItems);
  }

  void _addGroceryItem(GroceryItem item) {
    setState(() {
      _groceryList.add(item);
    });
  }

  void _editGroceryItem(GroceryItem item) {
    final TextEditingController nameController = TextEditingController(text: item.name);
    String selectedCategory = item.category;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Item'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Item Name'),
                  ),
                  DropdownButton<String>(
                    value: selectedCategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                    },
                    items: <String>['Grains', 'Vegetables', 'Fruits', 'Dairy', 'Meat', 'Snacks', 'Beverages']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
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

  void _deleteGroceryItem(GroceryItem item) {
    setState(() {
      _groceryList.remove(item);
    });
  }

  void _newTrip() {
    setState(() {
      _groceryList.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery Shopping'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _newTrip,
          ),
        ],
      ),
      body: ReorderableWrap(
        onReorder: this._onReorder,
        spacing: 8.0,
        runSpacing: 4.0,
        padding: const EdgeInsets.all(8),
        children: _groceryList.map((item) => _buildSlidableItem(item)).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final TextEditingController nameController = TextEditingController();
          String selectedCategory = 'Grains';

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Add Grocery Item'),
                content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'Item Name'),
                        ),
                        DropdownButton<String>(
                          value: selectedCategory,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCategory = newValue!;
                            });
                          },
                          items: <String>['Grains', 'Vegetables', 'Fruits', 'Dairy', 'Meat', 'Snacks', 'Beverages']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
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
                      final GroceryItem newItem = GroceryItem(
                        name: nameController.text,
                        category: selectedCategory,
                      );
                      _addGroceryItem(newItem);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final GroceryItem movedItem = _groceryList.removeAt(oldIndex);
      _groceryList.insert(newIndex, movedItem);
    });
  }

  Widget _buildSlidableItem(GroceryItem item) {
    Color getCategoryColor(String category) {
      switch (category) {
        case 'Vegetables':
          return Colors.green[100]!;
        case 'Fruits':
          return Colors.red[100]!;
        case 'Dairy':
          return Colors.blue[100]!;
        case 'Meat':
          return Colors.brown[100]!;
        case 'Snacks':
          return Colors.orange[100]!;
        case 'Beverages':
          return Colors.purple[100]!;
        default:
          return Colors.grey[200]!;
      }
    }

    return Slidable(
      key: ValueKey(item),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _editGroceryItem(item),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) => _deleteGroceryItem(item),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Container(
        color: getCategoryColor(item.category),
        child: ListTile(
          title: Text(item.name),
          subtitle: Text(item.category),
          trailing: Checkbox(
            value: item.isChecked,
            onChanged: (bool? value) {
              setState(() {
                item.isChecked = value!;
              });
            },
          ),
        ),
      ),
    );
  }
}
