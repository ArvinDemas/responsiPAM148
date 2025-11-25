import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';

class ApiService {
  // Ganti URL ini jika API berubah
  static const String _baseUrl = 'https://681388b3129f6313e2119693.mockapi.io/api/v1/movie';

  static Future<List<Movie>> getMovies() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Konversi JSON list menjadi Movie list
        return data.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil data dari API');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }
}