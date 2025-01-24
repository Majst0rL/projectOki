// lib/presentation/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../service/auth_service.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import '../../user_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _rememberMe = false;
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        User? user = await _authService.signIn(_email, _password);
        if (user != null) {
          // Fetch username from Firestore
          final userId = user.uid;
          final username = await _fetchUsernameFromFirestore(userId);

          // Save userId and username in the UserProvider
          Provider.of<UserProvider>(context, listen: false)
              .setUser(userId, username);

          // Navigate to the HomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          _showSnackBar('Failed to login. Please try again.');
        }
      } catch (e) {
        _showSnackBar('Login failed: ${e.toString()}');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _fetchUsernameFromFirestore(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return doc.data()?['username'] ?? 'Anonymous';
    } catch (e) {
      print('Failed to fetch username: $e');
      return 'Anonymous';
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  void _resetPassword() {
    if (_email.isNotEmpty) {
      _authService.resetPassword(_email);
      _showSnackBar('Password reset email sent.');
    } else {
      _showSnackBar('Enter your email to reset the password.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Enter an email' : null,
                onSaved: (value) => _email = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter a password' : null,
                onSaved: (value) => _password = value!,
                obscureText: true,
              ),
              CheckboxListTile(
                title: Text('Remember me'),
                value: _rememberMe,
                onChanged: (newValue) {
                  setState(() {
                    _rememberMe = newValue!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              TextButton(
                onPressed: _resetPassword,
                child: Text('Forgot Password?'),
              ),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: Text('Login'),
                    ),
              TextButton(
                onPressed: _goToRegister,
                child: Text('Don\'t have an account? Register here'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
