import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static Future<void> addMechanic(String name, String email) async {
    try {
      await FirebaseFirestore.instance.collection('mechanics').add({
        'name': name,
        'email': email,
        // Add other fields as needed
      });
      print('Mechanic added successfully');
    } catch (e) {
      print('Failed to add mechanic: $e');
      throw e; // Propagate the error for handling in the UI
    }
  }
// Add other Firestore-related functions as needed
}
