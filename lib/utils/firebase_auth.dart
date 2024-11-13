import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrollease_web/model/registrar_model.dart';
import 'package:flutter/material.dart';

class FirebaseAuthProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to save user data to Firestore
  Future<void> saveUserData(RegistrarModel registrar) async {
    try {
      // Save user data to Firestore with the generated ID
      await _firestore
          .collection('registrars')
          .doc(registrar.identification) // Use the generated ID here
          .set(registrar.toMap());

      debugPrint(
          "User data saved successfully with ID: ${registrar.identification}.");
    } catch (e) {
      debugPrint("Error saving user data: $e");
    }
  }

  // Method to generate a new identification ID based on the current max ID
  Future<String> generateNewIdentification() async {
    try {
      // Fetch all document IDs from the 'registrars' collection
      final querySnapshot = await _firestore.collection('registrars').get();

      // If the collection is empty, start with the first ID (e.g., SDA24-000000)
      if (querySnapshot.docs.isEmpty) {
        return 'SDA${DateTime.now().year % 100}-000000';
      }

      // Extract the last document ID and parse the numeric part
      final lastDoc = querySnapshot.docs.last.id;
      final yearPrefix = 'SDA${DateTime.now().year % 100}-';

      // Check if the last ID starts with the current year prefix
      if (!lastDoc.startsWith(yearPrefix)) {
        return '${yearPrefix}000000'; // If not, return the first ID for this year
      }

      // Extract the numeric part and increment it
      final lastNumber = int.parse(lastDoc.substring(yearPrefix.length));
      final newIncrement = (lastNumber + 1).toString().padLeft(6, '0');

      // Generate the new ID
      return '$yearPrefix$newIncrement';
    } catch (e) {
      debugPrint("Error generating new identification ID: $e");
      return 'SDA${DateTime.now().year % 100}-000000'; // Fallback to first ID if error occurs
    }
  }

  // Method to sign in using identification and password
  Future<bool> signIn(String identification, String password) async {
    try {
      // Fetch the document with the specified identification
      final docSnapshot =
          await _firestore.collection('registrars').doc(identification).get();

      // Check if document exists and if the password matches
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final storedPassword = data?['password'];

        if (storedPassword == password) {
          debugPrint("Sign-in successful for ID: $identification");
          return true; // Sign-in successful
        } else {
          debugPrint("Incorrect password for ID: $identification");
          return false; // Incorrect password
        }
      } else {
        debugPrint("Identification not found: $identification");
        return false; // Identification not found
      }
    } catch (e) {
      debugPrint("Error during sign-in: $e");
      return false; // Sign-in error
    }
  }
}
