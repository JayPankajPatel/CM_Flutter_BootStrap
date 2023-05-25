import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'favorites': [],
      });

      return userId;
    } catch (e) {
      // Handle registration errors
      print('Registration Error: $e');
      return ''; // Return an empty string or handle the error as needed
    }
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
