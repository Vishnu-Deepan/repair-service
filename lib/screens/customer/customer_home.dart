import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'submit_new_request.dart';

class CustomerHomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Home'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              _showLogoutPopup(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Navigate to submit repair request screen
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SubmitRequestScreen()));
                },
                child: Card(
                  child: Center(
                    child: Text(
                      'New Repair Request',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Navigate to track request status screen
                  // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => TrackStatusScreen()));
                },
                child: Card(
                  child: Center(
                    child: Text(
                      'Track Request Status',
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