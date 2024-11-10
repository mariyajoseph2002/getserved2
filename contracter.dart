import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login.dart';
import 'assignproviders.dart';

class Contracter extends StatefulWidget {
  const Contracter({super.key});

  @override
  State<Contracter> createState() => _ContracterState();
}

class _ContracterState extends State<Contracter> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Contractor"),
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('status', isEqualTo: 'requested') // Only fetch bookings where status is 'requested'
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("An error occurred. Please try again later."));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No requested bookings available"));
          }

          // Display list of bookings in a card format
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
                      Text("Date: $formattedDate"),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AssignProviders(booking: document), // Pass entire document
                            ),
                          );
                        },
                        child: const Text("Assign Provider"),
                      ),
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

  Future<void> logout(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context); // Dismiss loading dialog
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }
}
