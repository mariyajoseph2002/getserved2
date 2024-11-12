import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:getserved/view_complaints.dart';
import 'package:getserved/view_providers.dart';

import 'login.dart';
import 'add_provider.dart';
import 'view_customers.dart';
import 'view_contractors.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  int customerCount = 0;
  int providerCount = 0;
  int bookingCount = 0;

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  Future<void> fetchCounts() async {
    // Fetch customer count
    final customersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Customer')
        .get();
    setState(() {
      customerCount = customersSnapshot.size;
    });

    // Fetch provider count
    final providersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'provider')
        .get();
    setState(() {
      providerCount = providersSnapshot.size;
    });

    // Fetch booking count
    final bookingsSnapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .get();
    setState(() {
      bookingCount = bookingsSnapshot.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Welcome, Admin",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Displaying counts in informational boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoBox("Customers", customerCount, Colors.blue),
                _buildInfoBox("Providers", providerCount, Colors.green),
              //  _buildInfoBox("Bookings", bookingCount, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Function to build informational boxes
  Widget _buildInfoBox(String title, int count, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Drawer widget to create the sidebar
  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.teal,
            ),
            child: Text(
              'Admin Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          // Add Provider
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Add Provider'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddProvider(),
                ),
              );
            },
          ),
           ListTile(
            leading: const Icon(Icons.report_problem),
            title: const Text('Providers Complaints'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ViewComplaints(),
                ),
              );
            },
          ),
          // View Customers
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('View Customers'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ViewCustomers(),
                ),
              );
            },
          ),
           ListTile(
            leading: const Icon(Icons.people),
            title: const Text('View Providers'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ViewProviders(),
                ),
              );
            },
          ),
          // View Contractors
          ListTile(
            leading: const Icon(Icons.build),
            title: const Text('View Contractors'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ViewContractors(),
                ),
              );
            },
          ),
          // Log out option
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              logout(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    const CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }
}
