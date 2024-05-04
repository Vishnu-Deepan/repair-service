import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:repair_service/screens/login_signup_screen.dart';

import 'manage_request.dart';

class OwnerHomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Owner Home'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              _showLogoutPopup(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Navigate to manage repair requests screen
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ManageRequestsScreen()));
                },
                child: Card(
                  child: Center(
                    child: Text(
                      'Manage Repair Requests',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Additional functionality (e.g., manage mechanics)
                },
                child: Card(
                  child: Center(
                    child: Text(
                      'Manage Mechanics',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () async {
                  // Sign out the user
                  await _auth.signOut();
                  // Close the bottom sheet
                  Navigator.pop(context);
                  Navigator.pushReplacement(context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const LoginSignupPage(),
                    ),);
                  // Navigate back to the login/signup screen
                  // Example: Navigator.popUntil(context, ModalRoute.withName('/'));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}