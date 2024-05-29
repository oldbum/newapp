import 'package:flutter/material.dart';
import 'sort_option.dart';

class Bill {
  String name;
  double amount;
  DateTime dueDate;
  DateTime? paymentDate;
  String paymentMethod;
  bool isPaid;
  String billingPortalLink;
  String recurrence;
  int notificationId;
  String category;

  Bill({
    required this.name,
    required this.amount,
    required this.dueDate,
    this.paymentDate,
    required this.paymentMethod,
    this.isPaid = false,
    required this.billingPortalLink,
    required this.recurrence,
    required this.notificationId,
    required this.category,
  });
}

class BillProvider with ChangeNotifier {
  List<Bill> _bills = [];
  SortOption _sortOption = SortOption.name;

  List<Bill> get bills => _bills;
  SortOption get sortOption => _sortOption;

  void addBill(Bill bill) {
    _bills.add(bill);
    notifyListeners();
  }

  void updateBill(Bill bill) {
    final index = _bills.indexWhere((b) => b.notificationId == bill.notificationId);
    if (index != -1) {
      _bills[index] = bill;
      notifyListeners();
    }
  }

  void removeBill(Bill bill) {
    _bills.remove(bill);
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }
}
