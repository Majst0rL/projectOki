//lib/presentation/widgets/movie_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/firebase_service.dart';
import '../../user_provider.dart';
import 'package:intl/intl.dart';

class MovieCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final List<int> genreIds;
  final String releaseDate;
  final double rating;

  const MovieCard({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.genreIds,
    required this.releaseDate,
    required this.rating,
  }) : super(key: key);

  @override
  _MovieCardState createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  final FirebaseService _firebaseService = FirebaseService();
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  void _checkFavoriteStatus() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId != null) {
      final favoriteStatus =
          await _firebaseService.isFavorite(userId, widget.title);
      setState(() {
        isFavorite = favoriteStatus;
      });
    }
  }

  void _toggleFavorite() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to add favorites.')),
      );
      return;
    }

    setState(() {
      isFavorite = !isFavorite;
    });

    final movie = {
      'title': widget.title,
      'poster_path': widget.imageUrl,
      'genre_ids': widget.genreIds,
      'release_date': widget.releaseDate,
      'vote_average': widget.rating,
    };

    if (isFavorite) {
      await _firebaseService.addFavorite(userId, movie);
    } else {
      await _firebaseService.removeFavorite(userId, movie);
    }
  }

  String getGenres(List<int> ids) {
    final genreMap = {
      28: "Action",
      12: "Adventure",
      16: "Animation",
      35: "Comedy",
      80: "Crime",
      99: "Documentary",
      18: "Drama",
      10751: "Family",
      14: "Fantasy",
      36: "History",
      27: "Horror",
      10402: "Music",
      9648: "Mystery",
      10749: "Romance",
      878: "Science Fiction",
      10770: "TV Movie",
      53: "Thriller",
      10752: "War",
      37: "Western",
    };

    final genres = ids.map((id) => genreMap[id] ?? "Unknown").toList();
    return genres.isNotEmpty ? genres.join(", ") : "No genres available";
  }

  String formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat("yyyy").format(parsedDate);
    } catch (e) {
      return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                widget.imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    getGenres(widget.genreIds),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                Text(
                  formatDate(widget.releaseDate),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.star, color: Colors.yellow, size: 20),
                Text(
                  " ${widget.rating}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: _toggleFavorite,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
