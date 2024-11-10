import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProviderPage extends StatefulWidget {
  const EditProviderPage({super.key});

  @override
  State<EditProviderPage> createState() => _EditProviderPageState();
}

class _EditProviderPageState extends State<EditProviderPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _chargeController = TextEditingController();
  final TextEditingController _additionalDetailsController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadProviderData();
  }

  Future<void> _loadProviderData() async {
    if (user == null) return;

    // Fetch from the 'users' collection where the role is 'provider'
    var userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    if (userDoc.exists && userDoc['role'] == 'provider') {
      setState(() {
        _phoneController.text = userDoc['phone'] ?? '';
        _chargeController.text = userDoc['charge'] ?? '';
        _additionalDetailsController.text = userDoc['additionalDetails'] ?? '';
      });
    }
  }

  Future<void> _saveProviderData() async {
    if (user == null) return;

    try {
      // Update 'users' collection
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
          'additionalDetails': _additionalDetailsController.text,
          'charge': _chargeController.text,
          'phone': _phoneController.text,
     
      
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Provider information updated')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update information: $e')),
      );
    }
  }

  @override
  void dispose() {
    // Dispose controllers when not needed
    _chargeController.dispose();
    _phoneController.dispose();
    _additionalDetailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Provider Information'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _chargeController,
              decoration: const InputDecoration(labelText: 'Charge/hr'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _additionalDetailsController,
              decoration: const InputDecoration(labelText: 'Additional Details'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProviderData,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
