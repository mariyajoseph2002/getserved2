import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewContractors extends StatefulWidget {
  const ViewContractors({super.key});

  @override
  _ViewContractorsState createState() => _ViewContractorsState();
}

class _ViewContractorsState extends State<ViewContractors> {
  bool _isLoading = true;
  List<DocumentSnapshot> _contractors = []; // List to hold contractor details

  @override
  void initState() {
    super.initState();
    _fetchContractors(); // Fetch contractors on page load
  }

  // Fetch contractors from Firestore where role is 'contractor'
  Future<void> _fetchContractors() async {
    setState(() {
      _isLoading = true;
    });

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Contracter')
        .get();

    setState(() {
      _contractors = querySnapshot.docs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contractors"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading spinner
          : _contractors.isEmpty
              ? const Center(child: Text("No contractors found.")) // Show if no contractors
              : ListView.builder(
                  itemCount: _contractors.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot contractor = _contractors[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          "${contractor['name']} ",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                           Text("Phone no: ${contractor['phone']}"),
                            Text("Email: ${contractor['email']}"),
                            
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
