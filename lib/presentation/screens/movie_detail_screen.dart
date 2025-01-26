//presentation/screens/movie_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../user_provider.dart';

class MovieDetailScreen extends StatefulWidget {
  final Map<String, dynamic> movie;

  MovieDetailScreen({required this.movie});

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  int _selectedRating = 1; // Default rating
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Fetch reviews for the specific movie
  void _fetchReviews() async {
    setState(() {
      _isLoadingReviews = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('movieId',
              isEqualTo: widget.movie['id']) // Fetch specific movie reviews
          .orderBy('timestamp', descending: true)
          .get();

      final reviews = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });
    } catch (e) {
      print('Failed to fetch reviews: $e');
      setState(() {
        _isLoadingReviews = false;
      });
    }
  }

  // Submit a new review
  void _submitReview() async {
    final String comment = _commentController.text;
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    final username = Provider.of<UserProvider>(context, listen: false).username;

    if (userId == null || username == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to add a review.')),
      );
      return;
    }

    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a comment.")),
      );
      return;
    }

    try {
      // Add the review to Firestore
      await FirebaseFirestore.instance.collection('reviews').add({
        'movieId': widget.movie['id'], // Associate the review with the movie
        'userId': userId,
        'username': username,
        'rating': _selectedRating,
        'comment': comment,
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Review submitted successfully!")),
      );

      _commentController.clear();
      setState(() {
        _selectedRating = 1;
      });

      // Refresh reviews after submission
      _fetchReviews();
    } catch (e) {
      print('Failed to submit review: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit review: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    return Scaffold(
      appBar: AppBar(
        title: Text(movie['title'] ?? "Movie Details"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie Poster
              movie['poster_path'] != null
                  ? Image.network(
                      movie['poster_path'],
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : SizedBox(
                      height: 250,
                      child: Center(child: Text("No image available"))),
              SizedBox(height: 20),

              // Movie Details
              Text(
                movie['title'] ?? "Untitled",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                  "Rating: ${movie['vote_average']?.toStringAsFixed(1) ?? 'N/A'}"),
              SizedBox(height: 10),
              Text("Release Date: ${movie['release_date'] ?? 'N/A'}"),
              SizedBox(height: 20),

              // Reviews Section
              Text(
                "Reviews",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _isLoadingReviews
                  ? Center(child: CircularProgressIndicator())
                  : _reviews.isEmpty
                      ? Text("No reviews yet.")
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _reviews.length,
                          itemBuilder: (context, index) {
                            final review = _reviews[index];
                            return ListTile(
                              title: Text(review['username'] ?? "Anonymous"),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Rating: ${review['rating']} Stars"),
                                  Text(review['comment'] ?? ""),
                                ],
                              ),
                              isThreeLine: true,
                            );
                          },
                        ),
              SizedBox(height: 20),

              // Add Review Section
              Text(
                "Add a Review",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              // Star Rating Dropdown
              DropdownButton<int>(
                value: _selectedRating,
                items: List.generate(5, (index) {
                  final rating = index + 1;
                  return DropdownMenuItem(
                    value: rating,
                    child: Text("$rating Stars"),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRating = value;
                    });
                  }
                },
              ),
              SizedBox(height: 10),

              // Comment Input Field
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: "Comment",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 10),

              // Submit Button
              ElevatedButton(
                onPressed: _submitReview,
                child: Text("Submit Review"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
