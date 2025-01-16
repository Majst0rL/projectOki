//lib/service/firebase_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveMoviesToFirestore(List<Map<String, dynamic>> movies) async {
    final collection = _firestore.collection('movies');

    for (var movie in movies) {
      await collection.doc(movie['id'].toString()).set({
        'title': movie['title'],
        'genre': movie['genre_ids'].join(', '),
        'release_date': movie['release_date'],
        'overview': movie['overview'],
        'poster_path': 'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
        'vote_average': movie['vote_average'],
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchMoviesFromFirestore() async {
    final snapshot = await _firestore.collection('movies').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}

