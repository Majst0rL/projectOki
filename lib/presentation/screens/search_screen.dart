//presentation/screens/search_screen.dart
import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Searchs"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text(
          "Welcome to the Searchs Section",
          style: TextStyle(fontSize: 20, color: Colors.green),
        ),
      ),
    );
  }
}
