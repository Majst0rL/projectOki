//service/tmbd_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class TmdbService {
  final String _apiKey = '4428d2076aac13811654005f8a011f82'; // API KEY
  final String _baseUrl = 'https://api.themoviedb.org/3';

  Future<List<Map<String, dynamic>>> fetchMovies() async {
    final url = Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey&language=en-US&page=1');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['results']);
    } else {
      throw Exception('Failed to load movies');
    }
  }
}

