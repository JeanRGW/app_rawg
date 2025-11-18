import 'package:app_rawg/service/rawg_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RawgService rawgService = RawgService();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _games = [];

  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchGames();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _fetchGames();
      }
    });
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
        centerTitle: true,
        title: Text(
          "RAWG",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: 5,
          ),
        ),
        backgroundColor: Colors.blueGrey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.elliptical(40, 10),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: _isLoading && _games.isEmpty
            ? _loadingAnimation()
            : _gamesGrid(),
      ),
    );
  }

  Widget _loadingAnimation() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _gamesGrid() {
    return GridView.builder(
      controller: _scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: _games.length + 1,
      itemBuilder: (context, index) {
        if (index == _games.length) {
          return _hasMore
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                )
              : SizedBox.shrink();
        }

        final game = _games[index];
        final imageUrl = game['background_image'];

        return Card(
          color: Colors.blueGrey[700],
          elevation: 6,
          shadowColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.black.withAlpha(70), width: 1.2),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

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
                                    if (loadingProgress == null) return child;
                                    return _loadingAnimation();
                                  },
                            )
                          : _placeholderImage(),
                    ),

                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withAlpha(50),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.white.withAlpha(80),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${game['rating'] ?? 'N/A'}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber[800],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  game['name'] ?? 'Nome Desconhecido',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    height: 1.15,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withAlpha(60),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.black.withAlpha(60),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${game['released'] ?? 'sem data.'}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
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
