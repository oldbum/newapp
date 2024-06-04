import 'package:flutter/material.dart';
import 'event.dart';

class EventPlanningProvider with ChangeNotifier {
  List<Event> _events = [];

  List<Event> get events => _events;

  void addEvent(Event event) {
    _events.add(event);
    notifyListeners();
  }

  void updateEvent(int index, Event event) {
    _events[index] = event;
    notifyListeners();
  }

  void deleteEvent(int index) {
    _events.removeAt(index);
    notifyListeners();
  }
}
