//presentation/home_content_screen.dart

import 'package:flutter/material.dart';
import 'lib\service\firebase_service.dart';
import 'lib\presentation\widgets\movie_card.dart';

class HomeContentScreen extends StatefulWidget {
  @override
  _HomeContentScreenState createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<HomeContentScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _movies = [];

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      final movies = await _firebaseService.fetchMoviesFromFirestore();
      setState(() {
        _movies = movies;
      });
    } catch (e) {
      print('Failed to load movies: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _movies.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: _movies.length,
              itemBuilder: (context, index) {
                final movie = _movies[index];
                return MovieCard(
                  title: movie['title'],
                  imageUrl: movie['poster_path'],
                  genre: movie['genre'],
                  year: movie['release_date'],
                  rating: movie['vote_average'],
                );
              },
            ),
    );
  }
}
