import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'event.dart';
import 'event_details_page.dart';
import 'event_planning_provider.dart';

class EventPlanningPage extends StatelessWidget {
  const EventPlanningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Planning'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/eventbackground.png', // Ensure this path matches your asset
                fit: BoxFit.cover,
              ),
            ),
          ),
          Consumer<EventPlanningProvider>(
            builder: (context, provider, child) {
              final events = provider.events;

              return events.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event,
                            size: 100,
                            color: Colors.purple.withOpacity(0.5),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No Events Yet!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Tap the + button to add your first event.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black.withOpacity(0.5),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          child: ListTile(
                            title: Text(event.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Location: ${event.location}'),
                                if (event.date != null)
                                  Text('Date: ${DateFormat('yMMMd').format(event.date!)}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EventDetailsPage(
                                          event: event,
                                          onSave: (updatedEvent) {
                                            provider.updateEvent(index, updatedEvent);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    provider.deleteEvent(index);
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventDetailsPage(
                                    event: event,
                                    onSave: (updatedEvent) {
                                      provider.updateEvent(index, updatedEvent);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
            },
          ),
        ],
      ),
      floatingActionButton: Consumer<EventPlanningProvider>(
        builder: (context, provider, child) {
          return FloatingActionButton(
            onPressed: () {
              final newEvent = Event(
                name: '',
                location: '',
                date: null,
                notes: '',
                guests: [],
                tasks: [],
                expenses: [],
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailsPage(
                    event: newEvent,
                    onSave: (event) {
                      provider.addEvent(event);
                    },
                  ),
                ),
              );
            },
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}
