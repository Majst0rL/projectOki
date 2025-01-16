// lib/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/auth_service.dart';
import 'register_screen.dart';
import 'home_screen.dart';

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

  void _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      User? user = await _authService.signIn(_email, _password);
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to login')));
      }
    }
  }

  void _goToRegister() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
  }

  void _resetPassword() {
    if (_email.isNotEmpty) {
      _authService.resetPassword(_email);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password reset email sent')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Enter your email to reset password')));
    }
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
                validator: (value) => value!.isEmpty ? 'Enter a password' : null,
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
                controlAffinity: ListTileControlAffinity.leading, // Align checkbox to the left
              ),
              TextButton(
                onPressed: _resetPassword,
                child: Text('Forgot Password?'),
              ),
              ElevatedButton(
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