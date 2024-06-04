import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'trip.dart';
import 'travel_packing_provider.dart';
import 'trip_details_page.dart';

class TravelPackingPage extends StatelessWidget {
  const TravelPackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel & Packing'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/travel_packing_background.png', // Ensure this path matches your asset
                fit: BoxFit.cover,
              ),
            ),
          ),
          Consumer<TravelPackingProvider>(
            builder: (context, provider, child) {
              final trips = provider.trips;

              return trips.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.card_travel,
                            size: 100,
                            color: Colors.purple.withOpacity(0.5),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No Trips Yet!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Tap the + button to add your first trip.',
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
                      itemCount: trips.length,
                      itemBuilder: (context, index) {
                        final trip = trips[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          child: ListTile(
                            title: Text(trip.tripName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Destination: ${trip.destination}'),
                                if (trip.startDate != null)
                                  Text('Start Date: ${DateFormat('yMMMd').format(trip.startDate!)}'),
                                if (trip.endDate != null)
                                  Text('End Date: ${DateFormat('yMMMd').format(trip.endDate!)}'),
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
                                        builder: (context) => TripDetailsPage(
                                          trip: trip,
                                          onSave: (updatedTrip) {
                                            provider.updateTrip(index, updatedTrip);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    provider.deleteTrip(index);
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TripDetailsPage(
                                    trip: trip,
                                    onSave: (updatedTrip) {
                                      provider.updateTrip(index, updatedTrip);
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
      floatingActionButton: Consumer<TravelPackingProvider>(
        builder: (context, provider, child) {
          return FloatingActionButton(
            onPressed: () {
              final newTrip = Trip(
                tripName: '',
                destination: '',
                startDate: null,
                endDate: null,
                notes: '',
                packingList: [],
                preTripChecklist: [],
                inTripChecklist: [],
                postTripChecklist: [],
                expenses: [],
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TripDetailsPage(
                    trip: newTrip,
                    onSave: (trip) {
                      provider.addTrip(trip);
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
