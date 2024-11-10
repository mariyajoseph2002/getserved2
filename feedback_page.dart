import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackPage extends StatefulWidget {
  final String providerEmail;
  final String customerEmail;

  const FeedbackPage({super.key,required this.customerEmail, required this.providerEmail});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _feedbackController = TextEditingController();
  String _selectedRating = '5'; // Default value that matches an item in the list
  final List<String> _ratings = ['1', '2', '3', '4', '5']; // Rating options

  Future<void> _submitFeedback() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('feedback').add({
        'customerEmail': user.email,
        'providerEmail': widget.providerEmail,
        'rating': _selectedRating,
        'feedback': _feedbackController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Feedback Submitted Successfully!")),
      );
      Navigator.pop(context); // Return to previous page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Provide Feedback"),
        backgroundColor:  Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Rate the Provider:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedRating,
              onChanged: (newValue) {
                setState(() {
                  _selectedRating = newValue!;
                });
              },
              items: _ratings.map((rating) {
                return DropdownMenuItem(
                  value: rating,
                  child: Text(rating),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              "Feedback:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter your feedback here",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitFeedback,
              child: const Text("Submit Feedback"),
              style: ElevatedButton.styleFrom(
                backgroundColor:  Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
