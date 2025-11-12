import 'package:app_rawg/service/rawg_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RawgService rawgService = RawgService();
  final List<Map<String, dynamic>> _games = [];

  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchGames();
  }

  Future<void> _fetchGames() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newGames = await rawgService.fetchGames(page: _page);
      setState(() {
        _games.addAll(newGames);
        _isLoading = false;
        _page++;
        if (newGames.isEmpty) {
          _hasMore = false;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Erro"),
          content: Text("Erro ao carregar jogos: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[800],
      appBar: AppBar(
        title: Text("App RAWG"),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: _isLoading ? _loadingAnimation() : _gamesGrid(),
      ),
    );
  }

  Widget _loadingAnimation() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _gamesGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: _games.length,
      itemBuilder: (context, index) {
        final game = _games[index];
        final imageUrl = game['background_image'];

        return Card(
          color: Colors.blueGrey[700],
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    } else {
                                      return _loadingAnimation();
                                    }
                                  },
                            )
                          : _placeholderImage(),
                    ),

                    Positioned(
                      top: 3,
                      right: 3,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Text('${game['rating'] ?? 'N/A'}'),
                            Icon(Icons.star, size: 14, color: Colors.amber),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    game['name'] ?? 'Nome Desconhecido',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${game['released'] ?? 'sem data.'}',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(Icons.image_not_supported, color: Colors.white54, size: 40),
      ),
    );
  }
}
