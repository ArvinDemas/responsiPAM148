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
    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _onUpgrade);
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
    
    // Tabel Favorit dengan field tambahan
    await db.execute('''
      CREATE TABLE favorites (
        id TEXT PRIMARY KEY,
        title TEXT,
        posterPath TEXT,
        overview TEXT,
        releaseDate TEXT,
        voteAverage REAL,
        genre TEXT,
        director TEXT,
        cast TEXT,
        language TEXT,
        duration TEXT
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Tambah kolom baru jika upgrade dari versi lama
      await db.execute('ALTER TABLE favorites ADD COLUMN director TEXT');
      await db.execute('ALTER TABLE favorites ADD COLUMN cast TEXT');
      await db.execute('ALTER TABLE favorites ADD COLUMN language TEXT');
      await db.execute('ALTER TABLE favorites ADD COLUMN duration TEXT');
    }
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
    return result.map((json) => Movie.fromMap(json)).toList();
  }

  Future<bool> isFavorite(String id) async {
    final db = await instance.database;
    final result = await db.query('favorites', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty;
  }
}