class Movie {
  final String id;
  final String title;
  final String posterPath;
  final String overview;
  final String releaseDate;
  final double voteAverage;
  final String genre;
  
  // Additional fields dari API detail
  final String? director;
  final List<String>? cast;
  final String? language;
  final String? duration;

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.overview,
    required this.releaseDate,
    required this.voteAverage,
    required this.genre,
    this.director,
    this.cast,
    this.language,
    this.duration,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    
    String parseString(dynamic value, String defaultValue) {
      if (value == null || value == 'empty') return defaultValue;
      if (value is String) return value;
      if (value is List && value.isNotEmpty) return value[0].toString();
      return value.toString();
    }

  
    String? parseStringNullable(dynamic value) {
      if (value == null || value == 'empty') return null;
      if (value is String) return value;
      if (value is List && value.isNotEmpty) return value[0].toString();
      return value.toString();
    }

    
    double parseRating(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    
    String parseGenre(dynamic value) {
      if (value == null) return 'Unknown';
      if (value is String) return value;
      if (value is List && value.isNotEmpty) {
        return value.map((e) => e.toString()).join(", ");
      }
      return value.toString();
    }

    
    List<String>? parseCast(dynamic value) {
      if (value == null) return null;
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return null;
    }

    
    String posterUrl = parseString(
      json['imgUrl'] ?? json['image'], 
      'https://via.placeholder.com/300x450/1a1a1a/ffffff?text=No+Image'
    );

    
    String description = parseString(
      json['description'] ?? json['overview'] ?? json['synopsis'],
      'No Description Available'
    );

    return Movie(
      id: parseString(json['id'], '0'),
      title: parseString(json['title'], 'No Title'),
      posterPath: posterUrl,
      overview: description,
      releaseDate: parseString(json['release_date'], 'Unknown'),
      voteAverage: parseRating(json['rating']),
      genre: parseGenre(json['genre']),
      director: parseStringNullable(json['director']),
      cast: parseCast(json['cast']),
      language: parseStringNullable(json['language']),
      duration: parseStringNullable(json['duration']),
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
      'director': director,
      'cast': cast?.join(','),
      'language': language,
      'duration': duration,
    };
  }

  // Constructor dari Map (untuk database)
  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'] as String,
      title: map['title'] as String,
      posterPath: map['posterPath'] as String,
      overview: map['overview'] as String,
      releaseDate: map['releaseDate'] as String,
      voteAverage: map['voteAverage'] as double,
      genre: map['genre'] as String,
      director: map['director'] as String?,
      cast: map['cast'] != null ? (map['cast'] as String).split(',') : null,
      language: map['language'] as String?,
      duration: map['duration'] as String?,
    );
  }
}