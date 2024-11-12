import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login.dart';
import 'booking_page.dart'; // Assuming booking page is available
import 'previousorders.dart'; // Assuming previous orders page is available
import 'track.dart'; // Import track page

class Customer extends StatefulWidget {
  const Customer({super.key});

  @override
  State<Customer> createState() => _CustomerState();
}

class _CustomerState extends State<Customer> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
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

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PreviousOrders()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Track()), // Navigate to Track page
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer"),
        backgroundColor: const Color.fromARGB(255, 243, 173, 103),
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _buildCustomerHomePage(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 243, 173, 103),
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Previous Bookings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: "Track Booking",
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerHomePage() {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildServiceCard('Cleaning', Icons.cleaning_services),
        const SizedBox(height: 16),
        _buildServiceCard('Painting', Icons.brush),
        const SizedBox(height: 16),
        _buildServiceCard('Mechanic', Icons.build),
        const SizedBox(height: 16),
        _buildServiceCard('Plumber', Icons.plumbing),
      ],
    );
  }

  Widget _buildServiceCard(String serviceName, IconData icon) {
    return Card(
      color: const Color.fromARGB(255, 219, 194, 113),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.black),
        title: Text(
          serviceName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        onTap: () {
          // You can navigate to the booking page with the service type here
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingPage(serviceType: serviceName),
            ),
          );
        },
      ),
    );
  }
}
