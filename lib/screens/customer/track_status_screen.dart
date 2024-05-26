import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class TrackStatusScreen extends StatefulWidget {
  const TrackStatusScreen({Key? key});

  @override
  _TrackStatusScreenState createState() => _TrackStatusScreenState();
}

class _TrackStatusScreenState extends State<TrackStatusScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
        child: Column(
          children: [
            SizedBox(
                height:
                    MediaQuery.of(context).padding.top * 1.4), // Top spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon:
                      Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
                ),
                Text(
                  'Past Requests',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
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
            ),
          ],
        ),
      ),
    );
  }
}

class RequestTile extends StatelessWidget {
  final QueryDocumentSnapshot request;

  const RequestTile({Key? key, required this.request}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.white, // Set card background color to white
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(4), // Set border radius to make it sharper
      ),
      child: ListTile(
        title: Text(
          '${request['brand'] ?? 'N/A'}  ${request['model'] ?? 'N/A'}',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${request['itemType'] ?? 'N/A'}',
              style: GoogleFonts.inter(),
            ),
            Text(
              'Issue Description: ${request['issueDescription'] ?? 'N/A'}',
              style: GoogleFonts.inter(),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RequestDetailsScreen(request: request),
            ),
          );
        },
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: request['status'] == 'Completed'
                ? Colors
                    .greenAccent[200] // Set color to green for completed tasks
                : request['status'] == 'pending'
                    ? Colors.redAccent[100]
                    : // Set color to red for pending tasks
                    Colors.yellowAccent[
                        100], // Set color to yellow for other tasks
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            request['status'],
            style: TextStyle(
              color: Colors.black, // Set text color to white
            ),
          ),
        ),
      ),
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
        leading: IconButton(onPressed: () { Navigator.pop(context); }, icon: Icon(Icons.arrow_back_ios_new),color: Colors.white,iconSize: 17,),
        title: const Text(
          'Request Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.purple.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ListTile(
              title: const Text(
                'Item Type',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(request['itemType'] ?? 'N/A'),
            ),
            ListTile(
              title: const Text(
                'Issue Description',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(request['issueDescription'] ?? 'N/A'),
            ),
            ListTile(
              title: const Text(
                'Assigned Mechanic',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(request['assignedMechanic'] ?? 'N/A'),
            ),
            ListTile(
              title: const Text(
                'On Hold Reason',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(request['onHoldReason'] ?? 'N/A'),
            ),
            ListTile(
              title: const Text(
                'Status',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(request['status'] ?? 'N/A'),
            ),
          ],
        ),
      ),
    );
  }
}
