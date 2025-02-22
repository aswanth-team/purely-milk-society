import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:milkproject/farmer/services/farmer_auth.dart';

class FarmerRegistrationScreen extends StatefulWidget {
  const FarmerRegistrationScreen({Key? key}) : super(key: key);

  @override
  FarmerRegistrationScreenState createState() =>
      FarmerRegistrationScreenState();
}

class FarmerRegistrationScreenState extends State<FarmerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController cowsController = TextEditingController();
  XFile? _document;
  bool _isPasswordVisible = false;
  bool _isUploading = false;
  final String cloudinaryUrl =
      'https://api.cloudinary.com/v1_1/dsdvk2lms/image/upload';
  final String uploadPreset = 'milk project';

  Future<void> _pickDocument() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _document = pickedFile;
    });
  }

  Future<String?> _uploadDocumentToCloudinary(XFile file) async {
    try {
      setState(() {
        _isUploading = true;
      });

      final bytes = await file.readAsBytes();
      final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl))
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
            http.MultipartFile.fromBytes('file', bytes, filename: file.name));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final json = jsonDecode(responseData);
        return json['secure_url'];
      } else {
        throw Exception('Failed to upload document: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error uploading document: $e');
      return null;
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _registerFarmer() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_document == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload a document')),
        );
        return;
      }

      final documentUrl = await _uploadDocumentToCloudinary(_document!);
      if (documentUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload the document')),
        );
        return;
      }

      FarmerAuthService authService = FarmerAuthService();
      await authService.societyRegister(
        context: context,
        name: nameController.text.trim(),
        password: passwordController.text.trim(),
        phone: phoneController.text.trim(),
        cow: cowsController.text.trim(),
        email: emailController.text.trim(),
        documentUrl: documentUrl,
      );
    }
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
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Farmer Registration',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: nameController,
                        label: 'Name',
                        icon: Icons.person,
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your name' : null,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: emailController,
                        label: 'Email Address',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty) return 'Please enter your email';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your phone number'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      _buildPasswordField(passwordController, 'Password'),
                      const SizedBox(height: 20),
                      _buildPasswordField(
                          confirmPasswordController, 'Confirm Password',
                          validator: (value) {
                        if (value != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      }),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: cowsController,
                        label: 'Number of Cows',
                        icon: Icons.local_florist,
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty
                            ? 'Please enter the number of cows'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickDocument,
                            icon: const Icon(Icons.upload_file,
                                color: Colors.white),
                            label: const Text('Upload Document'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 20),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              elevation: 4,
                            ),
                          ),
                          if (_document != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                'Selected: ${_document!.name}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _isUploading ? null : _registerFarmer,
                            icon: _isUploading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.app_registration,
                                    color: Colors.white),
                            label: Text(
                                _isUploading ? 'Registering...' : 'Register'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 20),
                              backgroundColor:
                                  _isUploading ? Colors.grey : Colors.green,
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              elevation: 4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white), // Label color to white
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Colors.white), // Border color when not focused
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Colors.white, width: 2.0), // Border color when focused
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white), // Default border
        ),
        hintStyle: TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white),
      ),
      validator: validator,
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white), // Label color to white
        enabledBorder: const OutlineInputBorder(
          borderSide:
              BorderSide(color: Colors.white), // Border color when not focused
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
              color: Colors.white, width: 2.0), // Border color when focused
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white), // Default border
        ),
        prefixIcon: const Icon(Icons.lock, color: Colors.white),
        suffixIcon: IconButton(
          icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.white),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
      validator: validator,
    );
  }
}
