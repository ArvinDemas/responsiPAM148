import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../services/database_helper.dart';

class DetailPage extends StatefulWidget {
  final Movie movie;
  const DetailPage({super.key, required this.movie});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFav();
  }

  void _checkFav() async {
    bool fav = await DatabaseHelper.instance.isFavorite(widget.movie.id);
    if(mounted) setState(() => isFavorite = fav);
  }

  // Logic Toggle Favorite dengan Snackbar [cite: 46]
  void _toggleFav() async {
    if (isFavorite) {
      await DatabaseHelper.instance.removeFavorite(widget.movie.id);
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Dihapus dari Favorit"), backgroundColor: Colors.red)
        );
      }
    } else {
      await DatabaseHelper.instance.addFavorite(widget.movie);
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ditambahkan ke Favorit"), backgroundColor: Colors.green)
        );
      }
    }
    setState(() => isFavorite = !isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(widget.movie.posterPath, width: double.infinity, height: 450, fit: BoxFit.cover),
                Positioned(
                  top: 40, left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(widget.movie.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                      // Tombol Favorit [cite: 45]
                      IconButton(
                        icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, size: 32),
                        color: isFavorite ? Colors.red : Colors.white, // Berubah warna [cite: 46]
                        onPressed: _toggleFav,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Chip(label: Text(widget.movie.genre), backgroundColor: const Color(0xFF546EE5)),
                      const SizedBox(width: 8),
                      const Icon(Icons.star, color: Colors.amber),
                      Text(" ${widget.movie.voteAverage}"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.movie.overview, style: const TextStyle(color: Colors.grey, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}