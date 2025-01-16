//lib/presentation/screens/ProfileScreen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
  }

  void _updateEmail(String newEmail) async {
    try {
      await user!.updateEmail(newEmail);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Email updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update email')));
    }
  }

  void _updatePassword(String newPassword) async {
    try {
      await user!.updatePassword(newPassword);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update password')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              initialValue: user?.email,
              decoration: InputDecoration(labelText: 'Email'),
              onFieldSubmitted: _updateEmail,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'New Password'),
              onFieldSubmitted: _updatePassword,
              obscureText: true,
            ),
            // Add more fields for profile picture and other data if needed
          ],
        ),
      ),
    );
  }
}