import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/features/Profile/data/services/cloudinaryService.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';

class ProfileRepo {
  ProfileRepo(this.cloudinaryService);

  final CloudinaryService cloudinaryService;
  Future<String> changeImage(File pickedFile) {
    return CloudinaryService.pickAndUploadImage(pickedFile);
    // BlocProvider.of<AuthCubit>(context).user?.ImageUrl = imageUrl;
  }

  Future<void> changeFullName(String newName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection(FirebaseConstants.usersCollection)
        .doc(user.uid)
        .update({FirebaseConstants.fullNameField: newName});
  }
}
