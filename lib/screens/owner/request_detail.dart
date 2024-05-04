import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestDetailsScreen extends StatefulWidget {
  final String requestId;

  RequestDetailsScreen({required this.requestId});

  @override
  _RequestDetailsScreenState createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  String? _selectedMechanicEmail;
  List<String> _mechanicEmails = []; // List to store available mechanic emails

  @override
  void initState() {
    super.initState();
    _fetchMechanicEmails(); // Fetch mechanic emails when the screen initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Details'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('repair_requests').doc(widget.requestId).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Request not found'));
          }

          var request = snapshot.data!;
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Item Type: ${request['itemType']}',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Issue Description: ${request['issueDescription']}',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _selectedMechanicEmail,
                  hint: Text('Select Mechanic'),
                  items: _mechanicEmails.map((mechanicEmail) {
                    return DropdownMenuItem(
                      value: mechanicEmail,
                      child: Text(mechanicEmail),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMechanicEmail = value;
                    });
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    _assignMechanic(request.id, _selectedMechanicEmail);
                  },
                  child: Text('Assign Mechanic'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _fetchMechanicEmails() {
    FirebaseFirestore.instance.collection('mechanics').get().then((querySnapshot) {
      setState(() {
        _mechanicEmails = querySnapshot.docs.map((doc) => doc['email'] as String).toList();
      });
    }).catchError((error) {
      print('Error fetching mechanic emails: $error');
    });
  }

  void _assignMechanic(String requestId, String? mechanicEmail) {
    if (mechanicEmail != null) {
      FirebaseFirestore.instance.collection('repair_requests').doc(requestId).update({
        'status': "assigned to a mechanic"
      });

          FirebaseFirestore.instance.collection('repair_requests').doc(requestId).update({
        'assignedMechanic': mechanicEmail,
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mechanic assigned successfully'),
            duration: Duration(seconds: 3),
          ),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to assign mechanic: $error'),
            duration: Duration(seconds: 3),
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a mechanic'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}