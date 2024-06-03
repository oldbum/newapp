import 'package:flutter/foundation.dart';
import 'grocery_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GroceryProvider with ChangeNotifier {
  List<GroceryItem> _items = [];

  List<GroceryItem> get items => _items;

  GroceryProvider() {
    _loadItems();
  }

  void addItem(GroceryItem item) {
    _items.add(item);
    _saveItems();
    notifyListeners();
  }

  void updateItem(int index, GroceryItem updatedItem) {
    _items[index] = updatedItem;
    _saveItems();
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    _saveItems();
    notifyListeners();
  }

  void clearItems() {
    _items.clear();
    _saveItems();
    notifyListeners();
  }

  void _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> itemsJson = _items.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('groceryItems', itemsJson);
  }

  void _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? itemsJson = prefs.getStringList('groceryItems');
    if (itemsJson != null) {
      _items = itemsJson.map((itemString) {
        final Map<String, dynamic> json = jsonDecode(itemString);
        return GroceryItem.fromJson(json);
      }).toList();
    }
    notifyListeners();
  }
}
