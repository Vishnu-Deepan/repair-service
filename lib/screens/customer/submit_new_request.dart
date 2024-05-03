import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubmitRequestScreen extends StatefulWidget {
  @override
  _SubmitRequestScreenState createState() => _SubmitRequestScreenState();
}

class _SubmitRequestScreenState extends State<SubmitRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _itemTypeController = TextEditingController();
  final TextEditingController _issueDescriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Repair Request'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _itemTypeController,
                decoration: InputDecoration(labelText: 'Item Type'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the item type';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _issueDescriptionController,
                decoration: InputDecoration(labelText: 'Issue Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the issue description';
                  }
                  return null;
                },
                maxLines: 4,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Save repair request data to Firestore
      try {
        await FirebaseFirestore.instance.collection('repair_requests').add({
          'itemType': _itemTypeController.text,
          'issueDescription': _issueDescriptionController.text,
          'timestamp': Timestamp.now(),
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
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
          SnackBar(
            content: Text('Error submitting repair request'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}