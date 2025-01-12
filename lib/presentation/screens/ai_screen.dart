//presentation/screens/ai_screen.dart
import 'package:flutter/material.dart';

class AiScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text(
          "Welcome to the AI Section",
          style: TextStyle(fontSize: 20, color: Colors.green),
        ),
      ),
    );
  }
}
