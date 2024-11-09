

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  bool _showProgress = false;
  bool _isPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  List<String> roles = ['Customer', 'Contracter',];
  String selectedRole = 'Customer';
  String selectedGender = 'Male'; // Default gender

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    ageController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 164, 229, 239),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Color.fromARGB(255, 164, 223, 226),
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 80),
                        const Text(
                          "Register Now",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 40,
                          ),
                        ),
                        const SizedBox(height: 50),
                        _buildTextField(
                          controller: nameController,
                          hintText: 'Name',
                          validator: _validateName,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: emailController,
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: passwordController,
                          hintText: 'Password',
                          obscureText: _isPasswordObscure,
                          suffixIcon: _togglePasswordVisibility(isConfirmPassword: false),
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: confirmPasswordController,
                          hintText: 'Confirm Password',
                          obscureText: _isConfirmPasswordObscure,
                          suffixIcon: _togglePasswordVisibility(isConfirmPassword: true),
                          validator: _validateConfirmPassword,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: cityController,
                          hintText: 'City',
                          validator: _validateCity,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: pincodeController,
                          hintText: 'Pincode',
                          keyboardType: TextInputType.number,
                          validator: _validatePincode,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: ageController,
                          hintText: 'Age',
                          keyboardType: TextInputType.number,
                          validator: _validateAge,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: phoneController,
                          hintText: 'Phone Number',
                          keyboardType: TextInputType.phone,
                          validator: _validatePhone, // Add phone validation
                        ),
                        const SizedBox(height: 20),
                        const SizedBox(height: 20),
                        _buildRoleDropdown(),
                        const SizedBox(height: 20),
                        _buildGenderDropdown(),
                        const SizedBox(height: 20),
                        _buildActionButtons(),
                        const SizedBox(height: 20),
                       
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 14),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(20),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      validator: validator,
    );
  }

  Widget _togglePasswordVisibility({required bool isConfirmPassword}) {
    return IconButton(
      icon: Icon(isConfirmPassword
          ? _isConfirmPasswordObscure
              ? Icons.visibility_off
              : Icons.visibility
          : _isPasswordObscure
              ? Icons.visibility_off
              : Icons.visibility),
      onPressed: () {
        setState(() {
          if (isConfirmPassword) {
            _isConfirmPasswordObscure = !_isConfirmPasswordObscure;
          } else {
            _isPasswordObscure = !_isPasswordObscure;
          }
        });
      },
    );
  }

 /*  Widget _buildRoleDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Role: ",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        DropdownButton<String>(
          dropdownColor: Colors.blue[900],
          value: selectedRole,
          items: roles.map((String role) {
            return DropdownMenuItem(
              value: role,
              child: Text(
                role,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              selectedRole = newValue!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    List<String> genders = ['Male', 'Female', 'Other'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Gender: ",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        DropdownButton<String>(
          dropdownColor: Colors.blue[900],
          value: selectedGender,
          items: genders.map((String gender) {
            return DropdownMenuItem(
              value: gender,
              child: Text(
                gender,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              selectedGender = newValue!;
            });
          },
        ),
      ],
    );
  }
 */
Widget _buildRoleDropdown() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Role: ",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          DropdownButton<String>(
            dropdownColor: Colors.blue[900],
            value: selectedRole,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
            iconSize: 24,
            underline: SizedBox(),
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            items: roles.map((String role) {
              return DropdownMenuItem(
                value: role,
                child: Text(role),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedRole = newValue!;
              });
            },
          ),
        ],
      ),
    ),
  );
}
Widget _buildGenderDropdown() {
  List<String> genders = ['Male', 'Female', 'Other'];
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Gender: ",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          DropdownButton<String>(
            dropdownColor: Colors.blue[900],
            value: selectedGender,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
            iconSize: 24,
            underline: SizedBox(),
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            items: genders.map((String gender) {
              return DropdownMenuItem(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedGender = newValue!;
              });
            },
          ),
        ],
      ),
    ),
  );
}

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text("Login", style: TextStyle(fontSize: 20)),
        ),
        ElevatedButton(
          onPressed: _register,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text("Register", style: TextStyle(fontSize: 20)),
        ),
      ],
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
  String? _validateName(String? value) {
    if (value!.isEmpty) {
      return "Name cannot be empty";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value!.isEmpty) {
      return "Email cannot be empty";
    }
    if (!RegExp(r'^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\.[a-z]+$').hasMatch(value)) {
      return "Please enter a valid email";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value!.isEmpty) {
      return "Password cannot be empty";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters long";
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != passwordController.text) {
      return "Passwords do not match";
    }
    return null;
  }

  String? _validateCity(String? value) {
    if (value!.isEmpty) {
      return "City cannot be empty";
    }
    return null;
  }

  String? _validatePincode(String? value) {
    if (value!.isEmpty) {
      return "Pincode cannot be empty";
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return "Pincode must be 6 number";
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value!.isEmpty) {
      return "Age cannot be empty";
    }
    if (int.tryParse(value) == null || int.parse(value) < 0) {
      return "Please enter a valid age";
    }
    return null;
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _showProgress = true;
      });
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        await _postDetailsToFirestore(userCredential.user!.uid);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } catch (e) {
        print(e);
      } finally {
        setState(() {
          _showProgress = false;
        });
      }
    }
  }

  Future<void> _postDetailsToFirestore(String uid) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    CollectionReference users = firebaseFirestore.collection('users');

    await users.doc(uid).set({
      'name': nameController.text,
      'email': emailController.text,
      'role': selectedRole,
      'gender': selectedGender,
      'city': cityController.text,
      'pincode': pincodeController.text,
      'age': int.parse(ageController.text),
      'phone': phoneController.text,
    });
  }
}
