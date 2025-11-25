import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';

class ApiService {
  static const String _baseUrl = 'https://681388b3129f6313e2119693.mockapi.io/api/v1/movie';
  static const Duration _timeout = Duration(seconds: 15);

  static Future<List<Movie>> getMovies() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        
        List<Movie> movies = [];
        for (var i = 0; i < data.length; i++) {
          try {
            var movieData = data[i];
            print('Parsing movie ${i + 1}: ${movieData['title']}');
            print('Image URL: ${movieData['imgUrl'] ?? movieData['image']}');
            
            movies.add(Movie.fromJson(movieData));
          } catch (e) {
            print('Error parsing movie ${i + 1}: $e');
            print('Data: ${data[i]}');
            
            continue;
          }
        }
        
        print('Successfully loaded ${movies.length} movies');
        return movies;
      } else if (response.statusCode == 404) {
        throw Exception('API endpoint not found');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later');
      } else {
        throw Exception('Failed to load movies (Status: ${response.statusCode})');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: Please check your internet connection');
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout. Please try again');
      }
      rethrow;
    }
  }

 
  static Future<Movie> getMovieById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Movie.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Movie not found');
      } else {
        throw Exception('Failed to load movie detail (Status: ${response.statusCode})');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: Please check your internet connection');
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout. Please try again');
      }
      rethrow;
    }
  }
}