import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'customer.dart';
import 'previousorders.dart';

class Track extends StatefulWidget {
  const Track({super.key});

  @override
  State<Track> createState() => _TrackState();
}

class _TrackState extends State<Track> {
  int _currentIndex = 2; // Setting initial index for Track page

  // Method to fetch bookings for the logged-in user with specific statuses
  Stream<QuerySnapshot> _fetchBookings() {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email;

    return FirebaseFirestore.instance
        .collection('bookings')
        .where('customerEmail', isEqualTo: userEmail)
        .where('status', whereIn: ['requested', 'assigned'])
        .snapshots();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Customer()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PreviousOrders()),
      );
    } else if (index == 2) {
      // Already on Track page, so no navigation needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Track Booking"),
        backgroundColor: const Color.fromARGB(255, 243, 173, 103),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No bookings to track."));
          }

          return SingleChildScrollView(
            child: Column(
              children: snapshot.data!.docs.map((doc) {
                Map<String, dynamic> booking = doc.data() as Map<String, dynamic>;
                String serviceType = booking['serviceType'] ?? 'Service';
                String status = booking['status'] ?? 'Status';
                Timestamp timestamp = booking['timestamp'] ?? Timestamp.now();

                String? serviceProviderEmail = booking['serviceProviderEmail'];
                String? providerPhone = booking['providerPhone'];

                List<Step> steps = [
                  Step(
                    title: const Text("Requested"),
                    content: Text("Booking made on ${timestamp.toDate()}"),
                    isActive: true,
                  ),
                ];

                if (status == 'assigned') {
                  steps.add(
                    Step(
                      title: const Text("Assigned"),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Your booking has been assigned."),
                          if (serviceProviderEmail != null)
                            Text("Provider Email: $serviceProviderEmail"),
                          if (providerPhone != null)
                            Text("Provider Phone: $providerPhone"),
                        ],
                      ),
                      isActive: true,
                    ),
                  );
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceType,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Stepper(
                          physics: const ClampingScrollPhysics(), // Allow scroll within stepper
                          currentStep: status == 'requested' ? 0 : 1,
                          steps: steps,
                          controlsBuilder: (BuildContext context, ControlsDetails details) {
                            return const SizedBox.shrink(); // Hide control buttons
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 243, 173, 103),
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Previous Bookings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: "Track Booking",
          ),
        ],
      ),
    );
  }
}
