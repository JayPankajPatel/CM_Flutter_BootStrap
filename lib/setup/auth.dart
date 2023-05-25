import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<String> signInWithEmailandPassword(String email, String password);
  Future<String> createUserWithEmailandPassword(String email, String password);
  Future<String?> currentUser();
  Future<void> signOut();
}

class Auth extends BaseAuth {
  @override
  Future<String> signInWithEmailandPassword(
      String email, String password) async {
    UserCredential user = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return user.user!.uid;
  }

  @override
  Future<String> createUserWithEmailandPassword(
      String email, String password) async {
    UserCredential user = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    return user.user!.uid;
  }

  @override
  Future<String?> currentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  @override
  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }
}
