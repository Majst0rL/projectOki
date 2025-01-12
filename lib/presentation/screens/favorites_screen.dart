//presentation/screens/favorites_screen.dart
import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorites"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text(
          "Welcome to the Favorites Section",
          style: TextStyle(fontSize: 20, color: Colors.green),
        ),
      ),
    );
  }
}
