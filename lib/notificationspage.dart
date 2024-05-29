import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'billprovider.dart';
import 'sort_option.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final billProvider = Provider.of<BillProvider>(context);
    final bills = billProvider.bills.where((bill) => !bill.isPaid).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Notifications', style: TextStyle(fontFamily: 'Montserrat')),
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
                      FlutterLocalNotificationsPlugin().cancel(bill.notificationId).then((_) {
                        billProvider.removeBill(bill);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Notification for ${bill.name} deleted')),
                        );
                      }).catchError((error) {
                        print("Error deleting notification: $error");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to delete notification for ${bill.name}')),
                        );
                      });
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
