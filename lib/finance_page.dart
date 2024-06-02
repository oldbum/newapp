import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:new_app/billprovider.dart' as bill_provider;
import 'package:new_app/sort_option.dart' as sort_option;

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  _FinancePageState createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<bill_provider.BillProvider>(context);
    final List<bill_provider.Bill> sortedBills = provider.bills;
    final sortOption = provider.sortOption;

    sortedBills.sort((a, b) => _sortBills(a, b, sortOption));

    DateTime now = DateTime.now();
    List<bill_provider.Bill> upcomingBills = sortedBills.where((bill) => !bill.isPaid && bill.dueDate.isAfter(now) && bill.dueDate.month == now.month).toList();
    List<bill_provider.Bill> nextMonthBills = sortedBills.where((bill) => !bill.isPaid && bill.dueDate.isAfter(now) && bill.dueDate.month == now.month + 1).toList();
    List<bill_provider.Bill> pastDueBills = sortedBills.where((bill) => !bill.isPaid && bill.dueDate.isBefore(now)).toList();

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
                  paidBills: provider.bills.where((bill) => bill.isPaid).toList(),
                  sortOption: sortOption,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AnalyticsPage(bills: provider.bills)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Budget Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
            ),
            const SizedBox(height: 20),
            _buildBudgetChart(),
            const SizedBox(height: 20),
            const Text(
              'Upcoming Bills',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
            ),
            const SizedBox(height: 10),
            ...upcomingBills.map((bill) => buildBillCard(bill)).toList(),
            const SizedBox(height: 20),
            const Text(
              'Past Due Bills',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
            ),
            const SizedBox(height: 10),
            ...pastDueBills.map((bill) => buildBillCard(bill)).toList(),
            const SizedBox(height: 20),
            const Text(
              'Next Month Bills',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
            ),
            const SizedBox(height: 10),
            ...nextMonthBills.map((bill) => buildBillCard(bill)).toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildBillCard(bill_provider.Bill bill) {
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
                final provider = Provider.of<bill_provider.BillProvider>(context, listen: false);
                provider.updateBill(bill);
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

  void _createNextMonthBill(bill_provider.Bill bill) {
    final nextMonthDueDate = DateTime(bill.dueDate.year, bill.dueDate.month + 1, bill.dueDate.day);
    final newBill = bill_provider.Bill(
      name: bill.name,
      amount: bill.amount,
      dueDate: nextMonthDueDate,
      paymentMethod: bill.paymentMethod,
      billingPortalLink: bill.billingPortalLink,
      recurrence: bill.recurrence,
      notificationId: generateNotificationId(),
      category: bill.category,
      isPaid: false,
    );
    final provider = Provider.of<bill_provider.BillProvider>(context, listen: false);
    provider.addBill(newBill);
  }

  Widget _buildBudgetChart() {
  final provider = Provider.of<bill_provider.BillProvider>(context);
  Map<String, double> categoryExpenses = {};

  for (var bill in provider.bills) {
    if (categoryExpenses.containsKey(bill.category)) {
      categoryExpenses[bill.category] = categoryExpenses[bill.category]! + bill.amount;
    } else {
      categoryExpenses[bill.category] = bill.amount;
    }
  }

  List<BarChartGroupData> barGroups = [];
  int index = 0;
  categoryExpenses.forEach((category, amount) {
    Color color;

    switch (category) {
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

    barGroups.add(
      BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: amount,
            color: color,
            width: 15,
            borderRadius: BorderRadius.circular(0),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 0,
              color: Colors.grey[200],
            ),
          ),
        ],
        showingTooltipIndicators: [0],
      ),
    );
    index++;
  });

  return AspectRatio(
    aspectRatio: 1.3,
    child: Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Spending by Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,  // Adjusted for better text display
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(
                            color: Color(0xff7589a2),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          );
                          Widget text;
                          switch (value.toInt()) {
                            case 0:
                              text = const Text('Utilities', style: style);
                              break;
                            case 1:
                              text = const Text('Services', style: style);
                              break;
                            case 2:
                              text = const Text('Rent', style: style);
                              break;
                            case 3:
                              text = const Text('Subscription', style: style);
                              break;
                            case 4:
                            default:
                              text = const Text('Other', style: style);
                              break;
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 16.0,
                            child: text,
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,  // Adjusted for better text display
                        interval: 500,  // Adjusted for better scaling
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: const TextStyle(
                              color: Color(0xff7589a2),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipPadding: const EdgeInsets.all(8),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String category;
                        switch (group.x.toInt()) {
                          case 0:
                            category = 'Utilities';
                            break;
                          case 1:
                            category = 'Services';
                            break;
                          case 2:
                            category = 'Rent';
                            break;
                          case 3:
                            category = 'Subscription';
                            break;
                          case 4:
                          default:
                            category = 'Other';
                            break;
                        }
                        return BarTooltipItem(
                          '$category\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: '\$${rod.toY}',
                              style: const TextStyle(
                                color: Colors.yellow,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final provider = Provider.of<bill_provider.BillProvider>(context);
        return AlertDialog(
          title: const Text('Filter and Sort Bills', style: TextStyle(fontFamily: 'Montserrat')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Sort by Name', style: TextStyle(fontFamily: 'Montserrat')),
                leading: Radio(
                  value: sort_option.SortOption.name,
                  groupValue: provider.sortOption,
                  onChanged: (sort_option.SortOption? value) {
                    if (value != null) {
                      provider.updateSortOption(value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Amount Ascending', style: TextStyle(fontFamily: 'Montserrat')),
                leading: Radio(
                  value: sort_option.SortOption.amountAscending,
                  groupValue: provider.sortOption,
                  onChanged: (sort_option.SortOption? value) {
                    if (value != null) {
                      provider.updateSortOption(value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Amount Descending', style: TextStyle(fontFamily: 'Montserrat')),
                leading: Radio(
                  value: sort_option.SortOption.amountDescending,
                  groupValue: provider.sortOption,
                  onChanged: (sort_option.SortOption? value) {
                    if (value != null) {
                      provider.updateSortOption(value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Due Date Soonest', style: TextStyle(fontFamily: 'Montserrat')),
                leading: Radio(
                  value: sort_option.SortOption.dueDateSoonest,
                  groupValue: provider.sortOption,
                  onChanged: (sort_option.SortOption? value) {
                    if (value != null) {
                      provider.updateSortOption(value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Due Date Latest', style: TextStyle(fontFamily: 'Montserrat')),
                leading: Radio(
                  value: sort_option.SortOption.dueDateLatest,
                  groupValue: provider.sortOption,
                  onChanged: (sort_option.SortOption? value) {
                    if (value != null) {
                      provider.updateSortOption(value);
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

  int _sortBills(bill_provider.Bill a, bill_provider.Bill b, sort_option.SortOption option) {
    switch (option) {
      case sort_option.SortOption.amountAscending:
        return a.amount.compareTo(b.amount);
      case sort_option.SortOption.amountDescending:
        return b.amount.compareTo(a.amount);
      case sort_option.SortOption.dueDateSoonest:
        return a.dueDate.compareTo(b.dueDate);
      case sort_option.SortOption.dueDateLatest:
        return b.dueDate.compareTo(a.dueDate);
      case sort_option.SortOption.name:
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
    DateTime? notificationDateTime;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Bill', style: TextStyle(fontFamily: 'Montserrat')),
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
                      title: Text(dueDate == null
                          ? 'Select Due Date'
                          : 'Due Date: ${DateFormat('yMMMd').format(dueDate!)}'),
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: dueDate!,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            dueDate = pickedDate;
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: Text(notificationDateTime == null
                          ? 'Select Notification Time'
                          : 'Notification Time: ${DateFormat('yMMMd').add_jm().format(notificationDateTime!)}'),
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              notificationDateTime = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                            });
                          }
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
              child: const Text('Cancel', style: TextStyle(fontFamily: 'Montserrat')),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add', style: TextStyle(fontFamily: 'Montserrat')),
              onPressed: () {
                final double? amount = double.tryParse(amountController.text);
                if (amount != null && nameController.text.isNotEmpty && paymentMethodController.text.isNotEmpty) {
                  final bill_provider.Bill newBill = bill_provider.Bill(
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
                  final provider = Provider.of<bill_provider.BillProvider>(context, listen: false);
                  provider.addBill(newBill);
                  if (notificationDateTime != null) {
                    _addNotificationToProvider(
                      title: newBill.name,
                      body: 'It\'s time to pay your bill: ${newBill.name}',
                      dateTime: notificationDateTime!,
                      notificationId: newBill.notificationId,
                    );
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

  void _addNotificationToProvider({
    required String title,
    required String body,
    required DateTime dateTime,
    required int notificationId,
  }) {
    final newNotification = bill_provider.MyNotification(
      title: title,
      body: body,
      dateTime: dateTime,
      notificationId: notificationId,
    );
    final provider = Provider.of<bill_provider.BillProvider>(context, listen: false);
    provider.addNotification(newNotification);
  }
}

class PaymentHistoryPage extends StatelessWidget {
  final List<bill_provider.Bill> paidBills;
  final sort_option.SortOption sortOption;

  const PaymentHistoryPage({super.key, required this.paidBills, required this.sortOption});

  @override
  Widget build(BuildContext context) {
    List<bill_provider.Bill> sortedBills = [...paidBills];
    sortedBills.sort((a, b) => _sortBills(a, b, sortOption));

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

  int _sortBills(bill_provider.Bill a, bill_provider.Bill b, sort_option.SortOption option) {
    switch (option) {
      case sort_option.SortOption.amountAscending:
        return a.amount.compareTo(b.amount);
      case sort_option.SortOption.amountDescending:
        return b.amount.compareTo(a.amount);
      case sort_option.SortOption.dueDateSoonest:
        return a.dueDate.compareTo(b.dueDate);
      case sort_option.SortOption.dueDateLatest:
        return b.dueDate.compareTo(a.dueDate);
      case sort_option.SortOption.name:
      default:
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    }
  }
}

class AnalyticsPage extends StatelessWidget {
  final List<bill_provider.Bill> bills;

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

int generateNotificationId() {
  return DateTime.now().millisecondsSinceEpoch.remainder(100000);
}