import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore

class ViewCustomers extends StatelessWidget {
  const ViewCustomers({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Customers"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users') // Assuming your collection is named 'users'
            .where('role', isEqualTo: 'Customer') // Filter users with role 'Customer'
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No customers found.'));
          }

          final customers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              var customer = customers[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Name: ${customer['name']}'), // Assuming 'name' is a field
                  subtitle: Text('Email: ${customer['email']}'), // Assuming 'email' is a field
                  trailing: Text('Phone: ${customer['phone']}'), // Assuming 'phone' is a field
                ),
              );
            },
          );
        },
      ),
    );
  }
}
