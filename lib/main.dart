import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:repair_service/firebase_options.dart';
import 'package:repair_service/screens/login_signup_screen.dart';

import 'screens/customer/submit_new_request.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginSignupPage(),
    );
  }
}
