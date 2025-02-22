// ignore_for_file: unused_import

import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:milkproject/farmer/page/farmer_registration_page.dart';
import 'package:milkproject/firebase_options.dart';
import 'package:milkproject/login_page.dart';
import 'package:milkproject/splash_screen.dart';

const apiKey = 'AIzaSyCQRkPILWqFh25RkX33Wx2r1RwoMEg0oSg';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Gemini.init(apiKey: apiKey);
  runApp(
    MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen()),
  );
}
