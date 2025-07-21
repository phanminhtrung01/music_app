import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthFirebase {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late ValueNotifier<bool> infoSongsNewReleaseNotifier =
      ValueNotifier<bool>(false);

  Future<void> registerWithEmailAndPassword(
      String email, String password) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  void registerWithEmailAndPasswordAndVerify() async {
    final User? user = (await _firebaseAuth.createUserWithEmailAndPassword(
      email: "example@example.com",
      password: "password",
    ))
        .user;
    if (user != null) {
      await user.sendEmailVerification();
    }
  }

  void _checkEmailVerification() async {
    User? user = _firebaseAuth.currentUser;

    if (user != null) {
      await user.reload();
      if (user.emailVerified) {
        // Email đã được xác minh
        // Thực hiện các hành động phù hợp tại đây
      } else {
        // Email chưa được xác minh
        // Thực hiện các hành động phù hợp tại đây
      }
    }
  }
}
