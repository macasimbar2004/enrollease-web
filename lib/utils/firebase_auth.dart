import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrollease_web/dev.dart';
import 'package:enrollease_web/model/admin_model.dart';
import 'package:enrollease_web/model/enrollment_form_model.dart';
import 'package:enrollease_web/model/faculty_staff_model.dart';
import 'package:enrollease_web/model/fetching_registrar_model.dart';
import 'package:enrollease_web/model/registrar_model.dart';
import 'package:enrollease_web/states_management/account_data_controller.dart';
import 'package:enrollease_web/utils/efficient_grade_service.dart';
import 'package:enrollease_web/utils/grade_level_utils.dart';
import 'package:enrollease_web/services/faculty_activity_service.dart';
import 'package:enrollease_web/model/faculty_activity_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class FirebaseAuthProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FetchingRegistrarModel? currentRegistrar;

  // Method to save user data to Firestore (Legacy - for backward compatibility)
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

  // Method to save faculty/staff data to Firestore (New)
  Future<void> saveFacultyStaffData(FacultyStaffModel facultyStaff) async {
    try {
      // Save faculty/staff data to Firestore with the generated ID
      await _firestore
          .collection('faculty_staff')
          .doc(facultyStaff.id) // Use the generated ID here
          .set(facultyStaff.toMap());

      dPrint(
          'Faculty/Staff data saved successfully with ID: ${facultyStaff.id}.');
    } catch (e) {
      dPrint('Error saving faculty/staff data: $e');
    }
  }

  /// Updates the `status` field of a document in the `enrollment_forms` collection
  /// using `regNo` as the document ID.
  Future<String?> updateStatus(String regNo, String newStatus,
      {String? pdfBase64}) async {
    try {
      // Access the document directly using the regNo as the document ID
      DocumentReference docRef =
          _firestore.collection('enrollment_forms').doc(regNo);

      // Update the `status` field and optionally the `pdfBase64` field
      await docRef.update({
        'status': newStatus,
        if (pdfBase64 != null) 'pdfBase64': pdfBase64,
      });
      return null;
    } catch (e) {
      dPrint(e);
      return e.toString();
    }
  }

  // Method to generate a new ID based on the current max ID for any collection
  Future<String> generateNewIdentification({
    required String collectionName,
    required String prefix,
    int padding = 6,
    bool includeYear = true,
  }) async {
    try {
      // Fetch all document IDs from the specified collection
      final querySnapshot = await _firestore.collection(collectionName).get();

      // If the collection is empty, start with the first ID
      if (querySnapshot.docs.isEmpty) {
        final yearSuffix = includeYear ? '${DateTime.now().year % 100}-' : '';
        return '$prefix$yearSuffix${'0'.padLeft(padding, '0')}';
      }

      // Extract the last document ID
      final lastDoc = querySnapshot.docs.last.id;
      final yearSuffix = includeYear ? '${DateTime.now().year % 100}-' : '';
      final fullPrefix = '$prefix$yearSuffix';

      // Check if the last ID starts with the current prefix
      if (!lastDoc.startsWith(fullPrefix)) {
        return '$fullPrefix${'0'.padLeft(padding, '0')}';
      }

      // Extract the numeric part and increment it
      final lastNumber = int.parse(lastDoc.substring(fullPrefix.length));
      final newIncrement = (lastNumber + 1).toString().padLeft(padding, '0');

      // Generate the new ID
      return '$fullPrefix$newIncrement';
    } catch (e) {
      dPrint('Error generating new ID for $collectionName: $e');
      final yearSuffix = includeYear ? '${DateTime.now().year % 100}-' : '';
      return '$prefix$yearSuffix${'0'.padLeft(padding, '0')}';
    }
  }

  // Method to sign in using id and password
  Future<bool> signIn(BuildContext context, String id, String password) async {
    try {
      // Start loading
      Provider.of<AccountDataController>(context, listen: false)
          .setLoading(true);

      // First try to get user data from admin collection
      var docSnapshot = await _firestore.collection('admins').doc(id).get();
      var collectionName = 'admins';

      // If not found in admins, try faculty_staff collection
      if (!docSnapshot.exists) {
        docSnapshot =
            await _firestore.collection('faculty_staff').doc(id).get();
        collectionName = 'faculty_staff';
      }

      // If not found in faculty_staff, try registrars collection (legacy)
      if (!docSnapshot.exists) {
        docSnapshot = await _firestore.collection('registrars').doc(id).get();
        collectionName = 'registrars';
      }

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final storedPassword = data?['password'];

        if (storedPassword == password) {
          dPrint(
              'Sign-in successful for ID: $id from $collectionName collection');

          // Create FetchingRegistrarModel from Firestore data
          final registrar = FetchingRegistrarModel(
            profilePicData: data?['profilePicData'] ?? '',
            id: data?['id'] ?? '',
            lastName: data?['lastName'] ?? '',
            firstName: data?['firstName'] ?? '',
            middleName: data?['middleName'] ?? '',
            dateOfBirth: data?['dateOfBirth'] ?? '',
            age: data?['age'] ?? '',
            contact: data?['contact'] ?? '',
            placeOfBirth: data?['placeOfBirth'] ?? '',
            address: data?['address'] ?? '',
            email: data?['email'] ?? '',
            remarks: data?['remarks'] ?? '',
            nameExtension: data?['nameExtension'] ?? '', // Nullable
            password: data?['password'] ?? '',
            jobLevel: data?['jobLevel'] ?? '',
            // Load RBAC fields
            userType: data?['userType'],
            roles: data?['roles'] != null
                ? List<String>.from(data!['roles'])
                : null,
            status: data?['status'],
            gradeLevel: data?['gradeLevel'],
            profilePicLink: data?['profilePicLink'],
          );

          // Set registrar data in AccountDataController
          if (context.mounted) {
            await Provider.of<AccountDataController>(context, listen: false)
                .setRegistrarData(registrar: registrar);
          }

          // Optionally, notify that sign-in was successful
          dPrint('User data successfully set in AccountDataController.');

          // Log login activity
          final fullName =
              '${registrar.firstName} ${registrar.middleName} ${registrar.lastName}'
                  .trim();
          await FacultyActivityService.logActivity(
            facultyId: id,
            facultyName: fullName,
            activityType: FacultyActivityModel.login,
            description: 'Logged into the system',
            metadata: {
              'collection': collectionName,
              'userType': registrar.userType,
              'roles': registrar.roles,
            },
          );

          return true;
        } else {
          dPrint('Incorrect password for ID: $id');
          return false;
        }
      } else {
        dPrint('ID not found: $id in both collections');
        return false;
      }
    } catch (e) {
      dPrint('Error during sign-in: $e');
      return false;
    } finally {
      // Stop loading after the process is complete
      if (context.mounted) {
        Provider.of<AccountDataController>(context, listen: false)
            .setLoading(false);
      }
    }
  }

  Future<bool> updateRegistrarField({
    required String documentId,
    required Map<String, dynamic> updatedFields,
  }) async {
    try {
      // Try to update in faculty_staff collection first (new)
      try {
        final documentRef = FirebaseFirestore.instance
            .collection('faculty_staff')
            .doc(documentId);
        await documentRef.update(updatedFields);
        dPrint('Fields updated successfully in faculty_staff for: $documentId');
        return true;
      } catch (e) {
        // If not found in faculty_staff, try registrars collection (legacy)
        final documentRef =
            FirebaseFirestore.instance.collection('registrars').doc(documentId);
        await documentRef.update(updatedFields);
        dPrint('Fields updated successfully in registrars for: $documentId');
        return true;
      }
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
          .map((querySnapshot) =>
              querySnapshot.size); // Map to the count of documents
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
          .where('status',
              isEqualTo:
                  'pending') // Filter documents where status is 'pending'
          .snapshots() // Listen to changes in the filtered 'enrollment_forms' collection
          .map((querySnapshot) =>
              querySnapshot.size); // Map to the count of documents
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
          .map((querySnapshot) =>
              querySnapshot.size); // Map to the count of documents
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
    String? targetType, // 'registrar', 'parent', or 'all'
  }) async {
    try {
      // Reference to the Firestore notifications collection
      final notificationsCollection =
          FirebaseFirestore.instance.collection('notifications');

      // Generate custom notification ID
      final notifId = await generateNewIdentification(
        collectionName: 'notifications',
        prefix: 'NOTIF',
        padding: 6,
        includeYear: true,
      );

      // Create the notification data
      final notificationData = {
        'title':
            type == 'registrar' ? 'Registrar Activity' : 'Enrollment Update',
        'message': content,
        'type': type == 'registrar' ? 'info' : 'success',
        'userId': uid,
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
        'targetType': targetType ?? '',
      };

      // Add the notification document with custom ID
      await notificationsCollection.doc(notifId).set(notificationData);

      dPrint('Notification added successfully!');
    } catch (e) {
      dPrint('Error adding notification: $e');
    }
  }

  Future<Uint8List?> getProfilePic(BuildContext context) async {
    var userId =
        context.read<AccountDataController>().currentRegistrar?.id ?? '';

    // If userId is empty, retry a few times to get it
    if (userId.isEmpty) {
      dPrint('User ID is empty. Will retry to retrieve it...');
      // Retry 3 times with a delay between each attempt
      for (int i = 0; i < 3; i++) {
        // Wait a moment before retrying
        await Future.delayed(Duration(milliseconds: 500 * (i + 1)));

        // Try to get the user ID again
        if (context.mounted) {
          userId =
              context.read<AccountDataController>().currentRegistrar?.id ?? '';
          dPrint('Retry ${i + 1}: User ID = $userId');
        }

        if (userId.isNotEmpty) {
          dPrint('Successfully retrieved user ID after ${i + 1} retries');
          break;
        }
      }
    }

    // If still empty after retries, try to reload from SharedPreferences
    if (userId.isEmpty) {
      dPrint(
          'User ID still empty after retries. Attempting to reload from SharedPreferences...');
      // Request a reload of user data
      if (context.mounted) {
        await Provider.of<AccountDataController>(context, listen: false)
            .reloadUserData();

        if (context.mounted) {
          userId =
              context.read<AccountDataController>().currentRegistrar?.id ?? '';
        }
      }
    }

    // If still empty, return null
    if (userId.isEmpty) {
      dPrint('Could not retrieve user ID after multiple attempts');
      return null;
    }

    try {
      // Try to get the document from faculty_staff collection first (new)
      var docSnapshot =
          await _firestore.collection('faculty_staff').doc(userId).get();

      // If not found in faculty_staff, try registrars collection (legacy)
      if (!docSnapshot.exists) {
        docSnapshot =
            await _firestore.collection('registrars').doc(userId).get();
      }

      // Check if document exists and has profilePicData field
      if (docSnapshot.exists && docSnapshot.data()?['profilePicData'] != null) {
        // Decode the base64 string to bytes
        String base64String = docSnapshot.data()?['profilePicData'];
        return base64Decode(base64String);
      }
      dPrint('No profile picture found in Firestore');
      return null;
    } catch (e) {
      dPrint('Error getting profile picture: $e');
      return null;
    }
  }

  Future<String?> changeProfilePic(String userID, PlatformFile file) async {
    if (userID.isEmpty) throw ('User ID was blank!');

    try {
      // Convert image bytes to base64
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        return 'Invalid image file';
      }

      final base64String = base64Encode(bytes);

      // Try to update in faculty_staff collection first (new)
      try {
        await _firestore.collection('faculty_staff').doc(userID).update({
          'profilePicData': base64String,
        });
      } catch (e) {
        // If not found in faculty_staff, try registrars collection (legacy)
        await _firestore.collection('registrars').doc(userID).update({
          'profilePicData': base64String,
        });
      }

      dPrint('Updated Firestore document with base64 profile picture');

      // Update the current registrar in memory if needed
      if (currentRegistrar != null) {
        currentRegistrar = FetchingRegistrarModel(
          profilePicData: currentRegistrar!.profilePicData,
          id: currentRegistrar!.id,
          lastName: currentRegistrar!.lastName,
          firstName: currentRegistrar!.firstName,
          middleName: currentRegistrar!.middleName,
          dateOfBirth: currentRegistrar!.dateOfBirth,
          age: currentRegistrar!.age,
          contact: currentRegistrar!.contact,
          placeOfBirth: currentRegistrar!.placeOfBirth,
          address: currentRegistrar!.address,
          email: currentRegistrar!.email,
          remarks: currentRegistrar!.remarks,
          nameExtension: currentRegistrar!.nameExtension,
          password: currentRegistrar!.password,
          jobLevel: currentRegistrar!.jobLevel,
        );
      }

      return null;
    } catch (e) {
      dPrint('Error uploading file: $e');
      return e.toString();
    }
  }

  Future<String?> changeEmail(String uid, String email) async {
    try {
      // Try to update in faculty_staff collection first (new)
      try {
        await _firestore
            .collection('faculty_staff')
            .doc(uid)
            .update({'email': email});
        return null;
      } catch (e) {
        // If not found in faculty_staff, try registrars collection (legacy)
        await _firestore
            .collection('registrars')
            .doc(uid)
            .update({'email': email});
        return null;
      }
    } catch (e) {
      dPrint(e);
      return e.toString();
    }
  }

  Future<String?> changePass(String uid, String pass) async {
    try {
      // await _auth.currentUser!.updatePassword(pass);
      // Try to update in faculty_staff collection first (new)
      try {
        await _firestore
            .collection('faculty_staff')
            .doc(uid)
            .update({'password': pass});
        return null;
      } catch (e) {
        // If not found in faculty_staff, try registrars collection (legacy)
        await _firestore
            .collection('registrars')
            .doc(uid)
            .update({'password': pass});
        return null;
      }
    } catch (e) {
      dPrint(e);
      return e.toString();
    }
  }

  Future<String?> changeContactNo(String uid, String contactNo) async {
    try {
      // Try to update in faculty_staff collection first (new)
      try {
        await _firestore
            .collection('faculty_staff')
            .doc(uid)
            .update({'contact': contactNo});
        return null;
      } catch (e) {
        // If not found in faculty_staff, try registrars collection (legacy)
        await _firestore
            .collection('registrars')
            .doc(uid)
            .update({'contact': contactNo});
        return null;
      }
    } catch (e) {
      dPrint(e);
      return e.toString();
    }
  }

  Future<String?> saveStudentData(EnrollmentFormModel enrollment) async {
    try {
      // Create student data map from enrollment form
      final studentId = await generateNewIdentification(
          collectionName: 'students',
          prefix: 'SDAS',
          padding: 6,
          includeYear: true);
      final studentData = {
        'id': enrollment.regNo,
        'firstName': enrollment.firstName,
        'middleName': enrollment.middleName,
        'lastName': enrollment.lastName,
        'lrn': enrollment.lrn,
        'grade': enrollment.enrollingGrade.name,
        'age': enrollment.age,
        'dateOfBirth': enrollment.dateOfBirth,
        'placeOfBirth': enrollment.placeOfBirth,
        'religion': enrollment.religion,
        'gender': enrollment.gender.name,
        'address': enrollment.address,
        'motherTongue': enrollment.motherTongue,
        'civilStatus': enrollment.civilStatus.name,
        'ipOrIcc': enrollment.ipOrIcc,
        'sdaBaptismDate': enrollment.sdaBaptismDate,
        'cellno': enrollment.cellno,
        'lastSchoolAttended': enrollment.lastSchoolAttended,
        'parentsUserId': enrollment.parentsUserId,
        'fathersFirstName': enrollment.fathersFirstName,
        'fathersMiddleName': enrollment.fathersMiddleName,
        'fathersLastName': enrollment.fathersLastName,
        'fathersOcc': enrollment.fathersOcc,
        'mothersFirstName': enrollment.mothersFirstName,
        'mothersMiddleName': enrollment.mothersMiddleName,
        'mothersLastName': enrollment.mothersLastName,
        'mothersOcc': enrollment.mothersOcc,
        'form138Link': enrollment.form138Link,
        'cocLink': enrollment.cocLink,
        'birthCertLink': enrollment.birthCertLink,
        'goodMoralLink': enrollment.goodMoralLink,
        'sigOverNameLink': enrollment.sigOverNameLink,
        'additionalInfo': enrollment.additionalInfo,
        'timestamp': enrollment.timestamp,
        'status': 'active', // Default status for new students
      };

      // Save to students collection
      await _firestore.collection('students').doc(studentId).set(studentData);

      dPrint('Student data saved successfully with ID: $studentId');
      return null;
    } catch (e) {
      dPrint('Error saving student data: $e');
      return e.toString();
    }
  }

  // Admin-related methods
  Future<void> saveAdminData(AdminModel admin) async {
    try {
      await _firestore.collection('admins').doc(admin.id).set(admin.toMap());
      dPrint('Admin data saved successfully with ID: ${admin.id}.');
    } catch (e) {
      dPrint('Error saving admin data: $e');
      throw e;
    }
  }

  Future<AdminModel?> getAdminData(String id) async {
    try {
      var docSnapshot = await _firestore.collection('admins').doc(id).get();

      if (docSnapshot.exists) {
        return AdminModel.fromMap(docSnapshot.data()!);
      }
      return null;
    } catch (e) {
      dPrint('Error getting admin data: $e');
      return null;
    }
  }

  Future<bool> updateAdminField({
    required String documentId,
    required Map<String, dynamic> updatedFields,
  }) async {
    try {
      await _firestore
          .collection('admins')
          .doc(documentId)
          .update(updatedFields);
      dPrint('Admin fields updated successfully for: $documentId');
      return true;
    } catch (e) {
      dPrint('Error updating admin fields: $e');
      return false;
    }
  }

  // School year management methods
  Future<bool> setSchoolYearEndDate(DateTime endDate) async {
    try {
      // Update the admin record with the new school year end date
      if (currentRegistrar?.id != null) {
        // Use set with merge to ensure the document exists
        await _firestore.collection('admins').doc(currentRegistrar!.id).set({
          'schoolYearEndDate': endDate.millisecondsSinceEpoch,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        dPrint('School year end date set to: $endDate');
        return true;
      }
      dPrint('Error: currentRegistrar ID is null');
      return false;
    } catch (e) {
      dPrint('Error setting school year end date: $e');
      return false;
    }
  }

  Future<DateTime?> getSchoolYearEndDate() async {
    try {
      if (currentRegistrar?.id != null) {
        dPrint(
            'Getting school year end date for admin ID: ${currentRegistrar!.id}');
        var docSnapshot = await _firestore
            .collection('admins')
            .doc(currentRegistrar!.id)
            .get();
        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          dPrint('Admin document data: $data');
          if (data?['schoolYearEndDate'] != null) {
            final date =
                DateTime.fromMillisecondsSinceEpoch(data!['schoolYearEndDate']);
            dPrint('Retrieved school year end date: $date');
            return date;
          }
        } else {
          dPrint(
              'Admin document does not exist for ID: ${currentRegistrar!.id}');
        }
      } else {
        dPrint('Error: currentRegistrar ID is null');
      }
      return null;
    } catch (e) {
      dPrint('Error getting school year end date: $e');
      return null;
    }
  }

  // Auto-promotion methods
  Future<bool> performAutoPromotion() async {
    try {
      dPrint('Starting auto-promotion process...');

      // Get all students
      final studentsSnapshot = await _firestore.collection('students').get();
      int promotedCount = 0;
      int skippedCount = 0;

      for (var doc in studentsSnapshot.docs) {
        final studentData = doc.data();
        final studentId = doc.id;

        // Check if student meets promotion criteria
        if (await _canStudentBePromoted(studentId, studentData)) {
          // Promote student to next grade level
          await _promoteStudent(studentId, studentData);
          promotedCount++;
          dPrint('Promoted student: $studentId');
        } else {
          skippedCount++;
          dPrint('Skipped student: $studentId (does not meet criteria)');
        }
      }

      dPrint(
          'Auto-promotion completed. Promoted: $promotedCount, Skipped: $skippedCount');
      return true;
    } catch (e) {
      dPrint('Error during auto-promotion: $e');
      return false;
    }
  }

  Future<bool> _canStudentBePromoted(
      String studentId, Map<String, dynamic> studentData) async {
    try {
      // Get current school year
      final currentSchoolYear = _getCurrentSchoolYear();

      // Check if student has passing grades using the efficient grade service
      final hasPassingGrades = await EfficientGradeService.hasPassingGrades(
        studentId: studentId,
        schoolYear: currentSchoolYear,
        passingGrade: 75.0,
      );

      if (!hasPassingGrades) {
        dPrint(
            'Student $studentId does not have passing grades - cannot promote');
        return false;
      }

      // Check if student has paid balance
      final balanceSnapshot = await _firestore
          .collection('balance_accounts')
          .where('studentId', isEqualTo: studentId)
          .get();

      if (balanceSnapshot.docs.isNotEmpty) {
        final balanceData = balanceSnapshot.docs.first.data();
        final balance = balanceData['balance'] ?? 0.0;
        if (balance > 0) {
          dPrint(
              'Student $studentId has unpaid balance: $balance - cannot promote');
          return false;
        }
      }

      return true;
    } catch (e) {
      dPrint('Error checking student promotion criteria: $e');
      return false;
    }
  }

  /// Get current school year in format "YYYY-YYYY"
  String _getCurrentSchoolYear() {
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    // If we're in the latter part of the year (June-December),
    // then the school year is currentYear-nextYear
    // Otherwise, it's previousYear-currentYear
    if (currentMonth >= 6) {
      // June onwards
      return '$currentYear-${currentYear + 1}';
    } else {
      return '${currentYear - 1}-$currentYear';
    }
  }

  Future<void> _promoteStudent(
      String studentId, Map<String, dynamic> studentData) async {
    try {
      // Get the current grade from the student data (should be in student collection format)
      final currentGrade = studentData['grade'] ?? '';

      // Convert to standardized format for processing
      final currentStandardizedGrade =
          GradeLevelUtils.fromStudentCollectionFormat(currentGrade);

      // Define grade progression using standardized format
      String nextStandardizedGrade = '';
      switch (currentStandardizedGrade) {
        case 'kinderI':
          nextStandardizedGrade = 'kinderII';
          break;
        case 'kinderII':
          nextStandardizedGrade = 'grade1';
          break;
        case 'grade1':
          nextStandardizedGrade = 'grade2';
          break;
        case 'grade2':
          nextStandardizedGrade = 'grade3';
          break;
        case 'grade3':
          nextStandardizedGrade = 'grade4';
          break;
        case 'grade4':
          nextStandardizedGrade = 'grade5';
          break;
        case 'grade5':
          nextStandardizedGrade = 'grade6';
          break;
        case 'grade6':
          nextStandardizedGrade = 'grade7';
          break;
        case 'grade7':
          // Grade 7 is the highest grade - student graduates
          nextStandardizedGrade = 'graduated';
          break;
        default:
          dPrint(
              'Unknown grade level: $currentGrade (standardized: $currentStandardizedGrade)');
          return;
      }

      // Convert back to student collection format for storage
      final nextGrade =
          GradeLevelUtils.getStudentCollectionFormat(nextStandardizedGrade);

      // Update student's grade level
      await _firestore.collection('students').doc(studentId).update({
        'grade': nextGrade,
        'lastPromotionDate': DateTime.now().millisecondsSinceEpoch,
      });

      dPrint('Student $studentId promoted from $currentGrade to $nextGrade');
    } catch (e) {
      dPrint('Error promoting student: $e');
      throw e;
    }
  }
}
