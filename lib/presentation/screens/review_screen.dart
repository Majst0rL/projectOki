//presentation/screens/review_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewScreen extends StatefulWidget {
  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> genres = [
    "Action",
    "Comedy",
    "Drama",
    "Fantasy",
    "Horror",
    "Mystery",
    "Romance",
    "Thriller",
    "Sci-Fi",
    "Adventure",
  ];

  List<String> selectedGenres = [];
  List<String> favoriteMovies = [];
  List<String> favoriteActors = [];
  List<String> favoriteDirectors = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('preferences').doc(user.uid).get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        selectedGenres = List<String>.from(data['genres'] ?? []);
        favoriteMovies = List<String>.from(data['movies'] ?? []);
        favoriteActors = List<String>.from(data['actors'] ?? []);
        favoriteDirectors = List<String>.from(data['directors'] ?? []);
      });
    }
  }

  Future<void> _savePreferences() async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('preferences').doc(user.uid).set({
      'genres': selectedGenres,
      'movies': favoriteMovies,
      'actors': favoriteActors,
      'directors': favoriteDirectors,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Preferences saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preferences"),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Your Top 5 Favorite Genres:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8.0,
              children: genres.map((genre) {
                final isSelected = selectedGenres.contains(genre);
                return ChoiceChip(
                  label: Text(genre),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        if (selectedGenres.length < 5) {
                          selectedGenres.add(genre);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("You can select up to 5 genres only."),
                            ),
                          );
                        }
                      } else {
                        selectedGenres.remove(genre);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            _buildEditableList(
              "Top 10 Favorite Movies",
              favoriteMovies,
              maxItems: 10,
            ),
            _buildEditableList(
              "Top 10 Favorite Actors",
              favoriteActors,
              maxItems: 10,
            ),
            _buildEditableList(
              "Top 5 Favorite Directors",
              favoriteDirectors,
              maxItems: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePreferences,
              child: Text("Save Preferences"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableList(String title, List<String> items, {required int maxItems}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: items.length + 1,
          itemBuilder: (context, index) {
            if (index == items.length) {
              return items.length < maxItems
                  ? ListTile(
                      leading: Icon(Icons.add),
                      title: Text("Add new item"),
                      onTap: () async {
                        final newItem = await _showInputDialog(title);
                        if (newItem != null && newItem.isNotEmpty) {
                          setState(() {
                            items.add(newItem);
                          });
                        }
                      },
                    )
                  : Container();
            }
            return ListTile(
              title: Text(items[index]),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    items.removeAt(index);
                  });
                },
              ),
            );
          },
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Future<String?> _showInputDialog(String title) async {
    String input = "";
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add $title"),
          content: TextField(
            onChanged: (value) => input = value,
            decoration: InputDecoration(hintText: "Enter here"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, input),
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }
}