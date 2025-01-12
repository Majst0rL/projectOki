//presentation/screens/review_screen.dart
import 'package:flutter/material.dart';

class ReviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reviews"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text(
          "Welcome to the Reviews Section",
          style: TextStyle(fontSize: 20, color: Colors.green),
        ),
      ),
    );
  }
}
