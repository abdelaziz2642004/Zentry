import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';

class AccountopsRepo {
  Future<void> authenticate(String oldPassword, User user) async {
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: oldPassword,
    );

    await user.reauthenticateWithCredential(credential);
  }

  Future<void> deleteAccount() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    final String idd = currentUser.uid;

    await currentUser.delete();

    final docref = FirebaseFirestore.instance
        .collection(FirebaseConstants.usersCollection)
        .doc(idd);
    final userName =
        await docref.get().then((doc) => doc[FirebaseConstants.usernameField])
            as String;

    await docref.delete();
    await FirebaseFirestore.instance
        .collection(FirebaseConstants.userNamesCollection)
        .doc(userName)
        .get()
        .then((doc) {
          if (doc.exists) {
            doc.reference.delete();
          }
        });
    await FirebaseFirestore.instance
        .collection(FirebaseConstants.userNamesCollection)
        .doc(userName)
        .delete();
  }
}
