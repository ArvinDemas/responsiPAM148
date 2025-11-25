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
  bool _showAllMovies = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchMovies();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _applyFilters();
    });
  }

  void _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => username = prefs.getString('username') ?? "User");
  }

  Future<void> _fetchMovies() async {
    setState(() => _isLoading = true);
    try {
      final movies = await ApiService.getMovies();
      
      
      Set<String> genreSet = {};
      for (var movie in movies) {
        if (movie.genre.contains(',')) {
          genreSet.addAll(movie.genre.split(',').map((e) => e.trim()));
        } else {
          genreSet.add(movie.genre);
        }
      }
      
      if (mounted) {
        setState(() {
          _allMovies = movies;
          _filteredMovies = movies;
          _genres = ["All", ...genreSet.toList()..sort()];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)
        );
      }
    }
  }

  void _applyFilters() {
    List<Movie> result = _allMovies;

    // Filter by genre
    if (_selectedGenre != "All") {
      result = result.where((m) => m.genre.contains(_selectedGenre)).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      result = result.where((m) => 
        m.title.toLowerCase().contains(_searchQuery) ||
        m.genre.toLowerCase().contains(_searchQuery)
      ).toList();
    }

    setState(() => _filteredMovies = result);
  }

  void _filterByGenre(String genre) {
    setState(() {
      _selectedGenre = genre;
      _applyFilters();
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
    // by rating
    final Movie? heroMovie = _allMovies.isNotEmpty 
        ? _allMovies.reduce((curr, next) => curr.voteAverage > next.voteAverage ? curr : next) 
        : null;

    final displayMovies = _showAllMovies ? _filteredMovies : _filteredMovies.take(10).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchMovies,
              child: Stack(
                children: [
                  // HERO IMAGE BACKGROUND
                  if (heroMovie != null && _searchQuery.isEmpty)
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
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.black,
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.black,
                            child: const Center(
                              child: Icon(Icons.movie, size: 100, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),

                  
                  if (_searchQuery.isEmpty)
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

                  // CONTENT
                  SafeArea(
                    child: Column(
                      children: [
                        // Header
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
                                  IconButton(
                                    icon: const Icon(Icons.favorite, color: Colors.white),
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const FavoritePage())
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.logout, color: Colors.white),
                                    onPressed: _logout,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              if (_searchQuery.isEmpty) ...[
                                SizedBox(height: MediaQuery.of(context).size.height * 0.22),

                                // Hero Title & Play Button
                                if (heroMovie != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          heroMovie.title,
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            height: 1.1
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        GestureDetector(
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => DetailPage(movie: heroMovie))
                                          ),
                                          child: Container(
                                            width: 120,
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Colors.white, Color(0xFF666666)]
                                              ),
                                              borderRadius: BorderRadius.circular(30),
                                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                "Play Trailer",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 30),
                              ] else ...[
                                const SizedBox(height: 20),
                              ],

                              // Search Bar
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF272727).withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(30)
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    children: [
                                      Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          style: const TextStyle(color: Colors.white),
                                          decoration: InputDecoration(
                                            hintText: "Search movies...",
                                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      if (_searchQuery.isNotEmpty)
                                        IconButton(
                                          icon: const Icon(Icons.clear, color: Colors.white),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() => _searchQuery = "");
                                            _applyFilters();
                                          },
                                        ),
                                    ],
                                  ),
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
                                      onTap: () => _filterByGenre(genre),
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 10),
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: isSelected ? const Color(0xFF4E4E4E) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(20),
                                          border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.1)),
                                        ),
                                        child: Center(
                                          child: Text(
                                            genre,
                                            style: TextStyle(
                                              color: isSelected ? Colors.white : Colors.grey,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Section Header
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _searchQuery.isNotEmpty 
                                        ? "Search Results (${_filteredMovies.length})"
                                        : "Popular Movies",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16
                                      ),
                                    ),
                                    if (_filteredMovies.length > 10)
                                      GestureDetector(
                                        onTap: () {
                                          setState(() => _showAllMovies = !_showAllMovies);
                                        },
                                        child: Text(
                                          _showAllMovies ? "Show Less" : "See All",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.5),
                                            fontSize: 12
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // list
                              if (_showAllMovies || _searchQuery.isNotEmpty)
                                // See All
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.6,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                    ),
                                    itemCount: displayMovies.length,
                                    itemBuilder: (context, index) {
                                      final movie = displayMovies[index];
                                      return _buildMovieCard(movie);
                                    },
                                  ),
                                )
                              else
                                // Horizontal List untuk default view
                                SizedBox(
                                  height: 250,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    itemCount: displayMovies.length,
                                    itemBuilder: (context, index) {
                                      final movie = displayMovies[index];
                                      return Container(
                                        width: 150,
                                        margin: const EdgeInsets.only(right: 16),
                                        child: _buildMovieCard(movie), 
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
            ),
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetailPage(movie: movie))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF1a1a1a),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  movie.posterPath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / 
                              loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF1a1a1a),
                    child: const Center(
                      child: Icon(Icons.movie, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
          ),
          Text(
            "${movie.voteAverage} • ${movie.genre.split(',').first}",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12
            ),
          ),
        ],
      ),
    );
  }
}