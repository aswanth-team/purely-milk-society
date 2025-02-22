import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:milkproject/farmer/page/HomePage.dart';

class FarmerAuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore fireStoreDatabase = FirebaseFirestore.instance;

  Future<void> societyRegister({
    required BuildContext context,
    required String name,
    required String password,
    required String phone,
    required String cow,
    required String email,
    required String documentUrl,
  }) async {
    try {
      // Register user in Firebase Authentication
      UserCredential user = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save farmer data to Firestore
      await fireStoreDatabase.collection('farmer').doc(user.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password, // Consider hashing in production
        'cow': cow,
        'document_url': documentUrl,
      });

      // Save role in role_tb
      await fireStoreDatabase.collection('role_tb').doc(user.user!.uid).set({
        'uid': user.user!.uid,
        'role': 'farmer',
      });

      // Notify user of success
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FarmerHome(),
          ));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }
  }
}
