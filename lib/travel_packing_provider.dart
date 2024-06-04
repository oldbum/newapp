import 'package:flutter/material.dart';
import 'trip.dart';

class TravelPackingProvider with ChangeNotifier {
  List<Trip> _trips = [];

  List<Trip> get trips => _trips;

  void addTrip(Trip trip) {
    _trips.add(trip);
    notifyListeners();
  }

  void updateTrip(int index, Trip trip) {
    _trips[index] = trip;
    notifyListeners();
  }

  void deleteTrip(int index) {
    _trips.removeAt(index);
    notifyListeners();
  }
}
