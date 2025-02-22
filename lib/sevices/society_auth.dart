import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:firebase_core/firebase_core.dart';

class SocietyAuthService {
  final firebaseAuth = FirebaseAuth.instance;

  final fireStoreDatabase = FirebaseFirestore.instance;

  get name => null;

  get phone => null;

  Future<void> societyRegister(
      {required BuildContext context,
      required String buildingaddress,
      required String location,
      required String contactnumber,
      required String managername,
      required String managercontact,
      required String password,
      required String email,
      required String pincode,
      required String licencenumber}) async {
    try {
      final user = await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      print(user.user?.uid);

      await fireStoreDatabase.collection('society').doc(user.user?.uid).set({
        'buildingaddress': buildingaddress,
        'location': location,
        'contactnumber': contactnumber,
        'managername': managername,
        'password': password,
        'email': email,
        'pincode': pincode,
        'licencenumber': licencenumber,
        'managercontact': managercontact
      });
      fireStoreDatabase
          .collection('role_tb')
          .add({'uid': user.user?.uid, 'role': 'society'});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('registration successfull'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Registration failed'),
      ));
    }
  }
}
