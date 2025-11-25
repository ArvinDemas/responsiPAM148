class Movie {
  final String id;
  final String title;
  final String posterPath;
  final String overview;
  final String releaseDate;
  final double voteAverage;
  final String genre;

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.overview,
    required this.releaseDate,
    required this.voteAverage,
    required this.genre,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      // Pakai .toString() di semua field agar aman kalau API kirim Angka/List
      id: json['id']?.toString() ?? '0',
      
      title: json['title']?.toString() ?? 'No Title',
      
      // Kadang image dikirim array, kita convert aman ke String
      posterPath: json['image']?.toString() ?? 'https://via.placeholder.com/300',
      
      overview: json['overview']?.toString() ?? 'No Description',
      
      releaseDate: json['release_date']?.toString() ?? 'Unknown',
      
      voteAverage: double.tryParse(json['rating'].toString()) ?? 0.0,
      
      // PERBAIKAN UTAMA DI SINI:
      // Cek apakah genre itu List? Jika iya, gabung jadi string pake koma.
      // Jika bukan, jadikan string biasa.
      genre: (json['genre'] is List)
          ? (json['genre'] as List).join(", ") // Ubah ["Action", "Horor"] jadi "Action, Horor"
          : json['genre']?.toString() ?? 'Unknown',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'posterPath': posterPath,
      'overview': overview,
      'releaseDate': releaseDate,
      'voteAverage': voteAverage,
      'genre': genre,
    };
  }
}