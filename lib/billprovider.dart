import 'package:flutter/foundation.dart';
import 'sort_option.dart';

class Bill {
  String name;
  double amount;
  DateTime dueDate;
  String paymentMethod;
  String billingPortalLink;
  String recurrence;
  bool isPaid;
  DateTime? paymentDate;
  int notificationId;
  String category;

  Bill({
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.paymentMethod,
    required this.billingPortalLink,
    required this.recurrence,
    required this.isPaid,
    this.paymentDate,
    required this.notificationId,
    required this.category,
  });
}

class MyNotification {
  String title;
  String body;
  DateTime dateTime;
  int notificationId;

  MyNotification({
    required this.title,
    required this.body,
    required this.dateTime,
    required this.notificationId,
  });
}

class BillProvider with ChangeNotifier {
  List<Bill> _bills = [];
  List<MyNotification> _notifications = [];

  List<Bill> get bills => _bills;
  List<MyNotification> get notifications => _notifications;

  void addBill(Bill bill) {
    _bills.add(bill);
    notifyListeners();
  }

  void addNotification(MyNotification notification) {
    _notifications.add(notification);
    notifyListeners();
  }

  void removeNotification(MyNotification notification) {
    _notifications.remove(notification);
    notifyListeners();
  }

  void updateBill(Bill bill) {
    final index = _bills.indexWhere((b) => b.notificationId == bill.notificationId);
    if (index != -1) {
      _bills[index] = bill;
      notifyListeners();
    }
  }

  SortOption _sortOption = SortOption.name; // Default sort option

  SortOption get sortOption => _sortOption;

  void updateSortOption(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }
}
