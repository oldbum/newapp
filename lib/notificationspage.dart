import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:new_app/billprovider.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BillProvider>(context);
    final notifications = provider.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontFamily: 'Montserrat')),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            title: Text(notification.title),
            subtitle: Text('${notification.body}\n${notification.dateTime}'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                provider.removeNotification(notification);
              },
            ),
          );
        },
      ),
    );
  }
}
