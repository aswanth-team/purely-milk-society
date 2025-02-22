import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:milkproject/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _profileData;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _profileData = fetchProfileData();
  }

  // Fetch profile data for the logged-in user
  Future<Map<String, dynamic>> fetchProfileData() async {
    try {
      // Get the current user
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Fetch the document for the logged-in user
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('society')
          .doc(user.uid) // Use the logged-in user's UID
          .get();

      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        throw Exception('Profile not found for user: ${user.uid}');
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      throw Exception('Failed to load profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        title: const Text(
          'Society Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'No profile data found',
                style: TextStyle(color: Colors.black),
              ),
            );
          }

          // Data loaded successfully
          final profile = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // User Icon
                  const Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Individual Cards for Each Detail
                  buildDetailCard(
                    icon: Icons.location_city,
                    label: 'Building Address',
                    value: profile['buildingaddress'] ?? 'N/A',
                  ),
                  buildDetailCard(
                    icon: Icons.location_on,
                    label: 'Location',
                    value: profile['location'] ?? 'N/A',
                  ),
                  buildDetailCard(
                    icon: Icons.pin_drop,
                    label: 'Pincode',
                    value: profile['pincode'] ?? 'N/A',
                  ),
                  buildDetailCard(
                    icon: Icons.phone,
                    label: 'Contact Number',
                    value: profile['contactnumber'] ?? 'N/A',
                  ),
                  buildDetailCard(
                    icon: Icons.confirmation_number,
                    label: 'License Number',
                    value: profile['licencenumber'] ?? 'N/A',
                  ),
                  buildDetailCard(
                    icon: Icons.person_outline,
                    label: 'Manager Name',
                    value: profile['managername'] ?? 'N/A',
                  ),
                  buildDetailCard(
                    icon: Icons.phone_android,
                    label: 'Manager Contact Number',
                    value: profile['managercontact'] ?? 'N/A',
                  ),
                  buildDetailCard(
                    icon: Icons.email,
                    label: 'Email ID',
                    value: profile['email'] ?? 'N/A',
                  ),
                  const SizedBox(height: 30),

                  // Logout Button
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _auth.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper method to build individual detail cards
  Widget buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blue.withOpacity(0.5), width: 2),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue, size: 30),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
