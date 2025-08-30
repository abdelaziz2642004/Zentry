import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';

class FriendCodeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Generate a unique 6-character friend code
  Future<String> generateFriendCode() async {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    const codeLength = 6;

    while (true) {
      final code = String.fromCharCodes(
        Iterable.generate(
          codeLength,
          (_) => chars.codeUnitAt(
            DateTime.now().millisecondsSinceEpoch % chars.length,
          ),
        ),
      );

      // Check if code already exists
      final existingCode =
          await _firestore.collection('friendCodes').doc(code).get();

      if (!existingCode.exists) {
        return code;
      }
    }
  }

  /// Get or create friend code for current user
  Future<String> getOrCreateFriendCode() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    // Check if user already has a friend code
    final userDoc =
        await _firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(currentUser.uid)
            .get();

    if (userDoc.exists) {
      final userData = userDoc.data()!;
      final existingCode = userData['friendCode'] as String?;

      if (existingCode != null && existingCode.isNotEmpty) {
        return existingCode;
      }
    }

    // Generate new friend code
    final newCode = await generateFriendCode();

    // Save the code to user document
    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(currentUser.uid)
        .update({'friendCode': newCode});

    // Create friend code document
    await _firestore.collection('friendCodes').doc(newCode).set({
      'userId': currentUser.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return newCode;
  }

  /// Find user by friend code
  Future<Map<String, dynamic>?> findUserByFriendCode(String code) async {
    try {
      final codeDoc =
          await _firestore
              .collection('friendCodes')
              .doc(code.toUpperCase())
              .get();

      if (!codeDoc.exists) {
        return null;
      }

      final codeData = codeDoc.data()!;
      final userId = codeData['userId'] as String;

      // Get user data
      final userDoc =
          await _firestore
              .collection(FirebaseConstants.usersCollection)
              .doc(userId)
              .get();

      if (!userDoc.exists) {
        return null;
      }

      final userData = userDoc.data()!;
      return {
        'id': userId,
        'fullName': userData[FirebaseConstants.fullNameField],
        'username': userData[FirebaseConstants.usernameField],
        'imageUrl': userData[FirebaseConstants.imageUrlField] ?? '',
        'friendCode': userData['friendCode'] ?? '',
      };
    } catch (e) {
      print('Error finding user by friend code: $e');
      return null;
    }
  }
}
