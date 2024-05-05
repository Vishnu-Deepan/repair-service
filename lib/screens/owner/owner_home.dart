import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'request_detail.dart';


class OwnerHomePage extends StatelessWidget {
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
            SizedBox(height: MediaQuery.of(context).padding.top * 1.4),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Owner Dashboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.logout_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top:18.0,left: 18,right:18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AssignedUnassignedCount(
                    status: 'assigned',
                    icon: Icons.assignment_turned_in,
                  ),
                  AssignedUnassignedCount(
                    status: 'pending',
                    icon: Icons.assignment_late,
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('repair_requests')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
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
                      Icon icon;
                      switch (request['itemType']) {
                        case 'Camera':
                          icon = Icon(Icons.camera_alt);
                          break;
                        case 'Mobile Phone':
                          icon = Icon(Icons.phone_android);
                          break;
                        case 'Tablet':
                          icon = Icon(Icons.tablet);
                          break;
                        case 'Headphones':
                          icon = Icon(Icons.headset);
                          break;
                        default:
                          icon = Icon(Icons.device_unknown);
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: Card(
                          color: Colors.transparent,
                          elevation: 0, // Remove card elevation
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.5),
                                  Colors.white.withOpacity(0.5),
                                  Colors.white.withOpacity(0.5),
                                  getTrailingColor(
                                      request['status']), // Use red or green based on status
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius:
                              BorderRadius.circular(10.0), // Add border radius
                            ),
                            child: ListTile(
                              leading: icon,
                              title: Text(
                                request['itemType'],
                                style: TextStyle(color: Colors.black),
                              ),
                              subtitle: Text(
                                request['issueDescription'],
                                style: TextStyle(color: Colors.black),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                              ),
                              onTap: () {
                                // Navigate to request details screen or implement action
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RequestDetailsScreen(
                                      requestId: request.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
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


  Color getTrailingColor(String status) {
    return status == 'pending' ? Colors.red : Colors.green;
  }
}


class AssignedUnassignedCount extends StatelessWidget {
  final String status;
  final IconData icon;

  const AssignedUnassignedCount({
    required this.status,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('repair_requests')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        final documents = snapshot.data!.docs;
        int count = 0;
        for (var document in documents) {
          final documentStatus = document['status'];
          print('Status: $status, Document Status: $documentStatus');
          if (status == 'pending' && documentStatus == 'pending') {
            count++;
          } else if (status == 'assigned' && documentStatus != 'pending') {
            count++;
          }
        }
        return Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1,
              colors: status == 'assigned'
                  ? [Colors.green.withOpacity(0.8), Colors.green]
                  : [Colors.red.withOpacity(0.8), Colors.red],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text(
                  status == 'assigned'
                      ? 'Assigned : $count'
                      : 'Unassigned : $count',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}