import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/movie_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('movie_app_final.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Tabel User
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT
      )
    ''');
    
    // Tabel Favorit
    await db.execute('''
      CREATE TABLE favorites (
        id TEXT PRIMARY KEY,
        title TEXT,
        posterPath TEXT,
        overview TEXT,
        releaseDate TEXT,
        voteAverage REAL,
        genre TEXT
      )
    ''');
  }

  // --- Logic User ---
  Future<int> register(String username, String password) async {
    final db = await instance.database;
    return await db.insert('users', {'username': username, 'password': password});
  }

  Future<bool> login(String username, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }

  // --- Logic Favorit ---
  Future<int> addFavorite(Movie movie) async {
    final db = await instance.database;
    return await db.insert('favorites', movie.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> removeFavorite(String id) async {
    final db = await instance.database;
    return await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Movie>> getFavorites() async {
    final db = await instance.database;
    final result = await db.query('favorites');
    return result.map((json) => Movie(
      id: json['id'] as String,
      title: json['title'] as String,
      posterPath: json['posterPath'] as String,
      overview: json['overview'] as String,
      releaseDate: json['releaseDate'] as String,
      voteAverage: json['voteAverage'] as double,
      genre: json['genre'] as String,
    )).toList();
  }

  Future<bool> isFavorite(String id) async {
    final db = await instance.database;
    final result = await db.query('favorites', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty;
  }
}