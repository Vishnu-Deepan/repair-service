import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubmitRequestScreen extends StatefulWidget {
  @override
  _SubmitRequestScreenState createState() => _SubmitRequestScreenState();
}

class _SubmitRequestScreenState extends State<SubmitRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _itemTypeController = TextEditingController();
  final TextEditingController _issueDescriptionController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Repair Request'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _itemTypeController,
                decoration: const InputDecoration(labelText: 'Item Type'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the item type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _issueDescriptionController,
                decoration: const InputDecoration(labelText: 'Issue Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the issue description';
                  }
                  return null;
                },
                maxLines: 4,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Get current user ID
      String userId = _auth.currentUser!.uid;

      // Save repair request data to Firestore
      try {
        await FirebaseFirestore.instance.collection('repair_requests').add({
          'assignedMechanic': null,
          'issueDescription': _issueDescriptionController.text,
          'itemType': _itemTypeController.text,
          'onHoldReason': null,
          'status': 'Pending',
          'timestamp': Timestamp.now(),
          'userId': userId,
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Repair request submitted successfully'),
            duration: Duration(seconds: 3),
          ),
        );

        // Clear form fields
        _itemTypeController.clear();
        _issueDescriptionController.clear();
      } catch (e) {
        print(e);
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error submitting repair request'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}