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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _editNotification(context, provider, notification);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    provider.removeNotification(notification);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _editNotification(BuildContext context, BillProvider provider, MyNotification notification) {
    final titleController = TextEditingController(text: notification.title);
    final bodyController = TextEditingController(text: notification.body);
    final dateTimeController = TextEditingController(text: notification.dateTime.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Notification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: bodyController,
                decoration: InputDecoration(labelText: 'Body'),
              ),
              TextField(
                controller: dateTimeController,
                decoration: InputDecoration(labelText: 'DateTime'),
                onTap: () async {
                  DateTime dateTime = DateTime.now();
                  DateTime pickedDate = (await showDatePicker(
                    context: context,
                    initialDate: dateTime,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  ))!;
                  TimeOfDay pickedTime = (await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(dateTime),
                  ))!;
                  DateTime newDateTime = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );
                  dateTimeController.text = newDateTime.toString();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final updatedNotification = MyNotification(
                  title: titleController.text,
                  body: bodyController.text,
                  dateTime: DateTime.parse(dateTimeController.text),
                  notificationId: notification.notificationId,
                );
                provider.updateNotification(notification, updatedNotification);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
