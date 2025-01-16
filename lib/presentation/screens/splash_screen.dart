//presentation/screens/splash_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../service/tmdb_service.dart';
import '../service/firebase_service.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final TmdbService _tmdbService = TmdbService();
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _fetchAndSaveMovies();
  }

  Future<void> _fetchAndSaveMovies() async {
    try {
      final movies = await _tmdbService.fetchMovies();
      await _firebaseService.saveMoviesToFirestore(movies);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      print('Error during initialization: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(color: Colors.green),
      ),
    );
  }
}

