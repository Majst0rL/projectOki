import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.black, // Same background color as the splash screen
      appBar: AppBar(
        backgroundColor: Colors.black, // AppBar background color
        title: Text(
          'OKI',
          style: TextStyle(
            color: Colors.green, // Match splash screen text color
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0, // Remove AppBar shadow
      ),
      body: Center(
        child: Text(
          'Welcome to OKI!',
          style: TextStyle(
            fontSize: 24,
            color: Colors.green, // Match theme color
          ),
        ),
      ),
    );
  }
}
