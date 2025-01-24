//presentation/screens/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/firebase_service.dart';
import '../../user_provider.dart';

class FavoritesScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserProvider>(context).userId;

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: userId == null
          ? Center(child: Text('Please log in to view your favorites.'))
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: _firebaseService.fetchFavorites(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No favorites added yet.'));
                }

                final favorites = snapshot.data!;
                return ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final movie = favorites[index];
                    return ListTile(
                      leading: Image.network(movie['poster_path']),
                      title: Text(movie['title']),
                      subtitle: Text(
                          "Rating: ${movie['vote_average']?.toStringAsFixed(1) ?? 'N/A'}"),
                    );
                  },
                );
              },
            ),
    );
  }
}
