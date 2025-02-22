import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:milkproject/farmer/page/EditProfile.dart';
import 'package:milkproject/login_page.dart';

class FarmerProfilePage extends StatefulWidget {
  @override
  _FarmerProfilePageState createState() => _FarmerProfilePageState();
}

class _FarmerProfilePageState extends State<FarmerProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String name = "Loading...";
  String email = "Loading...";
  String phoneNumber = "Loading...";
  String numberOfCows = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? currentUser = _auth.currentUser; // Get the logged-in user
      if (currentUser != null) {
        // Query the 'farmers' collection for the user's document
        DocumentSnapshot userDoc =
            await _firestore.collection('farmer').doc(currentUser.uid).get();

        if (userDoc.exists) {
          // Extract the required fields from Firestore
          setState(() {
            name = userDoc['name'] ?? "N/A";
            email = userDoc['email'] ?? "N/A";
            phoneNumber = userDoc['phone'] ?? "N/A";
            numberOfCows =
                userDoc['cow'] != null ? userDoc['cow'].toString() : "N/A";
          });
        } else {
          setState(() {
            name = "No Data Found";
            email = "No Data Found";
            phoneNumber = "No Data Found";
            numberOfCows = "No Data Found";
          });
        }
      } else {
        setState(() {
          name = "User Not Logged In";
          email = "User Not Logged In";
          phoneNumber = "User Not Logged In";
          numberOfCows = "User Not Logged In";
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        name = "Error";
        email = "Error";
        phoneNumber = "Error";
        numberOfCows = "Error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Farmer Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit,
              size: 26,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return EditProfilePage();
                },
              ));
            },
          ),
        ],
        elevation: 5,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blue[200],
                child: Icon(
                  Icons.person,
                  size: 70,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Farmer Profile",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileDetailRow(
                        icon: Icons.person,
                        title: "Name",
                        value: name,
                      ),
                      Divider(),
                      ProfileDetailRow(
                        icon: Icons.email,
                        title: "Email",
                        value: email,
                      ),
                      Divider(),
                      ProfileDetailRow(
                        icon: Icons.phone,
                        title: "Phone Number",
                        value: phoneNumber,
                      ),
                      Divider(),
                      ProfileDetailRow(
                        icon: Icons.pets,
                        title: "No. of Cows",
                        value: numberOfCows,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 40), // Adjusted padding
              child: SizedBox(
                width: double.infinity, // Ensure the button takes full width
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: Icon(Icons.logout),
                  label: Text(
                    "Logout",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () async {
                    await _auth.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20), // To ensure spacing at the bottom
          ],
        ),
      ),
    );
  }
}

class ProfileDetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const ProfileDetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blue[700], size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 2, // Allows more space for the value
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis, // Adds '...' if text is too long
              maxLines: 1, // Ensures single-line text
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }
}
