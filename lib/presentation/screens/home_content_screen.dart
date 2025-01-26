//presentation/screens/home_content_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/firebase_service.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_screen.dart';

class HomeContentScreen extends StatefulWidget {
  @override
  _HomeContentScreenState createState() => _HomeContentScreenState();
} 

class _HomeContentScreenState extends State<HomeContentScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _movies = [];
  List<String> _favoriteMovieIds = []; // List of favorite movie IDs

  @override
  void initState() {
    super.initState();
    _loadMovies();
    _loadFavorites();
  }

  Future<void> _loadMovies() async {
    try {
      final movies = await FirebaseFirestore.instance.collection('movies').get();

      final processedMovies = movies.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['genre'] = data['genre'] ?? "0"; // Fallback for missing genre
        data['id'] = doc.id; // Ensure each movie has an ID
        return data;
      }).toList();

      setState(() {
        _movies = processedMovies;
      });
    } catch (e) {
      print('Failed to load movies: $e');
    }
  }


  Future<void> _loadFavorites() async {
    try {
      // Assuming a user ID is available (replace with actual user ID logic)
      final userId = 'current_user_id'; 
      final favorites = await _firebaseService.fetchFavorites(userId);

      setState(() {
        _favoriteMovieIds = favorites.map((movie) => movie['id'] as String).toList();
      });
    } catch (e) {
      print('Failed to load favorites: $e');
    }
  }

  Future<void> _toggleFavorite(Map<String, dynamic> movie) async {
    final userId = 'current_user_id'; // Replace with actual user ID
    final movieId = movie['id'];

    if (_favoriteMovieIds.contains(movieId)) {
      // Remove from favorites
      await _firebaseService.removeFavorite(userId, movie);
      setState(() {
        _favoriteMovieIds.remove(movieId);
      });
    } else {
      // Add to favorites
      await _firebaseService.addFavorite(userId, movie);
      setState(() {
        _favoriteMovieIds.add(movieId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: Colors.black,
      ),
      body: _movies.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: _movies.length,
              itemBuilder: (context, index) {
                final movie = _movies[index];
                final isFavorite = _favoriteMovieIds.contains(movie['id']); // Check if movie is in favorites

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailScreen(movie: movie),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      MovieCard(
                        title: movie['title'],
                        imageUrl: movie['poster_path'] ?? '',
                        genreIds: (movie['genre'] ?? "0")
                            .toString()
                            .split(',')
                            .map((id) => int.tryParse(id.trim()) ?? 0)
                            .where((id) => id != 0)
                            .toList(),
                        releaseDate: movie['release_date'] ?? '',
                        rating: double.parse(
                            (movie['vote_average']?.toDouble() ?? 0.0).toStringAsFixed(1)),
                        id: movie['id'], // OVDE DODAJETE ID
                      ),
                    ],
                  ),
                );
              },
            ),

    );
  }
}
