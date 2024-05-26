import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestDetailsScreen extends StatefulWidget {
  final String documentId;
  final DocumentSnapshot<Object?> document;

  const RequestDetailsScreen({
    Key? key,
    required this.documentId,
    required this.document,
  }) : super(key: key);

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  String? selectedStatus;
  String? onHoldReason;

  @override
  void initState() {
    super.initState();
    // Set default value for selectedStatus
    selectedStatus = "pending";
  }

  @override
  Widget build(BuildContext context) {
    final String itemType = widget.document['itemType'] ?? 'N/A';
    final String issueDescription =
        widget.document['issueDescription'] ?? 'N/A';
    final String brand = widget.document['brand'] ?? 'N/A';
    final String model = widget.document['model'] ?? 'N/A';
    final String isRaining = widget.document['isRaining'] ?? 'Clear';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade200, Colors.blue.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top * 1.4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon:
                      Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),
                ),
                Text(
                  'Mechanic Home',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Spacer(),
              ],
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  Card(
                    child: ListTile(
                      title: Text('Item Type'),
                      subtitle: Text(itemType),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text('Issue Description'),
                      subtitle: Text(issueDescription),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text('Brand'),
                      subtitle: Text(brand),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text('Model'),
                      subtitle: Text(model),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  if (widget.document['status'] != "Completed")
                    //Show option to change its status in firebase into - [On Hold or Completed] - please dont use any type of dropdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Confirmation"),
                                  content: Text(
                                      "Are you sure you want to put this request on hold?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Change status to "On Hold" in Firestore
                                        FirebaseFirestore.instance
                                            .collection('repair_requests')
                                            .doc(widget.documentId)
                                            .update({'status': 'On Hold'}).then(
                                                (_) {
                                          // Handle success
                                          setState(() {
                                            // No need to update widget.document since it's immutable
                                          });
                                        }).catchError((error) {
                                          // Handle error
                                          print(
                                              "Failed to update status: $error");
                                        });
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        "Confirm",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors
                                            .redAccent, // Orange background
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // Rectangle shape
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text(
                            'On Hold',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.redAccent, // Orange background
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10), // Rectangle shape
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Confirmation"),
                                  content: Text(
                                      "Completed button action cannot be reverted. Are you sure?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Change status to "Completed" in Firestore
                                        FirebaseFirestore.instance
                                            .collection('repair_requests')
                                            .doc(widget.documentId)
                                            .update({
                                          'status': 'Completed'
                                        }).then((_) {
                                          // Handle success
                                          setState(() {
                                            // No need to update widget.document since it's immutable
                                          });
                                        }).catchError((error) {
                                          // Handle error
                                          print(
                                              "Failed to update status: $error");
                                        });
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'Confirm',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.green, // Green background
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // Rectangle shape
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text(
                            'Completed',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Green background
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10), // Rectangle shape
                            ),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    // height: 50,
                    child: Stack(
                      children: [
                        // Background image representing weather condition
                        Container(
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(_getImagePath(isRaining)),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Black overlay with transparency
                              Container(
                                color: Colors.black54,
                              ),
                              // Overlay text
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                                  child: Text(
                                    _getOverlayText(isRaining),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Function to get overlay text based on weather condition
String _getOverlayText(String weatherCondition) {
  switch (weatherCondition) {
    case 'Rain':
      return "It's raining at customer location, consider later";
    case 'Thunderstorm':
      return "It's thunderstorm at customer location, schedule later";
    case 'Drizzle':
      return "It's drizzling there, it may rain later";
    case 'Clear':
    default:
      return "It's clear weather, no problem";
  }
}

// Function to get image path based on weather condition
String _getImagePath(String weatherCondition) {
  switch (weatherCondition) {
    case 'Rain':
      return 'https://images.newscientist.com/wp-content/uploads/2024/02/06103007/SEI_189745988.jpg';
    case 'Thunderstorm':
      return 'https://images.newscientist.com/wp-content/uploads/2024/02/06103007/SEI_189745988.jpg';
    case 'Drizzle':
      return 'assets/drizzle.jpg';
    case 'Clear':
    default:
      return 'assets/clear.jpg';
  }
}
