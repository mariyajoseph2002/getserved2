import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AssignProviders extends StatelessWidget {
  final DocumentSnapshot booking;

  const AssignProviders({super.key, required this.booking});

  Future<void> _assignProvider(BuildContext context, String providerEmail, String providerPhone) async {
    // Update the booking document with the selected provider's details and set status to 'assigned'
    await FirebaseFirestore.instance.collection('bookings').doc(booking.id).update({
      'serviceProviderEmail': providerEmail,
      'providerPhone': providerPhone,
      'status': 'assigned',  // Set status to 'assigned'
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Provider assigned successfully")),
    );
    Navigator.pop(context); // Return to the previous screen after assigning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Assign Provider"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Customer Email: ${booking['customerEmail']}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "Date: ${booking['date'].toDate().toString().split(' ')[0]}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "Time Slot: ${booking['slot']}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "Remarks: ${booking['remarks'] ?? 'No remarks provided'}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            const Text(
              "Available Providers:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'provider')
                    .where('serviceType', isEqualTo: booking['serviceType']) // Adjust field if needed
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No providers available for this service"));
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((providerDoc) {
                      Map<String, dynamic> providerData = providerDoc.data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(providerData['firstName'] ?? 'No Name'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Email: ${providerData['email'] ?? 'N/A'}"),
                              Text("Phone: ${providerData['phone'] ?? 'N/A'}"),
                              Text("Experience: ${providerData['experience'] ?? 'Experienced proffessional'}"),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              // Assign this provider to the booking and update status to 'assigned'
                              _assignProvider(
                                context,
                                providerData['email'] ?? '',
                                providerData['phone'] ?? '',
                              );
                            },
                            child: const Text("Select"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
