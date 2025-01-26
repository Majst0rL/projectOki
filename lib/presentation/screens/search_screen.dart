//presentation/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './movie_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Map<String, dynamic>> _allMovies = [];
  List<Map<String, dynamic>> _filteredMovies = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMovies();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMovies = _allMovies.where((movie) {
        final title = movie['title']?.toLowerCase() ?? '';
        return title.contains(query);
      }).toList();
    });
  }

  Future<void> _fetchMovies() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('movies').get();
      final movies = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      setState(() {
        _allMovies = movies;
        _filteredMovies = movies;
      });
    } catch (e) {
      print('Failed to fetch movies: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search by title",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _filteredMovies.isEmpty
                ? Center(child: Text("No movies found."))
                : ListView.builder(
                    itemCount: _filteredMovies.length,
                    itemBuilder: (context, index) {
                      final movie = _filteredMovies[index];
                      return ListTile(
                        leading: SizedBox(
                          width: 50, // Set a fixed width for the image
                          height: 50, // Set a fixed height for the image
                          child: movie['poster_path'] != null
                              ? Image.network(
                                  movie['poster_path'],
                                  fit: BoxFit.cover,
                                )
                              : Icon(Icons.movie, size: 50),
                        ),
                        title: Text(
                          movie['title'] ?? "Untitled",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Rating: ${movie['vote_average']?.toStringAsFixed(1) ?? 'N/A'}",
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MovieDetailScreen(movie: movie),
                            ),
                          );
                          // Navigate to movie details if needed
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
