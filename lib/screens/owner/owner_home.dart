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
            SizedBox(
                height:
                MediaQuery.of(context).padding.top * 1.4), // Top spacing
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Assign Mechanic',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
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
                            vertical: 8.0, horizontal: 16.0),
                        child: Card(
                          color: Colors.white.withOpacity(0.2),
                          child: ListTile(
                            leading: icon,
                            title: Text(request['itemType'],
                                style: TextStyle(color: Colors.white)),
                            subtitle: Text(request['issueDescription'],
                                style: TextStyle(color: Colors.white)),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                            ),
                            onTap: () {
                              // Navigate to request details screen or implement action
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RequestDetailsScreen(requestId: request.id),
                                ),
                              );
                            },
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
}