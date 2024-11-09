import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CBooking extends StatefulWidget {
  final DocumentSnapshot provider;

  const CBooking({super.key, required this.provider});

  @override
  State<CBooking> createState() => _CBookingState();
}

class _CBookingState extends State<CBooking> {
  DateTime? _selectedDate;
  List<DateTime> _unavailableDates = [];
  final TextEditingController _remarksController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  String? _contractorPhone;
  String? _contractorCity;

  @override
  void initState() {
    super.initState();
    _fetchUnavailableDates();
    _fetchContractorDetails();
  }

  Future<void> _fetchUnavailableDates() async {
    final bookings = await FirebaseFirestore.instance
        .collection('bookings')
        .where('providerId', isEqualTo: widget.provider.id)
        .get();

    setState(() {
      _unavailableDates = bookings.docs
          .map((doc) => (doc['date'] as Timestamp).toDate())
          .toList();
    });
  }

  Future<void> _fetchContractorDetails() async {
    final contractor = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.provider.id)
        .get();

    setState(() {
      _contractorPhone = contractor['phone'];
      _contractorCity = contractor['city'];
    });
  }

  Future<void> _bookService() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a date")),
      );
      return;
    }

    // Check if selected date is already unavailable
    if (_unavailableDates.contains(_selectedDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selected date is already booked")),
      );
      return;
    }

    // Save the booking
    await FirebaseFirestore.instance.collection('bookings').add({
      'providerId': widget.provider.id,
      'providerEmail': widget.provider['email'],
      'Email': user!.email,
      'date': _selectedDate,
      'remarks': _remarksController.text,
      'status': "requested",
      'Phone': _contractorPhone,
      'City': _contractorCity,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Booking Successful!")),
    );
    Navigator.pop(context);
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (picked != null && !_unavailableDates.contains(picked)) {
      setState(() {
        _selectedDate = picked;
      });
    } else if (picked != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selected date is unavailable")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book ${widget.provider['firstName']}"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${widget.provider['firstName']} ${widget.provider['lastName']}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text("Service Type: ${widget.provider['serviceType']}"),
            const SizedBox(height: 8),
            Text("Charge: Rs.${widget.provider['charge']}/hour"),
            const SizedBox(height: 16),

            Row(
              children: [
                Text(
                  _selectedDate == null
                      ? "Select Date"
                      : "Selected: ${_selectedDate!.toLocal()}",
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text("Choose Date"),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _remarksController,
              decoration: const InputDecoration(
                labelText: "Remarks",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _bookService,
              child: const Text("Book Now"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }
}
