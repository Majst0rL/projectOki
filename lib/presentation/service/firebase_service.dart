//lib/presentation/service/firebase_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchMoviesFromFirestore() async {
    try {
      // Assuming a Firestore collection named 'movies'
      final QuerySnapshot snapshot = await _firestore.collection('movies').get();

      // Map Firestore data to a list of maps
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print('Fetched movie data: $data');
        return {
          'title': data['title'] ?? '',
          'poster_path': data['poster_path'] ?? '',
          'genre_ids': List<int>.from(data['genre_ids'] ?? []),
          'release_date': data['release_date'] ?? '',
          'vote_average': (data['vote_average'] as num?)?.toDouble() ?? 0.0,
        };
      }).toList();
    } catch (e) {
      print('Error fetching movies: $e');
      return [];
    }
  }
  
  // Add a movie to the user's favorites
    Future<void> addFavorite(String userId, Map<String, dynamic> movie) async {
      try {
        final favoritesRef = _firestore.collection('favorites').doc(userId);

        // Save only necessary fields, including the movie ID
        final movieData = {
          'id': movie['id'], // Add the movie ID
          'title': movie['title'] ?? '',
          'poster_path': movie['poster_path'] ?? '',
          'vote_average': movie['vote_average'] ?? 0.0,
          'release_date': movie['release_date'] ?? '',
          'genre_ids': movie['genre_ids'] ?? [],
        };

        // Merge the movie into the favorites array
        await favoritesRef.set({
          'userId': userId,
          'favorites': FieldValue.arrayUnion([movieData])
        }, SetOptions(merge: true));

        print('Favorite added successfully for user: $userId');
      } catch (e) {
        print('Failed to add favorite: $e');
      }
    }


  // Remove a movie from the user's favorites
  Future<void> removeFavorite(String userId, Map<String, dynamic> movie) async {
    try {
      final favoritesRef = _firestore.collection('favorites').doc(userId);

      // Remove the movie from the favorites array
      await favoritesRef.update({
        'favorites': FieldValue.arrayRemove([movie]) // Remove the movie
      });

      print('Favorite removed successfully for user: $userId');
    } catch (e) {
      print('Failed to remove favorite: $e');
    }
  }

  // Check if a specific movie is in the user's favorites
  Future<bool> isFavorite(String userId, String movieId) async {
    try {
      final favoritesRef = _firestore.collection('favorites').doc(userId);
      final doc = await favoritesRef.get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final favorites =
            List<Map<String, dynamic>>.from(data['favorites'] ?? []);

        // Check if the movie with the specified ID exists in the favorites
        return favorites.any((movie) => movie['id'] == movieId);
      }
      return false;
    } catch (e) {
      print('Failed to check favorite status: $e');
      return false;
    }
  }

  // Fetch all favorites for a specific user
  Future<List<Map<String, dynamic>>> fetchFavorites(String userId) async {
    try {
      final favoritesRef = _firestore.collection('favorites').doc(userId);
      final doc = await favoritesRef.get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['favorites'] ?? []);
      }
      return [];
    } catch (e) {
      print('Failed to fetch favorites: $e');
      return [];
    }
  }

}
