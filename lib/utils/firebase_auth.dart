import 'package:appwrite/appwrite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrollease_web/appwrite.dart';
import 'package:enrollease_web/dev.dart';
import 'package:enrollease_web/model/fetching_registrar_model.dart';
import 'package:enrollease_web/model/registrar_model.dart';
import 'package:enrollease_web/states_management/account_data_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/v4.dart';

class FirebaseAuthProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FetchingRegistrarModel? currentRegistrar;

  // Method to save user data to Firestore
  Future<void> saveUserData(RegistrarModel registrar) async {
    try {
      // Save user data to Firestore with the generated ID
      await _firestore
          .collection('registrars')
          .doc(registrar.id) // Use the generated ID here
          .set(registrar.toMap());

      dPrint('User data saved successfully with ID: ${registrar.id}.');
    } catch (e) {
      dPrint('Error saving user data: $e');
    }
  }

  /// Updates the `status` field of a document in the `enrollment_forms` collection
  /// using `regNo` as the document ID.
  Future<String?> updateStatus(String regNo, String newStatus) async {
    try {
      // Access the document directly using the regNo as the document ID
      DocumentReference docRef = _firestore.collection('enrollment_forms').doc(regNo);

      // Update the `status` field
      await docRef.update({'status': newStatus});
      return null;
    } catch (e) {
      dPrint(e);
      return e.toString();
    }
  }

  // Method to generate a new id ID based on the current max ID
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
      dPrint('Error generating new id ID: $e');
      return 'SDA${DateTime.now().year % 100}-000000'; // Fallback to first ID if error occurs
    }
  }

  // Method to sign in using id and password
  Future<bool> signIn(BuildContext context, String id, String password) async {
    try {
      // Start loading
      Provider.of<AccountDataController>(context, listen: false).setLoading(true);

      // Get user data from Firestore using id
      final docSnapshot = await _firestore.collection('registrars').doc(id).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final storedPassword = data?['password'];

        if (storedPassword == password) {
          dPrint('Sign-in successful for ID: $id');

          // Create FetchingRegistrarModel from Firestore data
          FetchingRegistrarModel? registrar;
          if (data != null) {
            registrar = FetchingRegistrarModel.fromMap(id, data);
          }

          // Set registrar data in AccountDataController
          if (context.mounted) {
            await Provider.of<AccountDataController>(context, listen: false).setRegistrarData(registrar: registrar);
          }

          // Optionally, notify that sign-in was successful
          dPrint('User data successfully set in AccountDataController.');

          return true;
        } else {
          dPrint('Incorrect password for ID: $id');
          return false;
        }
      } else {
        dPrint('ID not found: $id');
        return false;
      }
    } catch (e) {
      dPrint('Error during sign-in: $e');
      return false;
    } finally {
      // Stop loading after the process is complete
      if (context.mounted) {
        Provider.of<AccountDataController>(context, listen: false).setLoading(false);
      }
    }
  }

  Future<bool> updateRegistrarField({
    required String documentId,
    required Map<String, dynamic> updatedFields,
  }) async {
    try {
      // Reference the specific document in the 'registrars' collection
      final documentRef = FirebaseFirestore.instance.collection('registrars').doc(documentId);

      // Update the specified fields
      await documentRef.update(updatedFields);

      dPrint('Fields updated successfully for registrar: $documentId');
      return true;
    } catch (e) {
      dPrint('Error updating registrar fields: $e');
      return false;
    }
  }

  // Method to fetch the total number of users in the 'users' collection
  Stream<int> getTotalUsersStream() {
    try {
      return _firestore
          .collection('users')
          .snapshots() // Listen to changes in the 'users' collection
          .map((querySnapshot) => querySnapshot.size); // Map to the count of documents
    } catch (e) {
      dPrint('Error fetching total users: $e');
      return Stream.value(0); // Return 0 in case of an error
    }
  }

  // Stream to fetch the total number of 'pending' enrollment forms
  Stream<int> getTotalPendingEnrollments() {
    try {
      return _firestore
          .collection('enrollment_forms')
          .where('status', isEqualTo: 'pending') // Filter documents where status is 'pending'
          .snapshots() // Listen to changes in the filtered 'enrollment_forms' collection
          .map((querySnapshot) => querySnapshot.size); // Map to the count of documents
    } catch (e) {
      dPrint('Error fetching enrollment forms: $e');
      return Stream.value(0); // Return 0 in case of an error
    }
  }

  // Stream to fetch the total number of 'pending' enrollment forms
  Stream<int> getTotalEnrollments() {
    try {
      return _firestore
          .collection('enrollment_forms')
          .snapshots() // Listen to changes in the filtered 'enrollment_forms' collection
          .map((querySnapshot) => querySnapshot.size); // Map to the count of documents
    } catch (e) {
      dPrint('Error fetching enrollment forms: $e');
      return Stream.value(0); // Return 0 in case of an error
    }
  }

  //add notifications
  Future<void> addNotification({
    required String content, // Notification content
    required String type, // "user" or "global"
    required String uid, // User ID for "user" notifications, '' for "global"
  }) async {
    try {
      // Reference to the Firestore notifications collection
      final notificationsCollection = FirebaseFirestore.instance.collection('notifications');

      // Create the notification data
      final notificationData = {
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'type': type,
        'uid': type == 'user' ? uid : '', // Only set uid for user-specific notifications
        'isRead': false, // Default to false
      };

      // Add the notification document
      await notificationsCollection.add(notificationData);

      dPrint('Notification added successfully!');
    } catch (e) {
      dPrint('Error adding notification: $e');
    }
  }

  Future<Uint8List?> getProfilePic(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '--';
    if (userId.isEmpty) throw ('cannot get profile pic, id is empty!');
    final data = await FirebaseFirestore.instance.collection('registrars').doc(userId).get();
    try {
      if (!data.exists) {
        dPrint('data doesnt exist!');
        return null;
      }
      final account = FetchingRegistrarModel.fromMap(data.id, data.data()!);
      final bytes = await storage.getFileView(
        bucketId: bucketIDProfilePics,
        fileId: account.profilePicLink,
      );
      if (bytes.isEmpty) {
        return null;
      }
      return bytes;
    } catch (e) {
      dPrint(e.toString());
      return null;
    }
  }

  Future<String?> changeProfilePic(String registrarID, PlatformFile file) async {
    if (registrarID.isEmpty) throw ('cannot update, id is empty!!');
    final mimeType = kIsWeb ? lookupMimeType('', headerBytes: file.bytes) : lookupMimeType(file.path!);
    // dPrint(mimeType);
    try {
      final data = await FirebaseFirestore.instance.collection('registrars').doc(registrarID).get();
      if (!data.exists) {
        dPrint('data doesnt exist!!');
        return null;
      }
      final account = FetchingRegistrarModel.fromMap(data.id, data.data()!);
      // remove previous, because appwrite doesn't allow file overwrite
      try {
        await storage.deleteFile(bucketId: bucketIDProfilePics, fileId: account.profilePicLink);
      } catch (e) {
        dPrint('deleting profilepic error: $e');
      }
      final newID = const UuidV4().generate();
      final response = await storage.createFile(
        bucketId: bucketIDProfilePics, // Replace with your bucket ID
        fileId: newID,
        file: InputFile.fromBytes(
          bytes: file.bytes!,
          filename: newID,
          contentType: mimeType,
        ),
      );
      await FirebaseFirestore.instance.collection('registrars').doc(registrarID).update(
            account.copyWith(profilePicLink: newID).toMap(),
          );
      dPrint('File uploaded: ${response.$id}');
      return null;
    } catch (e) {
      dPrint('Error uploading file: $e');
      return e.toString();
    }
  }

  Future<String?> changeEmail(String uid, String email) async {
    try {
      await _firestore.collection('registrars').doc(uid).update({'email': email});
      return null;
    } catch (e) {
      dPrint(e);
      return e.toString();
    }
  }

  Future<String?> changePass(String uid, String pass) async {
    try {
      // await _auth.currentUser!.updatePassword(pass);
      await _firestore.collection('registrars').doc(uid).update({'password': pass});
      return null;
    } catch (e) {
      dPrint(e);
      return e.toString();
    }
  }

  Future<String?> changeContactNo(String uid, String contactNo) async {
    try {
      // TODO: do OTP later?
      // await _auth.verifyPhoneNumber(
      //   verificationCompleted: (cred) {},
      //   verificationFailed: (e) {},
      //   codeSent: (verificationID, forceSendingToken) {},
      //   codeAutoRetrievalTimeout: (verificationID) {},
      // );
      await _firestore.collection('registrars').doc(uid).update({'contact': contactNo});
      return null;
    } catch (e) {
      dPrint(e);
      return e.toString();
    }
  }
}
