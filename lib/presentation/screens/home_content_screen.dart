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

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      // Replace this with your actual Firebase fetching logic
      final movies =
          await FirebaseFirestore.instance.collection('movies').get();

      // Process and ensure genre fallback
      final processedMovies = movies.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID to the movie data
        data['genre'] = data['genre'] ?? "0"; // Fallback for missing genre
        return data;
      }).toList();

      setState(() {
        _movies = processedMovies;
      });
    } catch (e) {
      print('Failed to load movies: $e');
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

                final genreField =
                    movie['genre'] ?? "0"; // Fallback to "0" if null

                final genreIds = genreField
                    .toString()
                    .split(',')
                    .map((id) => int.tryParse(id.trim()) ?? 0)
                    .where((id) => id != 0)
                    .toList();
                print('Parsed genre IDs for "${movie['title']}": $genreIds');

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailScreen(movie: movie),
                      ),
                    );
                  },
                  child: MovieCard(
                    title: movie['title'],
                    imageUrl: movie['poster_path'] ?? '',
                    genreIds: genreIds, // Pass parsed genre IDs
                    releaseDate: movie['release_date'] ?? '',
                    rating: double.parse(
                        (movie['vote_average']?.toDouble() ?? 0.0)
                            .toStringAsFixed(1)),
                  ),
                );
              },
            ),
    );
  }
}
