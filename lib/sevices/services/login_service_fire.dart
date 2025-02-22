import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:milkproject/farmer/page/HomePage.dart';
import 'package:milkproject/society/page/homepage.dart';
import 'package:milkproject/user/page/user_home.dart';

class LoginServiceFire {
  final firebaseAuth = FirebaseAuth.instance;
  final firestoreDatabse = FirebaseFirestore.instance;

  Future<void> LoginService({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Sign in with email and password
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Successful')),
        );

        final role = await firestoreDatabse
            .collection('role_tb')
            .where('uid', isEqualTo: userCredential.user?.uid)
            .get();

        final roledata = role.docs.first.data();
        final userRole = roledata['role'];

        // Save role to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', userRole);

        // Navigate based on role
        switch (userRole) {
          case 'user':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MilkProductPage(cartProducts: []),
              ),
            );
            break;
          case 'society':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MilkProjectHomePage(),
              ),
            );
            break;
          case 'farmer':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FarmerHome(),
              ),
            );
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Role not recognized')),
            );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed')),
      );
    }
  }
}
