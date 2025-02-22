import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:milkproject/user/page/user_home.dart';

class UserAuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore fireStoreDatabase = FirebaseFirestore.instance;

  Future<void> userRegister({
    required BuildContext context,
    required String name,
    required String password,
    required String aadhar,
    required String ration,
    required String bank,
    required String phone,
    required String email,
  }) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final userId = userCredential.user?.uid;

      if (userId != null) {
        await fireStoreDatabase.collection('user').doc(userId).set({
          'name': name,
          'email': email,
          'phone': phone,
          'ration_card': ration,
          'bank_account': bank,
          'aadhar': aadhar,
          'password': password,
          'role': 'user', // Default role is 'user'
        });

        fireStoreDatabase
            .collection('role_tb')
            .add({'uid': userCredential.user?.uid, 'role': 'user'});

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful'),
          ),
        );

        // Navigate to MilkProductPage after successful registration
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
              builder: (context) => MilkProductPage(cartProducts: const [])),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: ${e.toString()}'),
        ),
      );
    }
  }
}
