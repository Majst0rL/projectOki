import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hash the password
  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // Sign in with email or username
  Future<User?> signIn(String identifier, String password) async {
    try {
      // Check if identifier is an email or username
      QuerySnapshot userQuery = await _firestore.collection('users')
          .where('username', isEqualTo: identifier)
          .get();

      if (userQuery.docs.isEmpty) {
        // If not found by username, try email
        UserCredential result = await _auth.signInWithEmailAndPassword(email: identifier, password: password);
        return result.user;
      } else {
        // If found by username, get the email
        String email = userQuery.docs.first['email'];

        // Use Firebase Authentication to verify the password
        UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
        return result.user;
      }
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  // Register with email and password
  Future<User?> register(String email, String password, String username) async {
    try {
      // Check if email already exists
      QuerySnapshot emailQuery = await _firestore.collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (emailQuery.docs.isNotEmpty) {
        print('Email already in use');
        return null; // Email already in use
      }

      String hashedPassword = _hashPassword(password);
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      // Add user data to Firestore without storing the password
      await _firestore.collection('users').doc(user!.uid).set({
        'email': email,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
        'uid': user.uid,
      });

      print('User registered successfully');

      return user;
    } catch (e) {
      print('Error registering: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error resetting password: $e');
    }
  }
}
