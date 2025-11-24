import 'package:app_rawg/service/rawg_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GamePage extends StatefulWidget {
  final int gameId;
  const GamePage({super.key, required this.gameId});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final RawgService _rawgService = RawgService();

  bool _loading = true;
  bool _moviesLoading = false;
  bool _showFullDescription = false;

  Map<String, dynamic>? _game;
  Map<String, dynamic>? _gameMovies;

  @override
  void initState() {
    super.initState();
    _loadGame();
  }

  Future<void> _loadGame() async {
    try {
      final result = await _rawgService.fetchGameDetails(widget.gameId);
      _game = result;

      if ((result["movies_count"] ?? 0) > 0) {
        _moviesLoading = true;
        final movies = await _rawgService.fetchGameMovies(widget.gameId);
        _gameMovies = movies;
        _moviesLoading = false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erro ao carregar jogo: $e")));
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[800],
      appBar: AppBar(
        title: Text(
          _game?['name'] ?? 'Carregando...',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _game == null
          ? const Center(
              child: Text(
                "Erro ao carregar dados do jogo.",
                style: TextStyle(color: Colors.white),
              ),
            )
          : _buildGameContent(),
    );
  }

  Widget _buildGameContent() {
    final bg = _game!['background_image'];
    final name = _game!['name'];
    final rating = _game!['rating'];
    final released = _game!['released'] ?? 'Sem data';
    final description = _game!['description_raw'] ?? "Sem descrição.";
    final genres =
        (_game!['genres'] as List?)
            ?.map((e) => e['name'].toString())
            .toList() ??
        [];
    final tags =
        (_game!['tags'] as List?)?.map((e) => e['name'].toString()).toList() ??
        [];
    final trailerUrl = _gameMovies?["results"][0]?["data"]?["max"];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bg != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [BoxShadow(color: Colors.black, blurRadius: 10)],
                ),
                child: Image.network(
                  bg,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) =>
                      loadingProgress == null
                      ? child
                      : Center(child: CircularProgressIndicator()),
                ),
              ),
            ),

          const SizedBox(height: 10),

          // Nome
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withAlpha(90),
                    offset: Offset(5, 5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Avaliação / Data de lançamento
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 22),
                const SizedBox(width: 4),
                Text(
                  rating.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  "Lançado: $released",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Trailer
          if (_moviesLoading)
            const Center(child: CircularProgressIndicator())
          else if (trailerUrl != null && trailerUrl.isNotEmpty) ...[
            _buildTrailerButton(trailerUrl),
            const SizedBox(height: 10),
          ],

          // Generos
          if (genres.isNotEmpty) _buildSection("Gêneros", genres),

          // Tags
          if (tags.isNotEmpty) _buildSection("Tags", tags),

          // Descrição
          _buildDescription(description),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTrailerButton(String url) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          final uri = Uri.parse(url);

          await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
        icon: const Icon(Icons.play_arrow),
        label: const Text("Ver Trailer"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber[300],
          foregroundColor: Colors.black,
          elevation: 5,
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        _buildSectionList(items),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSectionList(List<String> list) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: list.map((item) {
          return Material(
            color: Colors.blueGrey.shade700,
            elevation: 4,
            shadowColor: Colors.black54,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                item,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDescription(String text) {
    const int limit = 250;
    final bool longText = text.length > limit;
    final String visible = _showFullDescription || !longText
        ? text
        : '${text.substring(0, limit)}...';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Descrição",
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            visible,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.justify,
          ),

          if (longText)
            TextButton(
              onPressed: () =>
                  setState(() => _showFullDescription = !_showFullDescription),
              child: Text(
                _showFullDescription ? "Ver menos" : "Ver mais",
                style: const TextStyle(color: Colors.amber),
              ),
            ),
        ],
      ),
    );
  }
}
