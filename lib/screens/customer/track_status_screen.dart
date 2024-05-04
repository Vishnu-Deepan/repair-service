import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrackStatusScreen extends StatefulWidget {
  @override
  _TrackStatusScreenState createState() => _TrackStatusScreenState();
}

class _TrackStatusScreenState extends State<TrackStatusScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Request Status'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('repair_requests')
            .where('userId', isEqualTo: _auth.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return RequestTile(
                request: request,
              );
            },
          );
        },
      ),
    );
  }
}

class RequestTile extends StatelessWidget {
  final QueryDocumentSnapshot request;

  const RequestTile({Key? key, required this.request}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      trailing: Text(request['status']),
      title: Text(request['itemType'] ?? 'N/A'),
      subtitle: Text(request['issueDescription'] ?? 'N/A'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestDetailsScreen(request: request),
          ),
        );
      },
    );
  }
}

class RequestDetailsScreen extends StatelessWidget {
  final QueryDocumentSnapshot request;

  const RequestDetailsScreen({Key? key, required this.request})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Details'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: Text('Item Type'),
            subtitle: Text(request['itemType'] ?? 'N/A'),
          ),
          ListTile(
            title: Text('Issue Description'),
            subtitle: Text(request['issueDescription'] ?? 'N/A'),
          ),
          ListTile(
            title: Text('Assigned Mechanic'),
            subtitle: Text(request['assignedMechanic'] ?? 'N/A'),
          ),
          ListTile(
            title: Text('On Hold Reason'),
            subtitle: Text(request['onHoldReason'] ?? 'N/A'),
          ),
          ListTile(
            title: Text('Status'),
            subtitle: Text(request['status'] ?? 'N/A'),
          ),

        ],
      ),
    );
  }
}