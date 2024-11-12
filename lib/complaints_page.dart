import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'reviews_ratings.dart';
import 'provider.dart'; // Assume provider_home.dart is the main Provider page with Bookings

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({super.key});

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  int _selectedIndex = 2; // Set index to 2 to highlight Complaints as the current page

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate based on selected index
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Provider()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ReviewsRatingsPage()),
      );
    } else if (index == 2) {
      // Stay on Complaints page, no navigation needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complaints"),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('serviceProviderEmail', isEqualTo: FirebaseAuth.instance.currentUser?.email)
            .where('status', isEqualTo: 'done') // Fetch only completed bookings
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No completed bookings available for complaints."));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              var bookingData = doc.data() as Map<String, dynamic>;
              String customerEmail = bookingData['customerEmail'] ?? '';

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text("Service: ${bookingData['serviceType']}"),
                  subtitle: Text("Customer: ${bookingData['customerEmail']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.report),
                    onPressed: () {
                      _showComplaintDialog(context, doc.id, customerEmail);
                    },
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Reviews & Ratings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: 'Complaints',
          ),
        ],
      ),
    );
  }

  void _showComplaintDialog(BuildContext context, String bookingId, String customerEmail) {
    final TextEditingController complaintController = TextEditingController();
    final String? providerEmail = FirebaseAuth.instance.currentUser?.email;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("File a Complaint"),
          content: TextField(
            controller: complaintController,
            decoration: const InputDecoration(
              hintText: "Describe the issue",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('complaints')
                    .add({
                      'bookingId': bookingId,
                      'customerEmail': customerEmail,
                      'providerEmail': providerEmail, // Store provider email
                      'complaint': complaintController.text,
                      'timestamp': Timestamp.now(),
                    })
                    .then((value) => Navigator.of(context).pop());
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }
}
