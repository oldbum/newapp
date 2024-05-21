import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';
import 'main.dart'; // Adjust this import based on your project structure

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
class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FinancePageState createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  final List<Bill> _bills = [];
  SortOption _sortOption = SortOption.name;
  double _notificationDays = 3;

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Bill> sortedBills = [..._bills];
    sortedBills.sort((a, b) => _sortBills(a, b, _sortOption));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addBill,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentHistoryPage(
                  paidBills: _bills.where((bill) => bill.isPaid).toList(),
                  sortOption: _sortOption,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationsPage(bills: _bills)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AnalyticsPage(bills: _bills)),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: sortedBills.length,
        itemBuilder: (context, index) => buildBillCard(sortedBills[index]),
      ),
    );
  }

  Widget buildBillCard(Bill bill) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      color: bill.isPaid ? Colors.green[100] : Colors.red[100],
      child: ListTile(
        title: Text('${bill.name} - \$${bill.amount.toStringAsFixed(2)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Due: ${DateFormat('yMMMd').format(bill.dueDate)}'),
            Text('Category: ${bill.category}'), // Display the category
            Text('Payment Method: ${bill.paymentMethod}'),
            InkWell(
              child: Text('Billing Portal: ${bill.billingPortalLink}', style: const TextStyle(color: Colors.blue)),
              onTap: () => _launchURL(bill.billingPortalLink),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(bill.isPaid ? Icons.check_circle : Icons.circle_outlined),
          onPressed: () {
            setState(() {
              bill.isPaid = !bill.isPaid;
              if (bill.isPaid) {
                bill.paymentDate = DateTime.now();
              }
            });
          },
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter and Sort Bills'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Sort by Name'),
                leading: Radio(
                  value: SortOption.name,
                  groupValue: _sortOption,
                  onChanged: (SortOption? value) {
                    if (value != null) {
                      setState(() => _sortOption = value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Amount Ascending'),
                leading: Radio(
                  value: SortOption.amountAscending,
                  groupValue: _sortOption,
                  onChanged: (SortOption? value) {
                    if (value != null) {
                      setState(() => _sortOption = value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Amount Descending'),
                leading: Radio(
                  value: SortOption.amountDescending,
                  groupValue: _sortOption,
                  onChanged: (SortOption? value) {
                    if (value != null) {
                      setState(() => _sortOption = value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Due Date Soonest'),
                leading: Radio(
                  value: SortOption.dueDateSoonest,
                  groupValue: _sortOption,
                  onChanged: (SortOption? value) {
                    if (value != null) {
                      setState(() => _sortOption = value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Due Date Latest'),
                leading: Radio(
                  value: SortOption.dueDateLatest,
                  groupValue: _sortOption,
                  onChanged: (SortOption? value) {
                    if (value != null) {
                      setState(() => _sortOption = value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  int _sortBills(Bill a, Bill b, SortOption option) {
    switch (option) {
      case SortOption.amountAscending:
        return a.amount.compareTo(b.amount);
      case SortOption.amountDescending:
        return b.amount.compareTo(a.amount);
      case SortOption.dueDateSoonest:
        return a.dueDate.compareTo(b.dueDate);
      case SortOption.dueDateLatest:
        return b.dueDate.compareTo(a.dueDate);
      case SortOption.name:
      default:
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    }
  }

  void _addBill() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController paymentMethodController = TextEditingController();
    final TextEditingController billingPortalController = TextEditingController();
    List<String> recurrenceOptions = ['None', 'Weekly', 'Monthly', 'Yearly'];
    String selectedRecurrence = 'None';
    DateTime? dueDate = DateTime.now();
    int? reminderDaysBefore;
    List<String> categories = ['Utilities', 'Services', 'Rent', 'Subscription', 'Other'];
    String selectedCategory = categories.first;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Bill'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Bill Name'),
                    ),
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(labelText: 'Amount'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    TextField(
                      controller: paymentMethodController,
                      decoration: const InputDecoration(labelText: 'Payment Method'),
                    ),
                    TextField(
                      controller: billingPortalController,
                      decoration: const InputDecoration(labelText: 'Billing Portal Link'),
                    ),
                    DropdownButton<String>(
                      value: selectedRecurrence,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedRecurrence = newValue;
                          });
                        }
                      },
                      items: recurrenceOptions.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    DropdownButton<String>(
                      value: selectedCategory,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedCategory = newValue;
                          });
                        }
                      },
                      items: categories.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    ListTile(
                      title: Text('Select Due Date: ${dueDate != null ? DateFormat('yMMMd').format(dueDate!) : 'Not set'}'),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: dueDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != dueDate) {
                          setState(() {
                            dueDate = picked;
                          });
                        }
                      },
                    ),
                    Slider(
                      value: _notificationDays,
                      min: 1,
                      max: 30,
                      divisions: 29,
                      label: '${_notificationDays.round()} days before',
                      onChanged: (double value) {
                        setState(() {
                          _notificationDays = value;
                          reminderDaysBefore = value.toInt();
                        });
                      },
                    ),
                    Text(
                      'Notify me ${_notificationDays.round()} days before due date',
                      style: const TextStyle(fontSize: 16),
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
                final double? amount = double.tryParse(amountController.text);
                if (amount != null && nameController.text.isNotEmpty && paymentMethodController.text.isNotEmpty) {
                  final Bill newBill = Bill(
                    name: nameController.text,
                    amount: amount,
                    dueDate: dueDate!,
                    paymentMethod: paymentMethodController.text,
                    billingPortalLink: billingPortalController.text,
                    recurrence: selectedRecurrence,
                    isPaid: false,
                    notificationId: generateNotificationId(),
                    category: selectedCategory,
                  );
                  setState(() {
                    _bills.add(newBill);
                  });
                  // Schedule a notification if reminder days is set
                  if (reminderDaysBefore != null) {
                    scheduleNotification(newBill, reminderDaysBefore!);
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> scheduleNotification(Bill bill, int daysBefore) async {
    try {
      final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
        bill.dueDate.subtract(Duration(days: daysBefore)), 
        tz.local,
      );

      var androidDetails = const AndroidNotificationDetails(
        'channelId',
        'channelName',
        channelDescription: 'Notification channel for bill reminders',
        importance: Importance.high,
        priority: Priority.high,
      );
      var iOSDetails = const IOSNotificationDetails();
      var platformDetails = NotificationDetails(android: androidDetails, iOS: iOSDetails);
      await FlutterLocalNotificationsPlugin().zonedSchedule(
        bill.notificationId,
        '${bill.name} Reminder',
        'Your bill for ${bill.name} is due in $daysBefore days.',
        scheduledDate,
        platformDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    // ignore: empty_catches
    } catch (e) {
    }
  }
}

class PaymentHistoryPage extends StatelessWidget {
  final List<Bill> paidBills;
  final SortOption sortOption;

  const PaymentHistoryPage({super.key, required this.paidBills, required this.sortOption});

  @override
  Widget build(BuildContext context) {
    List<Bill> sortedBills = [...paidBills];
    sortedBills.sort((a, b) => _sortBills(a, b, sortOption));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: sortedBills.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(sortedBills[index].name),
          subtitle: Text('Paid: \$${sortedBills[index].amount.toStringAsFixed(2)} on ${DateFormat('yMMMd').format(sortedBills[index].paymentDate!)}'),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sort Payments'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRadioListTile(context, 'Sort by Name', SortOption.name),
              _buildRadioListTile(context, 'Amount Ascending', SortOption.amountAscending),
              _buildRadioListTile(context, 'Amount Descending', SortOption.amountDescending),
              _buildRadioListTile(context, 'Due Date Soonest', SortOption.dueDateSoonest),
              _buildRadioListTile(context, 'Due Date Latest', SortOption.dueDateLatest),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRadioListTile(BuildContext context, String title, SortOption value) {
    return RadioListTile<SortOption>(
      title: Text(title),
      value: value,
      groupValue: sortOption,
      onChanged: (SortOption? value) {
        if (value != null) {
          Navigator.pop(context);
          // Handle state update in the parent or use a callback to update and rebuild with new sort option
        }
      },
    );
  }

  int _sortBills(Bill a, Bill b, SortOption option) {
    switch (option) {
      case SortOption.amountAscending:
        return a.amount.compareTo(b.amount);
      case SortOption.amountDescending:
        return b.amount.compareTo(a.amount);
      case SortOption.dueDateSoonest:
        return a.dueDate.compareTo(b.dueDate);
      case SortOption.dueDateLatest:
        return b.dueDate.compareTo(a.dueDate);
      case SortOption.name:
      default:
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    }
  }
}



// Notification Management Page
class NotificationsPage extends StatelessWidget {
  final List<Bill> bills;

  const NotificationsPage({super.key, required this.bills});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Notifications'),
      ),
      body: ListView.builder(
        itemCount: bills.length,
        itemBuilder: (context, index) {
          final bill = bills[index];
          return Card(
            child: ListTile(
              title: Text('${bill.name} - \$${bill.amount.toStringAsFixed(2)}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Due: ${DateFormat('yMMMd').format(bill.dueDate)}'),
                  Text('Payment Method: ${bill.paymentMethod}'),
                  Text('Notification: ${bill.notificationId}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // Add your edit functionality here
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // Add your delete functionality here
                      FlutterLocalNotificationsPlugin().cancel(bill.notificationId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Notification for ${bill.name} deleted')),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AnalyticsPage extends StatelessWidget {
  final List<Bill> bills;

  const AnalyticsPage({super.key, required this.bills});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> monthlyExpenses = {};
    final Map<String, double> categoryExpenses = {};

    for (var bill in bills) {
      final month = DateFormat('MMM yyyy').format(bill.dueDate);
      monthlyExpenses[month] = (monthlyExpenses[month] ?? 0) + bill.amount;

      categoryExpenses[bill.category] = (categoryExpenses[bill.category] ?? 0) + bill.amount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Expenses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...monthlyExpenses.entries.map((entry) => ListTile(
              title: Text(entry.key),
              trailing: Text('\$${entry.value.toStringAsFixed(2)}'),
            )),
            const Divider(),
            const Text(
              'Category Expenses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...categoryExpenses.entries.map((entry) => ListTile(
              title: Text(entry.key),
              trailing: Text('\$${entry.value.toStringAsFixed(2)}'),
            )),
          ],
        ),
      ),
    );
  }
}
enum SortOption {
  name,
  amountAscending,
  amountDescending,
  dueDateSoonest,
  dueDateLatest,
}