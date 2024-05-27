import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final String latitude = widget.document['latitude'].toString();
    final String longitude = widget.document['longitude'].toString();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade200, Colors.blue.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(8.0),
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
                  icon: const Icon(Icons.arrow_back_ios_new_sharp,
                      color: Colors.white),
                ),
                const Text(
                  'Mechanic Home',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Card(
                    child: ListTile(
                      title: const Text('Item Type'),
                      subtitle: Text(itemType),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Issue Description'),
                      subtitle: Text(issueDescription),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Brand'),
                      subtitle: Text(brand),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Model'),
                      subtitle: Text(model),
                    ),
                  ),
                  const SizedBox(
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
                                  title: const Text("Confirmation"),
                                  content: const Text(
                                      "Are you sure you want to put this request on hold?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Cancel"),
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
                                      child: const Text(
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
                          child: const Text(
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
                                  title: const Text("Confirmation"),
                                  content: const Text(
                                      "Completed button action cannot be reverted. Are you sure?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Cancel"),
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
                                      child: const Text(
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
                          child: const Text(
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
                  const SizedBox(
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                // Background image
                                Image.network(
                                  _getImagePath(isRaining),
                                  fit: BoxFit.cover,
                                  width: MediaQuery.of(context).size.width,
                                  height: 200,
                                ),
                                // Black overlay with transparency
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                // Overlay text
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 28.0),
                                    child: Text(
                                      _getOverlayText(isRaining),
                                      style: const TextStyle(
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
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: () {
                      navigateToLocation(latitude, longitude);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "Navigate To Location",
                          style: GoogleFonts.capriola(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void navigateToLocation(String latitude, String longitude) async {
  final url =
      'https://www.google.com/maps?q=$latitude,$longitude'; // Replace "Your Location Name" with a descriptive name
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Could not launch Google Maps.';
  }
}

// Function to get overlay text based on weather condition
String _getOverlayText(String weatherCondition) {
  switch (weatherCondition) {
    case 'Rain':
      return "️🌧️ Consider Rescheduling!";
    case 'Thunderstorm':
      return "⚡️ Hold off! Reschedule for calmer skies.";
    case 'Drizzle':
      return "️ Light drizzle. Keep an eye on the forecast.";
    case 'Clear':
      return "☀️ Perfect weather for a repair!";
    default:
      return "❄️ Snowy! Reschedule for warmer days.";
  }
}

// Function to get image path based on weather condition
String _getImagePath(String weatherCondition) {
  switch (weatherCondition) {
    case 'Rain':
      return 'https://wallpapers.com/images/hd/rain-background-0gxckn1rxnuwpake.jpg';
    case 'Thunderstorm':
      return 'https://images.newscientist.com/wp-content/uploads/2024/02/06103007/SEI_189745988.jpg';
    case 'Drizzle':
      return 'https://t3.ftcdn.net/jpg/00/00/51/58/360_F_515820_0FGvwS7d9XgiEsuQ4S7d9WghijGPZj.jpg';
    case 'Clear':
      return 'https://media.istockphoto.com/id/138295858/photo/green-rice-fild-with-evening-sky.jpg?s=612x612&w=0&k=20&c=NUhiKLDCPN_AGEjgRVPBRHyFsZXCCEwLDZVNUTFbjGc=';
    default:
      return 'https://wallpapers.com/images/hd/snowfall-hbzhowjy48hbrs5q.jpg';
  }
}
