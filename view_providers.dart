import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore

class ViewProviders extends StatelessWidget {
  const ViewProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Providers"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users') // Assuming your collection is named 'users'
            .where('role', isEqualTo: 'provider') // Filter users with role 'Customer'
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Providers found.'));
          }

          final ViewProviders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: ViewProviders.length,
            itemBuilder: (context, index) {
              var customer = ViewProviders[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Text('${customer['serviceType']}'),
                  title: Text('Name: ${customer['firstName']} ${customer['lastName']} '), // Assuming 'name' is a field
                  subtitle: Text('Email: ${customer['email']}'),
             // Assuming 'email' is a field
             

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
