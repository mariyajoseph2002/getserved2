import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddProvider extends StatefulWidget {
  const AddProvider({super.key});

  @override
  State<AddProvider> createState() => _AddProviderState();
}

class _AddProviderState extends State<AddProvider> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _chargeController = TextEditingController();
  final TextEditingController _serviceTypeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _gender;
  bool _isLoading = false;

  // Firebase Auth and Firestore instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Provider"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(_firstNameController, "First Name"),
                const SizedBox(height: 16),
                _buildTextField(_lastNameController, "Last Name"),
                const SizedBox(height: 16),
                _buildTextField(_ageController, "Age", isNumber: true),
                const SizedBox(height: 16),
                _buildGenderSelector(),
                const SizedBox(height: 16),
                _buildTextField(_chargeController, "Charge (in Rs.)", isNumber: true),
                const SizedBox(height: 16),
                _buildTextField(_serviceTypeController, "Service Type"),
                const SizedBox(height: 16),
                _buildTextField(_emailController, "Email", isEmail: true),
                const SizedBox(height: 16),
                _buildTextField(_passwordController, "Password", isPassword: true),
                const SizedBox(height: 20),
                 _buildTextField(_phoneController, "Phone no", isNumber: true),
                const SizedBox(height: 20),
                _buildSubmitButton(),
                if (_isLoading)
                  const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false, bool isPassword = false, bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$label cannot be empty";
        }
        if (isEmail && !RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\.[a-z]+$").hasMatch(value)) {
          return "Please enter a valid email";
        }
        if (isNumber && int.tryParse(value) == null) {
          return "Please enter a valid number";
        }
        return null;
      },
    );
  }

  Widget _buildGenderSelector() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: "Gender",
        border: OutlineInputBorder(),
      ),
      value: _gender,
      items: const [
        DropdownMenuItem(value: "Male", child: Text("Male")),
        DropdownMenuItem(value: "Female", child: Text("Female")),
        DropdownMenuItem(value: "Other", child: Text("Other")),
      ],
      onChanged: (value) {
        setState(() {
          _gender = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return "Please select a gender";
        }
        return null;
      },
    );
  }
String? _validatePhone(String? value) {
    if (value!.isEmpty) {
      return "Phone number cannot be empty";
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return "Phone number must be 10 digits";
    }
    return null;
  }
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _submit,
      child: const Text("Add Provider"),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create the provider's account in Firebase Auth
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Add the provider's details to the Firestore collection
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'age': int.parse(_ageController.text.trim()),
          'gender': _gender,
          'charge': double.parse(_chargeController.text.trim()),
          'serviceType': _serviceTypeController.text.trim(),
          'email': _emailController.text.trim(),
          'role':'provider',
          'phone':_phoneController.text.trim(),
          'uid': userCredential.user!.uid, // Store user UID
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Provider added successfully!")),
        );
        _clearForm();
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.message}")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _ageController.clear();
    _chargeController.clear();
    _serviceTypeController.clear();
    _emailController.clear();
    _passwordController.clear();
    _phoneController.clear();
    setState(() {
      _gender = null;
    });
  }
}
