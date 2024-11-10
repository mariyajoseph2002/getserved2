import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'provider.dart'; // Import the providers page

class ReviewsRatingsPage extends StatefulWidget {
  const ReviewsRatingsPage({super.key});

  @override
  _ReviewsRatingsPageState createState() => _ReviewsRatingsPageState();
}

class _ReviewsRatingsPageState extends State<ReviewsRatingsPage> {
  int _selectedIndex = 1; // Set the initial index to 1 (Reviews & Ratings)

  void _onItemTapped(int index) {
    if (index == 0) {
      // Navigate to the Home (Providers) page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Provider()),
      );
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews & Ratings'),
        backgroundColor: Color.fromARGB(255, 243, 173, 103),
      ),
      body: user == null
          ? const Center(child: Text('Please log in to view reviews.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('feedback')
                  .where('providerEmail', isEqualTo: user.email) // Use logged-in provider's email
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No reviews available.'));
                }

                final reviews = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    var review = reviews[index];
            

                    return Card(
                      color:  Color.fromARGB(255, 219, 194, 113),
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rating: ${review['rating']} / 5',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Feedback: ${review['feedback']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                          
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.reviews),
            label: 'Reviews & Ratings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      ),
    );
  }
}
