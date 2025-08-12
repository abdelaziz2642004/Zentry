import 'dart:io';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';
import 'package:zentry_pomodoro_app/core/config/environment_config.dart';

class CloudinaryService {
  // Using EnvironmentConfig for secure credential management
  static String get cloudName => EnvironmentConfig.cloudName;
  static String get apiKey => EnvironmentConfig.apiKey;
  static String get apiSecret => EnvironmentConfig.apiSecret;
  static const String uploadPreset = FirebaseConstants.uploadPreset;

  static Future<String> pickAndUploadImage(File pickedFile) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return "";
    try {
      // Image deletion failed
    } on Exception catch (e) {
      e;
      // Image deletion failed
    }

    try {
      // Step 2: Upload new image
      final String? imageUrl = await _uploadImage(pickedFile, currentUser.uid);
      if (imageUrl != null) {
        // Step 3: Update Firestore
        await FirebaseFirestore.instance
            .collection(FirebaseConstants.usersCollection)
            .doc(currentUser.uid)
            .update({FirebaseConstants.imageUrlField: imageUrl});
        return imageUrl;
      } else {
        return "";
      }
    } on Exception catch (e) {
      e;
      return "";
    }
  }

  static Future<String?> _uploadImage(File file, String publicId) async {
    final Cloudinary cloudinary = Cloudinary.full(
      cloudName: cloudName,
      apiKey: apiKey,
      apiSecret: apiSecret,
    );
    final CloudinaryUploadResource cloudinaryUploadResource =
        CloudinaryUploadResource(publicId: publicId, filePath: file.path);
    final CloudinaryResponse cloudinaryResponse = await cloudinary
        .uploadResource(cloudinaryUploadResource);

    return cloudinaryResponse.url;
  }
}
