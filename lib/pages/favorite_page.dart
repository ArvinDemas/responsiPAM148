import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../services/database_helper.dart';
import 'detail_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});
  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Movie> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final data = await DatabaseHelper.instance.getFavorites(); // Load dari DB [cite: 49]
    setState(() => _favorites = data);
  }

  void _remove(String id) async {
    await DatabaseHelper.instance.removeFavorite(id);
    _loadData(); // Refresh list agar item hilang [cite: 48]
    if(mounted) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Removed"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Favorites")),
      body: _favorites.isEmpty 
        ? const Center(child: Text("Belum ada favorit"))
        : ListView.builder(
            itemCount: _favorites.length,
            itemBuilder: (context, index) {
              final movie = _favorites[index];
              return ListTile(
                leading: Image.network(movie.posterPath, width: 50, fit: BoxFit.cover),
                title: Text(movie.title),
                subtitle: Text(movie.genre),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _remove(movie.id),
                ),
                onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(movie: movie)))
                   .then((_) => _loadData());
                },
              );
            },
          ),
    );
  }
}