import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'request_detail.dart';

class ManageRequestsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Repair Requests'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('repair_requests').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No repair requests found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              var request = snapshot.data!.docs[index];
              return ListTile(
                title: Text(request['itemType']),
                subtitle: Text(request['issueDescription']),
                onTap: () {
                  // Navigate to request details screen or implement action
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RequestDetailsScreen(requestId: request.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}