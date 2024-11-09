import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookingPage extends StatefulWidget {
  final String serviceType;

  const BookingPage({super.key, required this.serviceType});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();

  // Controller for remarks
  final TextEditingController _remarksController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedSlot;
  String? _email;
  String? _phone;
  String? _city;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  // Fetch current user email, phone, and city from FirebaseAuth and Firestore
  Future<void> _fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _email = user.email;
      });

      try {
        // Fetch user details from Firestore (users collection) using email
        QuerySnapshot userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email) // Querying users by email
            .limit(1) // Assuming email is unique, we limit to 1 result
            .get();

        if (userQuery.docs.isNotEmpty) {
          // Fetch the first document matching the email
          DocumentSnapshot userDoc = userQuery.docs.first;

          setState(() {
            _phone = userDoc['phone']; // Assuming the user's phone number is stored under 'phone'
            _city = userDoc['city'];   // Assuming the user's city is stored under 'city'
          });
        } else {
          // Handle case where user data is not found
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User data not found in Firestore')));
        }
      } catch (e) {
        // Handle error if user data retrieval fails
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching user details: $e')));
      }
    }
  }

  // Function to handle booking submission
  Future<void> _submitBooking() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDate == null || _selectedSlot == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select date and slot.')));
        return;
      }

      try {
        // Save the booking details to Firestore
        await FirebaseFirestore.instance.collection('bookings').add({
          'serviceType': widget.serviceType,
          'date': _selectedDate,
          'slot': _selectedSlot,
          'customerEmail': _email,
          'customerPhone': _phone, // Store phone in bookings collection
          'customerCity': _city,   // Store city in bookings collection
          'remarks': _remarksController.text,
          'status': 'requested', // or your defined status
        });

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking request submitted!')));

        // Optionally, navigate back or show a success message
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  // Open date picker to choose the date
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Ensure the date picker starts from today
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Book ${widget.serviceType}")),
      body: SingleChildScrollView( // Add SingleChildScrollView to make the form scrollable
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Service Type: ${widget.serviceType}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Date Picker
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Select Date',
                      hintText: _selectedDate != null
                          ? '${_selectedDate!.toLocal()}'.split(' ')[0]
                          : 'Pick a date',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_selectedDate == null) {
                        return 'Please select a date';
                      }
                      return null;
                    },
                    controller: TextEditingController(
                      text: _selectedDate != null
                          ? '${_selectedDate!.toLocal()}'.split(' ')[0]
                          : '',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Slot Picker (Dropdown)
              DropdownButtonFormField<String>(
                value: _selectedSlot,
                decoration: const InputDecoration(
                  labelText: 'Select Slot',
                  border: OutlineInputBorder(),
                ),
                items: ['9:00 AM', '12:00 PM', '3:00 PM', '6:00 PM']
                    .map((slot) => DropdownMenuItem<String>(
                          value: slot,
                          child: Text(slot),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSlot = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a time slot';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Remarks TextField
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  labelText: 'Remarks (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              // Customer Email (Fetched from Firebase)
              TextFormField(
                initialValue: _email ?? 'Fetching email...',
                decoration: const InputDecoration(
                  labelText: 'Customer Email',
                  border: OutlineInputBorder(),
                  enabled: false,
                ),
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 16),

              // Submit Button
              ElevatedButton(
                onPressed: _submitBooking,
                child: const Text('Submit Booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
