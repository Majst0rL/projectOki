import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import this for the User type
import 'package:cloud_firestore/cloud_firestore.dart'; // Import this for Firestore
import '../service/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _username = '';
  String _firstName = '';
  String _lastName = '';
  String _dateOfBirth = '';
  String _errorMessage = ''; // Variable to hold error messages

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.now())
      setState(() {
        _dateOfBirth = "${picked.toLocal()}".split(' ')[0]; // Format date
      });
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_password.length < 6) {
        setState(() {
          _errorMessage = 'Password must be at least 6 characters long';
        });
        return;
      }
      if (_password == _confirmPassword) {
        User? user = await _authService.register(_email, _password, _username); // Pass username
        if (user != null) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'username': _username,
            'first_name': _firstName,
            'last_name': _lastName,
            'date_of_birth': _dateOfBirth,
            'email': _email, // Store email in the database
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else {
          setState(() {
            _errorMessage = 'Email already in use or registration failed';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Passwords do not match';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView( // Allow scrolling
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
              TextFormField(
                decoration: InputDecoration(labelText: 'Confirm Password'),
                validator: (value) => value!.isEmpty ? 'Confirm your password' : null,
                onSaved: (value) => _confirmPassword = value!,
                obscureText: true,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) => value!.isEmpty ? 'Enter a username' : null,
                onSaved: (value) => _username = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'First Name'),
                onSaved: (value) => _firstName = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Last Name'),
                onSaved: (value) => _lastName = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Date of Birth'),
                readOnly: true,
                onTap: () => _selectDate(context), // Show date picker
                validator: (value) => value!.isEmpty ? 'Select your date of birth' : null,
                onSaved: (value) => _dateOfBirth = value!,
                controller: TextEditingController(text: _dateOfBirth), // Display selected date
              ),
              ElevatedButton(
                onPressed: _register,
                child: Text('Register'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text('Already have an account? Login here'),
              ),
              if (_errorMessage.isNotEmpty) // Display error message
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
