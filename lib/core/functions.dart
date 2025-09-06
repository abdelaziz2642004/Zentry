import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';

String capitalizeFirstLetterOfEachWord(String input) {
  return input
      .split(' ')
      .map((word) {
        if (word.isEmpty) return word; // Skip empty words
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      })
      .join(' ');
}

/// Generates a unique 6-digit room code
/// Returns a 6-digit string that is unique in Firestore
Future<String> generateUniqueRoomCode() async {
  final random = Random();
  final firestore = FirebaseFirestore.instance;
  int attempts = 0;

  while (attempts < 100) {
    // Prevent infinite loop
    attempts++;
    // Generate a 6-digit number
    final code = (100000 + random.nextInt(900000)).toString();

    try {
      // Check if this code already exists in Firestore
      final roomDoc = await firestore
          .collection(FirebaseConstants.roomsCollection)
          .doc(code)
          .get();

      if (!roomDoc.exists) {
        return code;
      }
    } on Exception catch (e) {
      e;
      // If there's an error checking, we'll try again
      continue;
    }
  }

  throw Exception("Could not generate unique room code after 100 attempts");
}

/// Validates if a room code is in the correct format (6 digits)
bool isValidRoomCode(String code) {
  return code.length == 6 && int.tryParse(code) != null;
}
