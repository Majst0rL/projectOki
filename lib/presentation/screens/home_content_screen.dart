//presentation/screens/home_content_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/movie_card.dart';

class HomeContentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          MovieCard(
            title: "The Shawshank Redemption",
            imageUrl:
                "https://s29288.pcdn.co/wp-content/uploads/2010/03/shawshank-redemption-poster-1.jpg", // Replace with a real URL
            genre: "Drama",
            year: "1994",
            rating: 4.5,
          ),
          // Add more MovieCards
        ],
      ),
    );
  }
}
