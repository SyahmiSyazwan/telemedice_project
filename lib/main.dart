import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:telemedice_project/pages/bottomNav.dart';
import 'package:telemedice_project/pages/login.dart';
import 'package:telemedice_project/pages/onboard.dart';
import 'package:telemedice_project/pages/signup.dart';
import 'package:telemedice_project/pages/profile.dart'; // if not already imported

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediTap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial',
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/onboard', // start here
      routes: {
        '/onboard': (context) => const Onboard(),
        '/login': (context) => const Login(),
        '/profile': (context) => const Profile(),
      },
    );
  }
}
