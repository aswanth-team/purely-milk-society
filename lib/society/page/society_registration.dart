// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:milkproject/society/page/homepage.dart';
import 'package:milkproject/sevices/society_auth.dart';

class SocietyLockPage extends StatefulWidget {
  const SocietyLockPage({super.key});

  @override
  _SocietyLockPageState createState() => _SocietyLockPageState();
}

class _SocietyLockPageState extends State<SocietyLockPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController pinController = TextEditingController();

  bool loading = false;

  void authenticateHandler() async {
    setState(() {
      loading = true;
    });

    final pin = pinController.text.trim();

    // Example: Validate the PIN and perform authentication (replace with your authentication logic)
    if (pin == "1234") {
      // Example PIN (you can replace this with your own validation)
      // Navigate to the next screen if authentication is successful.
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const SocietyRegistrationScreen()),
      );
    } else {
      setState(() {
        loading = false;
      });
      // Show an error message if the PIN is incorrect
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incorrect PIN. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF2C5364),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    // Logo (you can use your logo)
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // "Authenticate Society" title
                    const Text(
                      'Authenticate Society',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // PIN Field
                    TextFormField(
                      controller: pinController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      maxLength: 4, // PIN of length 4
                      decoration: InputDecoration(
                        labelText: 'Enter PIN',
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.lock, color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your PIN';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    // Authenticate Button
                    SizedBox(
                      width: double.infinity,
                      child: loading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: authenticateHandler,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                              ),
                              child: const Text(
                                'AUTHENTICATE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 15),
                    // Optionally, you could add a "forgot pin" section if needed
                    const Spacer(),
                    const SizedBox(height: 20), // Bottom spacing for alignment
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SocietyRegistrationScreen extends StatefulWidget {
  const SocietyRegistrationScreen({super.key});

  @override
  _SocietyRegistrationScreenState createState() =>
      _SocietyRegistrationScreenState();
}

class _SocietyRegistrationScreenState extends State<SocietyRegistrationScreen> {
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final TextEditingController buildingAddressController =
      TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController licenseNumberController = TextEditingController();
  final TextEditingController managerNameController = TextEditingController();
  final TextEditingController managerContactController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _navigateToHomePage() {
    // Navigate to the HomePage if all validations pass
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MilkProjectHomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Society Registration',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Building Address Field
                    TextFormField(
                      controller: buildingAddressController,
                      decoration: InputDecoration(
                        labelText: 'Building Address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the building address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Location Field
                    TextFormField(
                      controller: locationController,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Pincode Field
                    TextFormField(
                      controller: pincodeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Pincode',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the pincode';
                        }
                        if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                          return 'Please enter a valid 6-digit pincode';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Contact Number Field
                    TextFormField(
                      controller: contactNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Contact Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the contact number';
                        }
                        if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                          return 'Please enter a valid 10-digit contact number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // License Number Field
                    TextFormField(
                      controller: licenseNumberController,
                      decoration: InputDecoration(
                        labelText: 'License Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the license number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Manager Name Field
                    TextFormField(
                      controller: managerNameController,
                      decoration: InputDecoration(
                        labelText: 'Manager Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the manager\'s name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Manager Contact Number Field
                    TextFormField(
                      controller: managerContactController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Manager Contact Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the manager\'s contact number';
                        }
                        if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                          return 'Please enter a valid 10-digit contact number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Email Field
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email address';
                        }
                        if (!RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 8, 111, 255),
                          padding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 60.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _navigateToHomePage();
                            {
                              SocietyAuthService().societyRegister(
                                context: context,
                                buildingaddress: buildingAddressController.text,
                                location: locationController.text,
                                contactnumber: contactNumberController.text,
                                managername: managerNameController.text,
                                managercontact: managerContactController.text,
                                password: passwordController.text,
                                email: emailController.text,
                                pincode: pincodeController.text,
                                licencenumber: licenseNumberController.text,
                              );
                            }
                          }
                          const Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                          null;
                        },
                        child: null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
