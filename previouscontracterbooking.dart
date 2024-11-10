import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'contracter.dart'; // Import the customer page
import 'feedback_page.dart'; // Import the Feedback page

class PreviousContracterBooking extends StatefulWidget {
  const PreviousContracterBooking({super.key});

  @override
  _PreviouscontracterbookingState createState() => _PreviouscontracterbookingState();
}

class _PreviouscontracterbookingState extends State<PreviousContracterBooking> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    if (index == 0) {
      // Navigate to the Home (Contractor) page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Contracter()),
      );
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('Email', isEqualTo: user?.email)
          .where('status', isEqualTo: 'done')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No completed bookings available."));
        }

        final orders = snapshot.data!.docs;

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            var order = orders[index];
            DateTime date = (order['date'] as Timestamp).toDate();

            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text('Booking ID: ${order.id}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Provider: ${order['providerEmail']}'),
                    Text('Date: ${date.toLocal()}'.split(' ')[0]), // Displaying only the date
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FeedbackPage(
                          customerEmail: user!.email!,
                          providerEmail: order['providerEmail'],
                        ),
                      ),
                    );
                  },
                  child: const Text("Add Feedback"),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
