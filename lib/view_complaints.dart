import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewComplaints extends StatefulWidget {
  const ViewComplaints({super.key});

  @override
  _ViewComplaintsState createState() => _ViewComplaintsState();
}

class _ViewComplaintsState extends State<ViewComplaints> {
  bool _isLoading = true;
  List<DocumentSnapshot> _complaints = []; // List to hold complaint details

  @override
  void initState() {
    super.initState();
    _fetchComplaints(); // Fetch complaints on page load
  }

  // Fetch complaints from Firestore
  Future<void> _fetchComplaints() async {
    setState(() {
      _isLoading = true;
    });

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('complaints') // Fetching from complaints collection
        .get();

    setState(() {
      _complaints = querySnapshot.docs;
      _isLoading = false;
    });
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yMMMd').add_jm().format(dateTime); // Format as "Jan 1, 2023, 5:30 PM"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complaints"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading spinner
          : _complaints.isEmpty
              ? const Center(child: Text("No complaints found.")) // Show if no complaints
              : ListView.builder(
                  itemCount: _complaints.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot complaint = _complaints[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          "${complaint['customerEmail']}", // Display complaint title
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Description: ${complaint['complaint']}"),
                            Text("By provider: ${complaint['providerEmail']}"),
                            Text("Date: ${_formatTimestamp(complaint['timestamp'])}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
