import 'package:flutter/material.dart';
import 'package:milkproject/user/page/services/user_auth.dart';

class UserSignupPage extends StatefulWidget {
  const UserSignupPage({super.key});

  @override
  State<UserSignupPage> createState() => UserSignupPageState();
}

class UserSignupPageState extends State<UserSignupPage> {
  // Controllers for each field
  final TextEditingController name = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController aadhar = TextEditingController();
  final TextEditingController ration = TextEditingController();
  final TextEditingController bank = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController email = TextEditingController();

  // State for password visibility toggle
  bool showPassword = true;

  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Validation functions
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username cannot be empty';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateAadhar(String? value) {
    if (value == null || value.isEmpty) {
      return 'Aadhar number cannot be empty';
    } else if (value.length != 12 || !RegExp(r'^\d+$').hasMatch(value)) {
      return 'Aadhar number must be 12 digits';
    }
    return null;
  }

  String? validateRationCard(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ration Card number cannot be empty';
    } else if (value.length < 10 || value.length > 15) {
      return 'Ration Card number must be between 10 and 15 characters';
    } else if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return 'Ration Card number should only contain alphanumeric characters';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number cannot be empty';
    } else if (value.length != 10 || !RegExp(r'^\d+$').hasMatch(value)) {
      return 'Phone number must be 10 digits';
    }
    return null;
  }

  String? validateBankAccount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bank account number cannot be empty';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  bool loading = false;
  void register() async {
    setState(() {
      loading = true;
    });

    if (_formKey.currentState?.validate() ?? false) {
      await UserAuthService().userRegister(
        context: context,
        name: name.text,
        password: password.text,
        aadhar: aadhar.text,
        ration: ration.text,
        bank: bank.text,
        phone: phone.text,
        email: email.text,
      );
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C5364),
        title: const Text(
          'Signup Page',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'User Registration',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: name,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(
                            color: Colors.white), // Label color to white
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors
                                  .white), // Border color when not focused
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white,
                              width: 2.0), // Border color when focused
                        ),
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white), // Default border
                        ),
                        prefixIcon: Icon(Icons.person, color: Colors.white),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: validateUsername,
                    ),
                    const SizedBox(height: 16.0),
                    // Email field
                    TextFormField(
                      controller: email,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                            color: Colors.white), // Label color to white
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors
                                  .white), // Border color when not focused
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white,
                              width: 2.0), // Border color when focused
                        ),
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white), // Default border
                        ),
                        prefixIcon: Icon(Icons.email, color: Colors.white),
                      ),
                      validator: validateEmail,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16.0),
                    // Password field
                    TextFormField(
                      controller: password,
                      obscureText: showPassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                            color: Colors.white), // Label color to white
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors
                                  .white), // Border color when not focused
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white,
                              width: 2.0), // Border color when focused
                        ),
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white), // Default border
                        ),
                        prefixIcon: const Icon(Icons.lock, color: Colors.white),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                        ),
                      ),
                      validator: validatePassword,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16.0),
                    // Aadhar number field
                    TextFormField(
                      controller: aadhar,
                      decoration: const InputDecoration(
                        labelText: 'Aadhar Number',
                        labelStyle: TextStyle(
                            color: Colors.white), // Label color to white
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors
                                  .white), // Border color when not focused
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white,
                              width: 2.0), // Border color when focused
                        ),
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white), // Default border
                        ),
                        prefixIcon:
                            Icon(Icons.card_membership, color: Colors.white),
                      ),
                      keyboardType: TextInputType.number,
                      validator: validateAadhar,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16.0),
                    // Ration number field
                    TextFormField(
                      controller: ration,
                      validator: validateRationCard,
                      decoration: const InputDecoration(
                        labelText: 'Ration Number',
                        labelStyle: TextStyle(
                            color: Colors.white), // Label color to white
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors
                                  .white), // Border color when not focused
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white,
                              width: 2.0), // Border color when focused
                        ),
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white), // Default border
                        ),
                        prefixIcon:
                            Icon(Icons.card_travel, color: Colors.white),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16.0),
                    // Bank account number field
                    TextFormField(
                      controller: bank,
                      decoration: const InputDecoration(
                        labelText: 'Bank Account Number',
                        labelStyle: TextStyle(
                            color: Colors.white), // Label color to white
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors
                                  .white), // Border color when not focused
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white,
                              width: 2.0), // Border color when focused
                        ),
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white), // Default border
                        ),
                        prefixIcon: Icon(Icons.account_balance_wallet,
                            color: Colors.white),
                      ),
                      keyboardType: TextInputType.number,
                      validator: validateBankAccount,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16.0),
                    // Phone number field
                    TextFormField(
                      controller: phone,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number',
                        labelStyle: TextStyle(
                            color: Colors.white), // Label color to white
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors
                                  .white), // Border color when not focused
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white,
                              width: 2.0), // Border color when focused
                        ),
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white), // Default border
                        ),
                        prefixIcon: Icon(Icons.phone, color: Colors.white),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: validatePhone,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 20.0),
                    // Signup button
                    loading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            onPressed: register,
                            icon: const Icon(Icons.person_add,
                                color: Colors.white),
                            label: const Text('Sign Up'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 20),
                              backgroundColor:
                                  Colors.blue, // Change color as needed
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              elevation: 4,
                            ),
                          ),
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
