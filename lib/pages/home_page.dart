import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie_model.dart';
import '../services/api_service.dart';
import 'detail_page.dart';
import 'favorite_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = "";
  List<Movie> _allMovies = [];
  List<Movie> _filteredMovies = [];
  List<String> _genres = ["All"];
  String _selectedGenre = "All";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchMovies();
  }

  void _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => username = prefs.getString('username') ?? "User");
  }

  Future<void> _fetchMovies() async {
    try {
      final movies = await ApiService.getMovies();
      final genres = movies.map((m) => m.genre).toSet().toList();
      
      if (mounted) {
        setState(() {
          _allMovies = movies;
          _filteredMovies = movies;
          _genres = ["All", ...genres];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filter(String genre) {
    setState(() {
      _selectedGenre = genre;
      if (genre == "All") {
        _filteredMovies = _allMovies;
      } else {
        _filteredMovies = _allMovies.where((m) => m.genre == genre).toList();
      }
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil film pertama untuk Hero Image
    final Movie? heroMovie = _allMovies.isNotEmpty ? _allMovies.first : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // 1. HERO IMAGE BACKGROUND
                if (heroMovie != null)
                  Positioned(
                    top: 0, left: 0, right: 0, height: 500,
                    child: ShaderMask(
                      shaderCallback: (rect) {
                        return const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black, Colors.transparent],
                          stops: [0.0, 1.0], 
                        ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                      },
                      blendMode: BlendMode.dstIn,
                      child: Image.network(
                        heroMovie.posterPath,
                        fit: BoxFit.cover,
                        // Gunakan ResizeImage agar memory hemat
                        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                          return child;
                        },
                        errorBuilder: (_,__,___) => Container(color: Colors.black),
                      ),
                    ),
                  ),

                // 2. GRADIENT OVERLAY
                Positioned(
                  top: 0, left: 0, right: 0, height: 500,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                          const Color(0xFF0D0D0D),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ),

                // 3. CONTENT
                SafeArea(
                  child: Column(
                    children: [
                      // Header AppBar Custom
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Welcome back,", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                Text(username, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(icon: const Icon(Icons.favorite, color: Colors.white), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritePage()))),
                                IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: _logout),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.22),

                            // Judul Hero & Tombol Play
                            if (heroMovie != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(heroMovie.title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1)),
                                    const SizedBox(height: 16),
                                    GestureDetector(
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(movie: heroMovie))),
                                      child: Container(
                                        width: 120, padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(colors: [Colors.white, Color(0xFF666666)]),
                                          borderRadius: BorderRadius.circular(30),
                                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                                        ),
                                        child: const Center(child: Text("Play Trailer", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12))),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 30),

                            // Search Bar
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(color: const Color(0xFF272727).withOpacity(0.5), borderRadius: BorderRadius.circular(30)),
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(children: [
                                  Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
                                  const SizedBox(width: 10),
                                  Text("Search...", style: TextStyle(color: Colors.white.withOpacity(0.5))),
                                ]),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Filter Chips
                            SizedBox(
                              height: 40,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: _genres.length,
                                itemBuilder: (context, index) {
                                  final genre = _genres[index];
                                  final isSelected = genre == _selectedGenre;
                                  return GestureDetector(
                                    onTap: () => _filter(genre),
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFF4E4E4E) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                        border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.1)),
                                      ),
                                      child: Center(child: Text(genre, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12))),
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 30),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                const Text("Popular Movies", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                Text("See All", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                              ]),
                            ),

                            const SizedBox(height: 16),

                            // LIST HORIZONTAL DENGAN RESIZE IMAGE (ANTI LAG)
                            SizedBox(
                              height: 250,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: _filteredMovies.length,
                                itemBuilder: (context, index) {
                                  final movie = _filteredMovies[index];
                                  return GestureDetector(
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(movie: movie))),
                                    child: Container(
                                      width: 150, margin: const EdgeInsets.only(right: 16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(16),
                                                image: DecorationImage(
                                                  // PENTING: ResizeImage untuk mencegah Force Close memori penuh
                                                  image: ResizeImage(
                                                    NetworkImage(movie.posterPath),
                                                    width: 150, 
                                                    allowUpscaling: true
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(movie.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          Text("${movie.voteAverage} • ${movie.genre}", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}