import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:enrollease_web/utils/firebase_auth.dart';

class ProfilePicCache {
  static final ProfilePicCache _instance = ProfilePicCache._internal();
  factory ProfilePicCache() => _instance;
  ProfilePicCache._internal();

  Uint8List? _cachedBytes;
  bool _isLoading = false;
  final _auth = FirebaseAuthProvider();

  Uint8List? get cachedBytes => _cachedBytes;
  bool get isLoading => _isLoading;

  Future<void> loadProfilePic(BuildContext context) async {
    if (_cachedBytes != null || _isLoading) return;

    _isLoading = true;
    try {
      final profileData = await _auth.getProfilePic(context);
      _cachedBytes = profileData;
    } catch (e) {
      debugPrint('Error loading profile picture: $e');
    } finally {
      _isLoading = false;
    }
  }

  void clearCache() {
    _cachedBytes = null;
  }
}
