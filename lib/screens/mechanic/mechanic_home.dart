import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MechanicHomePage extends StatelessWidget {
  final String mechanicEmail;

  const MechanicHomePage({Key? key, required this.mechanicEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mechanic Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Navigate to New Repair Requests screen
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NewRequestsPage(mechanicEmail: mechanicEmail)));
                },
                child: Card(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'New Repair Requests',
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Navigate to Completed Repair Requests screen
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CompletedRequestsPage(mechanicEmail: mechanicEmail)));
                },
                child: Card(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Completed Repair Requests',
                        style: TextStyle(fontSize: 20.0),
                      ),
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
}

class NewRequestsPage extends StatelessWidget {
  final String mechanicEmail;

  const NewRequestsPage({Key? key, required this.mechanicEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('repair_requests')
            .where('assignedMechanic', isEqualTo: mechanicEmail)
            .where('status', whereIn: ['Pending', 'On Hold', 'assigned'])
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
              child: Text('No new requests'),
            );
          }
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final document = documents[index];
              return TaskTile(document: document);
            },
          );
        },
      ),
    );
  }
}

class CompletedRequestsPage extends StatelessWidget {
  final String mechanicEmail;

  const CompletedRequestsPage({Key? key, required this.mechanicEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Completed Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('repair_requests')
            .where('assignedMechanic', isEqualTo: mechanicEmail)
            .where('status', isEqualTo: 'Completed')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final documents = snapshot.data!.docs;
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final document = documents[index];
              return CompletedTaskTile(document: document);
            },
          );
        },
      ),
    );
  }
}

class TaskTile extends StatefulWidget {
  final DocumentSnapshot document;

  TaskTile({required this.document, Key? key}) : super(key: key);

  @override
  _TaskTileState createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  String? selectedStatus;
  String? onHoldReason;

  @override
  void initState() {
    super.initState();
    // Set default value for selectedStatus
    selectedStatus = widget.document['status'] == 'assigned' ? 'Pending' : widget.document['status'];
  }

  void confirmSelection() {
    if (selectedStatus != null) {
      // Update status in Firestore
      FirebaseFirestore.instance.collection('repair_requests').doc(widget.document.id).update({
        'status': selectedStatus,
        'onHoldReason': selectedStatus == 'On Hold' ? onHoldReason : null,
      });

      // Clear selection
      setState(() {
        selectedStatus = null;
        onHoldReason = null;
      });
    }
  }

  void completeRequest() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Completion'),
          content: Text('Are you sure you want to mark this repair request as completed?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Update status in Firestore
                FirebaseFirestore.instance.collection('repair_requests').doc(widget.document.id).update({
                  'status': 'Completed',
                });

                // Close dialog
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String itemType = widget.document['itemType'] ?? 'N/A';
    final String issueDescription = widget.document['issueDescription'] ?? 'N/A';

    return Card(
      child: ListTile(
        title: Text('Item Type: $itemType'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Issue Description: $issueDescription'),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              items: ['Pending', 'On Hold'].map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedStatus = value;
                });
              },
            ),
            if (selectedStatus == 'On Hold')
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Reason for On Hold',
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                onChanged: (value) {
                  setState(() {
                    onHoldReason = value;
                  });
                },
              ),
            ElevatedButton(
              onPressed: confirmSelection,
              child: Text('Confirm'),
            ),
            ElevatedButton(
              onPressed: completeRequest,
              child: Text('Mark as Completed'),
            ),
          ],
        ),
      ),
    );
  }
}

class CompletedTaskTile extends StatelessWidget {
  final DocumentSnapshot document;

  CompletedTaskTile({required this.document});

  @override
  Widget build(BuildContext context) {
    final String itemType = document['itemType'] ?? 'N/A';
    final String issueDescription = document['issueDescription'] ?? 'N/A';

    return

      Card(
        child: ListTile(
          title: Text('Item Type: $itemType'),
          subtitle: Text('Issue Description: $issueDescription'),
        ),
      );
  }
}