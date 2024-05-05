import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:repair_service/screens/login_signup_screen.dart';

import 'detailed_request_mechanic.dart';

class MechanicHomePage extends StatefulWidget {
  final String mechanicEmail;

  const MechanicHomePage({Key? key, required this.mechanicEmail}) : super(key: key);

  @override
  State<MechanicHomePage> createState() => _MechanicHomePageState();
}

class _MechanicHomePageState extends State<MechanicHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade200, Colors.blue.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top * 1.4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mechanic Home',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginSignupPage(),
                      ),
                    );
                  },
                  icon: Icon(Icons.logout_rounded, color: Colors.white),
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('repair_requests')
                    .where('assignedMechanic', isEqualTo: widget.mechanicEmail)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final documents = snapshot.data!.docs;
                  print('Number of documents: ${documents.length}');

                  if (documents.isEmpty) {
                    return Center(
                      child: Text('No repair requests assigned'),
                    );
                  }

                  // Sort the documents based on status
                  documents.sort((a, b) {
                    final String statusA = a['status'] ?? '';
                    final String statusB = b['status'] ?? '';
                    if (statusA == 'Completed' && statusB != 'Completed') {
                      return 1;
                    } else if (statusA != 'Completed' && statusB == 'Completed') {
                      return -1;
                    }
                    return 0;
                  });

                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final document = documents[index];
                      return TaskTile(document: document);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class TaskTile extends StatelessWidget {
  final DocumentSnapshot document;

  TaskTile({required this.document});

  @override
  Widget build(BuildContext context) {
    final String itemType = document['itemType'] ?? 'N/A';
    final String issueDescription = document['issueDescription'] ?? 'N/A';
    final String status = document['status'] ?? '';

    IconData iconData;
    switch (itemType) {
      case 'Camera':
        iconData = Icons.camera_alt;
        break;
      case 'Mobile Phone':
        iconData = Icons.phone_android;
        break;
      case 'Tablet':
        iconData = Icons.tablet;
        break;
      case 'Headphones':
        iconData = Icons.headset;
        break;
      default:
        iconData = Icons.device_unknown;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('repair_requests')
                  .doc(document.id) // Use the document id to fetch details
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(child: CircularProgressIndicator());
                }

                final detailedDocument = snapshot.data!;
                final documentId = document.id;
                // Now you have the detailed document, you can pass it to the RequestDetailsScreen
                return RequestDetailsScreen(document: detailedDocument, documentId: documentId,);
              },
            ),
          ),
        );
      },
      child: Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide(color: status == 'Completed' ? Colors.green : Colors.transparent,
          width: 4),
        ),
        child: ListTile(
          leading: Icon(iconData, color: Colors.black),
          title: Text('Item Type: $itemType', style: TextStyle(color: Colors.black)),
          subtitle: Text('Issue Description: $issueDescription', style: TextStyle(color: Colors.black)),
          trailing: status == 'Completed' ? Icon(Icons.done_outline_sharp, color: Colors.grey) : Icon(Icons.arrow_forward_ios, color: Colors.grey),
        ),
      ),
    );
  }
}

