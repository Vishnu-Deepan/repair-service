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
  List<String> _mechanicEmails = [];

  @override
  void initState() {
    super.initState();
    _fetchMechanicEmails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade100, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            margin: EdgeInsets.only(right: 16.0,left: 16.0,bottom: 300.0,top: 300.0),
            padding: EdgeInsets.only(right: 16.0,left: 16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade100, Colors.blue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('repair_requests')
                  .doc(widget.requestId)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Text('Request not found');
                }

                var request = snapshot.data!;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${request['brand']} ${request['model']}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Issue Description: ${request['issueDescription']}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      value: _selectedMechanicEmail,
                      hint: Text(
                        request['assignedMechanic']??"Select Mechanic",
                        style: TextStyle(color: Colors.black),
                      ),
                      items: _mechanicEmails.map((mechanicEmail) {
                        return DropdownMenuItem(
                          value: mechanicEmail,
                          child: Text(
                            mechanicEmail,
                            style: TextStyle(color: Colors.black),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMechanicEmail = value;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: request['status'] == 'pending'
                          ? () {
                        _assignMechanic(request.id, _selectedMechanicEmail);
                      }
                          : null, // Set onPressed to null when status is not Pending
                      child: Text('Assign Mechanic'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.yellow[400],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.all(10.0),
                      child: Center(
                        child: Text(
                          'Request Status: ${request['status']}',
                          style: TextStyle(
                            // color: request['status']!=="pending",
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
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
        // Navigate back to OwnerHomePage
        Navigator.pop(context);
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