import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:new_app/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'billprovider.dart';
import 'sort_option.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  _FinancePageState createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
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
    final billProvider = Provider.of<BillProvider>(context);
    final now = DateTime.now();
    List<Bill> sortedBills = [...billProvider.bills];
    sortedBills.sort((a, b) => _sortBills(a, b, billProvider.sortOption));

    List<Bill> upcomingBills = sortedBills.where((bill) => !bill.isPaid && bill.dueDate.isAfter(now) && bill.dueDate.month == now.month).toList();
    List<Bill> nextMonthBills = sortedBills.where((bill) => !bill.isPaid && bill.dueDate.isAfter(now) && bill.dueDate.month == now.month + 1).toList();
    List<Bill> pastDueBills = sortedBills.where((bill) => !bill.isPaid && bill.dueDate.isBefore(now)).toList();
    List<Bill> paidBills = sortedBills.where((bill) => bill.isPaid).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance', style: TextStyle(fontFamily: 'Montserrat')),
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
                  paidBills: paidBills,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(billProvider),
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AnalyticsPage(bills: billProvider.bills)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Budget Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
            ),
            const SizedBox(height: 20),
            _buildBudgetChart(billProvider.bills),
            const SizedBox(height: 20),
            const Text(
              'Upcoming Bills',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: upcomingBills.length,
                itemBuilder: (context, index) => buildBillCard(upcomingBills[index]),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Past Due Bills',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: pastDueBills.length,
                itemBuilder: (context, index) => buildBillCard(pastDueBills[index]),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Next Month Bills',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: nextMonthBills.length,
                itemBuilder: (context, index) => buildBillCard(nextMonthBills[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBillCard(Bill bill) {
    IconData icon;
    Color color;

    switch (bill.category) {
      case 'Utilities':
        icon = Icons.lightbulb;
        color = Colors.blue;
        break;
      case 'Services':
        icon = Icons.build;
        color = Colors.orange;
        break;
      case 'Rent':
        icon = Icons.home;
        color = Colors.green;
        break;
      case 'Subscription':
        icon = Icons.subscriptions;
        color = Colors.purple;
        break;
      case 'Other':
      default:
        icon = Icons.attach_money;
        color = Colors.grey;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          '${bill.name} - \$${bill.amount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Due: ${DateFormat('yMMMd').format(bill.dueDate)}'),
            Text('Category: ${bill.category}'),
            Text('Payment Method: ${bill.paymentMethod}'),
            InkWell(
              child: Text('Billing Portal: ${bill.billingPortalLink}', style: const TextStyle(color: Colors.blue)),
              onTap: () => _launchURL(bill.billingPortalLink),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(bill.isPaid ? Icons.check_circle : Icons.circle_outlined),
          color: bill.isPaid ? Colors.green : Colors.red,
          onPressed: () {
            setState(() {
              bill.isPaid = !bill.isPaid;
              if (bill.isPaid) {
                bill.paymentDate = DateTime.now();
                // Move bill to payment history
                final billProvider = Provider.of<BillProvider>(context, listen: false);
                billProvider.updateBill(bill);
                // Create a new bill for next month if recurrence is monthly
                if (bill.recurrence == 'Monthly') {
                  _createNextMonthBill(bill);
                }
              }
            });
          },
        ),
      ),
    );
  }

  void _createNextMonthBill(Bill bill) {
    final nextMonthDueDate = DateTime(bill.dueDate.year, bill.dueDate.month + 1, bill.dueDate.day);
    final newBill = Bill(
      name: bill.name,
      amount: bill.amount,
      dueDate: nextMonthDueDate,
      paymentMethod: bill.paymentMethod,
      billingPortalLink: bill.billingPortalLink,
      recurrence: bill.recurrence,
      notificationId: generateNotificationId(),
      category: bill.category,
    );
    final billProvider = Provider.of<BillProvider>(context, listen: false);
    billProvider.addBill(newBill);
  }

  Widget _buildBudgetChart(List<Bill> bills) {
    Map<String, double> categoryExpenses = {};

    for (var bill in bills) {
      if (categoryExpenses.containsKey(bill.category)) {
        categoryExpenses[bill.category] = categoryExpenses[bill.category]! + bill.amount;
      } else {
        categoryExpenses[bill.category] = bill.amount;
      }
    }

    List<PieChartSectionData> sections = categoryExpenses.entries.map((entry) {
      Color color;

      switch (entry.key) {
        case 'Utilities':
          color = Colors.blue;
          break;
        case 'Services':
          color = Colors.orange;
          break;
        case 'Rent':
          color = Colors.green;
          break;
        case 'Subscription':
          color = Colors.purple;
          break;
        case 'Other':
        default:
          color = Colors.grey;
          break;
      }

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${entry.key} - \$${entry.value.toStringAsFixed(2)}',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Text(
                'Spending by Category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(BillProvider billProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter and Sort Bills', style: TextStyle(fontFamily: 'Montserrat')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Sort by Name', style: TextStyle(fontFamily: 'Montserrat')),
                leading: Radio<SortOption>(
                  value: SortOption.name,
                  groupValue: billProvider.sortOption,
                  onChanged: (SortOption? value) {
                    if (value != null) {
                      billProvider.setSortOption(value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Amount Ascending', style: TextStyle(fontFamily: 'Montserrat')),
                leading: Radio<SortOption>(
                  value: SortOption.amountAscending,
                  groupValue: billProvider.sortOption,
                  onChanged: (SortOption? value) {
                    if (value != null) {
                      billProvider.setSortOption(value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Amount Descending', style: TextStyle(fontFamily: 'Montserrat')),
                leading: Radio<SortOption>(
                  value: SortOption.amountDescending,
                  groupValue: billProvider.sortOption,
                  onChanged: (SortOption? value) {
                    if (value != null) {
                      billProvider.setSortOption(value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Due Date Soonest', style: TextStyle(fontFamily: 'Montserrat')),
                leading: Radio<SortOption>(
                  value: SortOption.dueDateSoonest,
                  groupValue: billProvider.sortOption,
                  onChanged: (SortOption? value) {
                    if (value != null) {
                      billProvider.setSortOption(value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Due Date Latest', style: TextStyle(fontFamily: 'Montserrat')),
                leading: Radio<SortOption>(
                  value: SortOption.dueDateLatest,
                  groupValue: billProvider.sortOption,
                  onChanged: (SortOption? value) {
                    if (value != null) {
                      billProvider.setSortOption(value);
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
              child: const Text('Close', style: TextStyle(fontFamily: 'Montserrat')),
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
    List<String> categories = ['Utilities', 'Services', 'Rent', 'Subscription', 'Other'];
    String selectedCategory = categories.first;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Bill', style: TextStyle(fontFamily: 'Montserrat')),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
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
                        setState(() {
                          selectedRecurrence = newValue!;
                        });
                      },
                      items: recurrenceOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    DropdownButton<String>(
                      value: selectedCategory,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue!;
                        });
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
                        });
                      },
                    ),
                    Text(
                      'Notify me ${_notificationDays.round()} days before due date',
                      style: const TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(fontFamily: 'Montserrat')),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add', style: TextStyle(fontFamily: 'Montserrat')),
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
                  final billProvider = Provider.of<BillProvider>(context, listen: false);
                  billProvider.addBill(newBill);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class PaymentHistoryPage extends StatelessWidget {
  final List<Bill> paidBills;

  const PaymentHistoryPage({super.key, required this.paidBills});

  @override
  Widget build(BuildContext context) {
    List<Bill> sortedBills = [...paidBills];
    sortedBills.sort((a, b) => _sortBills(a, b, SortOption.dueDateLatest));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History', style: TextStyle(fontFamily: 'Montserrat')),
      ),
      body: ListView.builder(
        itemCount: sortedBills.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(sortedBills[index].name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Paid: \$${sortedBills[index].amount.toStringAsFixed(2)} on ${DateFormat('yMMMd').format(sortedBills[index].paymentDate!)}'),
              Text('Original Due Date: ${DateFormat('yMMMd').format(sortedBills[index].dueDate)}'),
            ],
          ),
        ),
      ),
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

class AnalyticsPage extends StatelessWidget {
  final List<Bill> bills;

  const AnalyticsPage({super.key, required this.bills});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> monthlyExpenses = {};
    final Map<String, Map<String, double>> categorizedMonthlyExpenses = {};

    for (var bill in bills) {
      final month = DateFormat('MMM yyyy').format(bill.dueDate);
      monthlyExpenses[month] = (monthlyExpenses[month] ?? 0) + bill.amount;

      if (!categorizedMonthlyExpenses.containsKey(month)) {
        categorizedMonthlyExpenses[month] = {};
      }

      categorizedMonthlyExpenses[month]![bill.category] = (categorizedMonthlyExpenses[month]![bill.category] ?? 0) + bill.amount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics', style: TextStyle(fontFamily: 'Montserrat')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Expenses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
            ),
            ...monthlyExpenses.entries.map((entry) => ListTile(
              title: Text(entry.key),
              trailing: Text('\$${entry.value.toStringAsFixed(2)}'),
            )),
            const Divider(),
            const Text(
              'Categorized Monthly Expenses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
            ),
            ...categorizedMonthlyExpenses.entries.expand((entry) {
              return [
                ListTile(
                  title: Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ...entry.value.entries.map((categoryEntry) => ListTile(
                  title: Text(categoryEntry.key),
                  trailing: Text('\$${categoryEntry.value.toStringAsFixed(2)}'),
                )),
              ];
            }).toList(),
          ],
        ),
      ),
    );
  }
}
