import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';

/// Result class for signup operations
class SignupResult {
  final bool isSuccess;
  final String? error;
  final String? userId;

  SignupResult._({required this.isSuccess, this.error, this.userId});

  factory SignupResult.success(String userId) {
    return SignupResult._(isSuccess: true, userId: userId);
  }

  factory SignupResult.failure(String error) {
    return SignupResult._(isSuccess: false, error: error);
  }
}

/// Clean signup service - only business logic and data access, no UI
class SignupService {
  SignupService();

  /// Upload image to Cloudinary
  Future<String> uploadImageToCloudinary(
    File imageFile,
    UserCredential user,
  ) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/dv0opvwfu/image/upload',
    );

    final request =
        http.MultipartRequest('POST', url)
          ..fields['upload_preset'] = 'UsersPics'
          ..fields['public_id'] = user.user!.uid
          ..files.add(
            await http.MultipartFile.fromPath(
              'file',
              imageFile.path,
              contentType: MediaType.parse(
                lookupMimeType(imageFile.path) ?? 'image/jpeg',
              ),
            ),
          );

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      return jsonDecode(responseData.body)['secure_url'];
    } else {
      throw Exception('Failed to upload image: ${response.statusCode}');
    }
  }

  /// Check if username is available
  static Future<bool> isUsernameAvailable(String username) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection(FirebaseConstants.userNamesCollection)
            .doc(username.trim())
            .get();
    return !snapshot.exists;
  }

  /// Check if email is available
  static Future<bool> isEmailAvailable(String email) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection(FirebaseConstants.usersCollection)
            .where(FirebaseConstants.emailField, isEqualTo: email.trim())
            .get();
    return snapshot.docs.isEmpty;
  }

  /// Validate signup form data
  static String? validateSignupForm({
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
    required String fullName,
  }) {
    if (email.isEmpty) {
      return 'Email cannot be empty';
    }
    if (!RegExp(
      r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$",
    ).hasMatch(email)) {
      return 'Enter a valid email';
    }
    if (username.isEmpty) {
      return 'Username cannot be empty';
    }
    if (username.length < 4) {
      return 'Username must be 4 or more characters';
    }
    if (password.isEmpty) {
      return 'Password cannot be empty';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (confirmPassword.isEmpty) {
      return 'Confirm password cannot be empty';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    if (fullName.isEmpty) {
      return 'Full name cannot be empty';
    }
    return null;
  }

  /// Create new user account
  Future<SignupResult> signUp({
    required String email,
    required String username,
    required String password,
    required String fullName,
    File? profileImage,
  }) async {
    try {
      // Initialize collections if they don't exist
      await FirebaseFirestore.instance
          .collection(FirebaseConstants.userNamesCollection)
          .doc(FirebaseConstants.initDocument)
          .set({});
      await FirebaseFirestore.instance
          .collection(FirebaseConstants.usersCollection)
          .doc(FirebaseConstants.initDocument)
          .set({});

      // Check username availability
      if (!await isUsernameAvailable(username)) {
        return SignupResult.failure('Username already exists');
      }

      // Check email availability
      if (!await isEmailAvailable(email)) {
        return SignupResult.failure('Email already exists');
      }

      // Create user with Firebase Auth
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      // Upload profile image if provided
      String imageUrl = '';
      if (profileImage != null) {
        imageUrl = await uploadImageToCloudinary(profileImage, userCredential);
      }

      // Save user data to Firestore
      await FirebaseFirestore.instance
          .collection(FirebaseConstants.usersCollection)
          .doc(userCredential.user!.uid)
          .set({
            FirebaseConstants.usernameField: username.trim(),
            FirebaseConstants.fullNameField: fullName.trim(),
            FirebaseConstants.emailField: email.trim(),
            FirebaseConstants.imageUrlField: imageUrl,
            FirebaseConstants.favoritedField: [],
            FirebaseConstants.notificationsField: [],
          });

      // Save username mapping
      await FirebaseFirestore.instance
          .collection(FirebaseConstants.userNamesCollection)
          .doc(username.trim())
          .set({
            FirebaseConstants.usernameField: username.trim(),
            FirebaseConstants.fullNameField: fullName.trim(),
            FirebaseConstants.emailField: email.trim(),
            FirebaseConstants.idField: userCredential.user!.uid,
          });

      return SignupResult.success(userCredential.user!.uid);
    } on Exception catch (e) {
      e;
      return SignupResult.failure(e.toString());
    }
  }
}
