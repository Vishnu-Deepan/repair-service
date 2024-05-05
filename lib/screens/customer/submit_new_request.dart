import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../service/model.dart';

class NewRequestPage extends StatelessWidget {
  final Service gadget;

  const NewRequestPage({Key? key, required this.gadget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RepairForm(gadget: gadget), // Use a separate widget for the repair form
    );
  }
}

class RepairForm extends StatefulWidget {
  final Service gadget;

  const RepairForm({Key? key, required this.gadget}) : super(key: key);

  @override
  _RepairFormState createState() => _RepairFormState();
}

class _RepairFormState extends State<RepairForm> {
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _issueDescriptionController =
  TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _submitRequest() async {
    try {
      // Get current user ID
      String userId = _auth.currentUser!.uid;

      // Get current timestamp
      Timestamp timestamp = Timestamp.now();

      // Construct repair request data
      Map<String, dynamic> requestData = {
        'itemType': widget.gadget.name, // Gadget name as itemType
        'brand': _brandController.text,
        'model': _modelController.text,
        'issueDescription': _issueDescriptionController.text,
        'assignedMechanic': null, // Default to null
        'onHoldReason': null, // Default to null
        'status': 'pending', // Default to "pending"
        'timestamp': timestamp,
        'userId': userId,
      };

      // Add repair request to Firestore
      await _firestore.collection('repair_requests').add(requestData);

      // Show success message or navigate to success screen
      // (not implemented in this example)
    } catch (error) {
      // Handle errors
      print('Error submitting request: $error');
      // Show error message to user
      // (not implemented in this example)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade200, Colors.purple.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
                ),
                Text(
                  'Repair ${widget.gadget.name}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Device Information:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _brandController,
              decoration: InputDecoration(
                labelText: 'Brand',
                labelStyle: TextStyle(color: Colors.white),
                hintText: 'Enter brand name...',
                hintStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)), // Updated border color to transparent
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _modelController,
              decoration: InputDecoration(
                labelText: 'Model',
                labelStyle: TextStyle(color: Colors.white),
                hintText: 'Enter model name...',
                hintStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)), // Updated border color to transparent
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              'Problem Description:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _issueDescriptionController,
              decoration: InputDecoration(
                hintText: 'Enter problem description...',
                hintStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)), // Updated border color to transparent
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _submitRequest, // Call submit function when tapped
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Submit Request",
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
    );
  }

  @override
  void dispose() {
    // Clean up controllers
    _brandController.dispose();
    _modelController.dispose();
    _issueDescriptionController.dispose();
    super.dispose();
  }
}