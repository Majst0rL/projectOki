//presentation/screens/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/firebase_service.dart';
import '../../user_provider.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _favorites = [];
  String? _userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (_userId != null) {
        _loadFavorites();
      }
    });
  }

  Future<void> _loadFavorites() async {
    if (_userId == null) return;
    final favorites = await _firebaseService.fetchFavorites(_userId!);
    setState(() {
      _favorites = favorites;
    });
  }

  Future<void> _removeFavorite(Map<String, dynamic> movie) async {
    if (_userId == null) return;
    await _firebaseService.removeFavorite(_userId!, movie);
    setState(() {
      _favorites.remove(movie);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Favorite removed successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: _userId == null
          ? Center(child: Text('Please log in to view your favorites.'))
          : _favorites.isEmpty
              ? Center(child: Text('No favorites added yet.'))
              : ListView.builder(
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final movie = _favorites[index];
                    return ListTile(
                      leading: Image.network(
                        movie['poster_path'] ?? '',
                        width: 50,
                        height: 75,
                        fit: BoxFit.cover,
                      ),
                      title: Text(movie['title']),
                      subtitle: Text(
                          "Rating: ${movie['vote_average']?.toStringAsFixed(1) ?? 'N/A'}"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeFavorite(movie),
                      ),
                    );
                  },
                ),
    );
  }
}
