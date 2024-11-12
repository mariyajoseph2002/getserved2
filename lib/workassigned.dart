import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'contracter.dart';

class WorkAssigned extends StatefulWidget {
  const WorkAssigned({Key? key}) : super(key: key);

  @override
  _WorkAssignedState createState() => _WorkAssignedState();
}

class _WorkAssignedState extends State<WorkAssigned> {
  int _selectedIndex = 1;

  // Handle Bottom Navigation Bar item tap
  void _onItemTapped(int index) {
    if (index == 0) {
      // Navigate to the Home page (Contracter) if 'Home' is selected
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Contracter()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('status', isEqualTo: 'assigned') // Only fetch bookings where status is 'assigned'
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("An error occurred. Please try again later."));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No assigned work available"));
          }

          // Display list of assigned bookings in a card format
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final QueryDocumentSnapshot document = doc as QueryDocumentSnapshot;
              Map<String, dynamic> booking = document.data() as Map<String, dynamic>;

              // Format the date if it's a Timestamp
              String formattedDate = 'N/A';
              if (booking['date'] != null && booking['date'] is Timestamp) {
                DateTime dateTime = (booking['date'] as Timestamp).toDate();
                formattedDate = "${dateTime.year}-${dateTime.month}-${dateTime.day}"; // Format as desired
              }

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Booking ID: ${document.id}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text("Customer: ${booking['customerEmail'] ?? 'N/A'}"),
                      Text("Service: ${booking['serviceType'] ?? 'N/A'}"),
                      Text("Service provider: ${booking['serviceProviderEmail'] ?? 'N/A'}"),
                      Text("Date: $formattedDate"),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
     
    );
  }
}
