import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'reviews_ratings.dart';
import 'edit_provider.dart'; // Import the edit provider page
import 'complaints_page.dart'; // Import complaints page
import 'chat_pageprotocus.dart';
class Provider extends StatefulWidget {
  const Provider({super.key});

  @override
  State<Provider> createState() => _ProviderState();
}

class _ProviderState extends State<Provider> {
  User? user = FirebaseAuth.instance.currentUser;
  String? providerEmail;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    providerEmail = user?.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Provider"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProviderPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              logout(context);
            },
          ),
        ],
      ),
      body: providerEmail == null
          ? const Center(child: CircularProgressIndicator())
          : bookingDetails(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReviewsRatingsPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ComplaintsPage()), // Navigate to Complaints page
            );
          }
        },
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
/* 
  Widget bookingDetails() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('serviceProviderEmail', isEqualTo: providerEmail)
          .where('status', isEqualTo: 'assigned')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No bookings available.'));
        }

        final bookings = snapshot.data!.docs;

        return ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            var booking = bookings[index];
            var bookingData = booking.data() as Map<String, dynamic>; // Cast to Map

            DateTime? date;
            try {
              date = (bookingData['date'] as Timestamp).toDate();
            } catch (e) {
              date = null;
            }

            return Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Booking ID: ${booking.id}'),
                    const SizedBox(height: 8),
                    Text('Date: ${date != null ? date.toLocal().toString().split(' ')[0] : 'No date available'}'),
                    if (bookingData.containsKey('slot'))
                      Text('Slot: ${bookingData['slot']}'),
                    Text('Customer Phone: ${bookingData['customerPhone']}'),
                    Text('Customer City: ${bookingData['customerCity']}'),
                    Text('Remarks: ${bookingData['remarks']}'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: bookingData['status'] == 'done'
                              ? null
                              : () => markWorkDone(booking.id),
                          child: const Text('Work Done'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
 */

Widget bookingDetails() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('bookings')
        .where('serviceProviderEmail', isEqualTo: providerEmail)
        .where('status', isEqualTo: 'assigned')
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(child: Text('No bookings available.'));
      }

      final bookings = snapshot.data!.docs;

      return ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          var booking = bookings[index];
          var bookingData = booking.data() as Map<String, dynamic>;

          DateTime? date;
          try {
            date = (bookingData['date'] as Timestamp).toDate();
          } catch (e) {
            date = null;
          }

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Booking ID: ${booking.id}'),
                  const SizedBox(height: 8),
                  Text('Date: ${date != null ? date.toLocal().toString().split(' ')[0] : 'No date available'}'),
                  if (bookingData.containsKey('slot'))
                    Text('Slot: ${bookingData['slot']}'),
                  Text('Customer Phone: ${bookingData['customerPhone']}'),
                  Text('Customer City: ${bookingData['customerCity']}'),
                  Text('Remarks: ${bookingData['remarks']}'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: bookingData['status'] == 'done'
                            ? null
                            : () => markWorkDone(booking.id),
                        child: const Text('Work Done'),
                      ),
                     /*  ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProChatPage(
                                bookingId: booking.id,
                                customerEmail: bookingData['customerEmail'],
                              ),
                            ),
                          );
                        },
                        child: const Text('Chat'),
                      ), */
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

  Future<void> markWorkDone(String bookingId) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({'status': 'done'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Status updated to 'done'")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update status: $e")),
      );
    }
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }
}
