import 'package:app_rawg/service/rawg_service.dart';
import 'package:app_rawg/view/auth_page.dart';
import 'package:app_rawg/view/game_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final SearchParams _searchParams = SearchParams();

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
      final newGames = await rawgService.fetchGames(
        page: _page,
        sp: _searchParams,
      );

      setState(() {
        _games.addAll(newGames.games);
        _isLoading = false;
        _page++;
        _hasMore = newGames.hasMore;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
          _fetchGames();
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
              onPressed: () => {Navigator.of(context).pop(), _fetchGames()},
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
        actions: [
          _userPopup(),
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              AuthPage.isGuest = false;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AuthPage()),
              );
            },
            icon: Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          spacing: 10,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey[700],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.only(left: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hint: Text(
                          "Pesquisar jogos...",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      controller: _searchController,
                      onSubmitted: _onSearch,
                    ),
                  ),
                  IconButton(
                    onPressed: _selectFilters,
                    icon: Icon(Icons.filter_alt),
                    color: Colors.white,
                  ),
                ],
              ),
            ),

            _isLoading && _games.isEmpty
                ? _loadingAnimation()
                : Expanded(child: _gamesGrid()),
          ],
        ),
      ),
    );
  }

  void _onSearch(String query) {
    setState(() {
      _games.clear();
      _page = 1;
      _hasMore = true;
      _searchParams.search = query;
    });
    _fetchGames();
  }

  void _selectFilters() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.blueGrey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final selectedPlatforms = <GamePlatform>{};
        SortParam? selectedSort = _searchParams.sortBy;
        bool descending = _searchParams.descending ?? false;

        if (_searchParams.platforms != null) {
          selectedPlatforms.addAll(_searchParams.platforms!);
        }

        return StatefulBuilder(
          builder: (context, setStateSB) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context)
                    .viewInsets
                    .bottom, // Padding dinâmico, para teclado / botões do sistema
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Ocupar só o necessário
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Filtros',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Plataformas
                        const Text(
                          'Plataformas',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Wrap(
                          spacing: 8,
                          children: GamePlatform.values.map((p) {
                            final label = p.label;
                            final isSelected = selectedPlatforms.contains(p);

                            return FilterChip(
                              label: Text(
                                label,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: Colors.amber[300],
                              backgroundColor: Colors.blueGrey[700],
                              onSelected: (v) {
                                setStateSB(() {
                                  if (v) {
                                    selectedPlatforms.add(p);
                                  } else {
                                    selectedPlatforms.remove(p);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 12),

                        // Ordenação
                        const Text(
                          'Ordenar por',
                          style: TextStyle(color: Colors.white70),
                        ),

                        RadioGroup<SortParam>(
                          groupValue: selectedSort,
                          onChanged: (value) {
                            setStateSB(() => selectedSort = value);
                          },
                          child: Column(
                            children: SortParam.values.map((s) {
                              return ListTile(
                                dense: true,
                                minVerticalPadding: 0,
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  s.label,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                trailing: Radio<SortParam>(value: s),
                                onTap: () => setStateSB(() => selectedSort = s),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 4),

                        Row(
                          children: [
                            const Text(
                              'Decrescente',
                              style: TextStyle(color: Colors.white70),
                            ),
                            const Spacer(),
                            Switch(
                              value: descending,
                              activeThumbColor: Colors.amber[300],
                              onChanged: (v) =>
                                  setStateSB(() => descending = v),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.white24),
                                ),
                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _searchParams.platforms =
                                        selectedPlatforms.isEmpty
                                        ? null
                                        : selectedPlatforms.toList();
                                    _searchParams.sortBy = selectedSort;
                                    _searchParams.descending = descending;
                                    _games.clear();
                                    _page = 1;
                                    _hasMore = true;
                                  });
                                  Navigator.of(context).pop();
                                  _fetchGames();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber[300],
                                  foregroundColor: Colors.black,
                                ),
                                child: const Text('Aplicar'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
      itemCount: _hasMore ? _games.length + 1 : _games.length,
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

        return _gameCard(_games[index]);
      },
    );
  }

  Widget _gameCard(Map<String, dynamic> game) {
    final imageUrl = game['background_image'];

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GamePage(gameId: game['id'])),
      ),
      child: Card(
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
                            loadingBuilder: (context, child, loadingProgress) {
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
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
                          Icon(Icons.star, size: 16, color: Colors.amber[800]),
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
      ),
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

  Widget _userPopup() {
    final user = FirebaseAuth.instance.currentUser;

    String label;
    if (AuthPage.isGuest) {
      label = "Visitante";
    } else {
      label = user?.email ?? "Desconhecido";
    }

    return PopupMenuButton(
      icon: const Icon(Icons.person, color: Colors.white),
      color: Colors.blueGrey[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Usuário atual",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
