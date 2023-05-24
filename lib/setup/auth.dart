import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<String> signInWithEmailandPassword(String email, String password);
}

class Auth extends BaseAuth {
  @override
  Future<String> signInWithEmailandPassword(
      String email, String password) async {
    UserCredential user = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return user.user!.uid;
  }
}
