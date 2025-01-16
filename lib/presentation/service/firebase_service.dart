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
}