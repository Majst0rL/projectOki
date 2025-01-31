import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AiScreen extends StatefulWidget {
  @override
  _AiScreenState createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _selectedMovieId = ""; // Selected movie ID for recommendations
  List<Map<String, dynamic>> _recommendedMovies = [];
  List<Map<String, dynamic>> _userFavorites = [];
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _fetchUserFavorites();
  }

  Future<void> _fetchUserFavorites() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return;

      final doc = await _firestore.collection('favorites').doc(user.uid).get();
      if (doc.exists) {
        final favorites =
            List<Map<String, dynamic>>.from(doc.data()?['favorites'] ?? []);
        setState(() {
          _userFavorites = favorites;
        });
      }
    } catch (e) {
      print('Error fetching favorites: $e');
    }
  }

  Future<void> _fetchRecommendations() async {
    if (_selectedMovieId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a movie first!")),
      );
      return;
    }

    try {
      const String apiKey = "4428d2076aac13811654005f8a011f82";
      final uri = Uri.https(
        "api.themoviedb.org",
        "/3/movie/$_selectedMovieId/recommendations",
        {
          "api_key": apiKey,
          "language": "en-US",
          "page": _page.toString(),
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> movies = data['results'];
        setState(() {
          _recommendedMovies =
              movies.map((movie) => Map<String, dynamic>.from(movie)).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch recommendations.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 20),
          Text(
            "Select a movie to get recommendations:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          DropdownButton<String>(
            value: _selectedMovieId.isNotEmpty ? _selectedMovieId : null,
            hint: Text("Select a movie"),
            items: _userFavorites.map((movie) {
              return DropdownMenuItem<String>(
                value: movie['id'], // Use movie ID
                child: Text(movie['title']),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedMovieId = value!;
                _recommendedMovies.clear();
                _page = 1;
              });
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _fetchRecommendations,
            child: Text("Get Recommendations"),
          ),
          SizedBox(height: 20),
          Expanded(
            child: _recommendedMovies.isEmpty
                ? Center(child: Text("No recommendations yet."))
                : ListView.builder(
                    itemCount: _recommendedMovies.length,
                    itemBuilder: (context, index) {
                      final movie = _recommendedMovies[index];
                      return ListTile(
                        leading: movie['poster_path'] != null
                            ? Image.network(
                                "https://image.tmdb.org/t/p/w500${movie['poster_path']}",
                                width: 50,
                                height: 75,
                                fit: BoxFit.cover,
                              )
                            : Icon(Icons.movie, size: 50),
                        title: Text(movie['title'] ?? "Untitled"),
                        subtitle: Text(
                          "Rating: ${movie['vote_average']?.toStringAsFixed(1) ?? 'N/A'}",
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
