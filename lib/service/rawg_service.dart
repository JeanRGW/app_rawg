import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

enum GamePlatform {
  playstation5(187, "PlayStation 5"),
  playstation4(18, "PlayStation 4"),
  xboxSeries(186, "Xbox Series S/X"),
  xboxOne(1, "Xbox One"),
  nintendoSwitch(7, "Nintendo Switch");

  final int id;
  final String label;

  const GamePlatform(this.id, this.label);
}

enum SortParam {
  name('name', "Nome"),
  released('released', "Data de lançamento"),
  rating('rating', "Avaliação");

  final String param;
  final String label;

  const SortParam(this.param, this.label);
}

class SearchParams {
  String? search;
  List<GamePlatform>? platforms;
  SortParam? sortBy;
  bool? descending;

  SearchParams({this.search, this.platforms, this.sortBy, this.descending});
}

class GamesResponse {
  final List<Map<String, dynamic>> games;
  final bool hasMore;

  GamesResponse(this.games, this.hasMore);
}

class RawgService {
  final String apiKey = '4dc10e932c4944d8913b4e8c336c086b';
  final String baseUrl = 'https://api.rawg.io/api';

  Future<GamesResponse> fetchGames({
    int? page = 1,
    required SearchParams? sp,
  }) async {
    try {
      final searchParam = sp?.search != null && sp!.search!.isNotEmpty
          ? "&search=${sp.search}"
          : "";

      final platformsParam = sp?.platforms != null && sp!.platforms!.isNotEmpty
          ? "&platforms=${sp.platforms!.map((p) => p.id).join(',')}"
          : "&platforms=187,186,7";

      final sortParam = sp?.sortBy != null
          ? "&ordering=${sp!.descending == true ? '-' : ''}${sp.sortBy!.param}"
          : "";

      final uri = Uri.parse(
        '$baseUrl/games?key=$apiKey&page=$page&page_size=20&exclude_additions=true'
        '$searchParam'
        '$platformsParam'
        '$sortParam',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return GamesResponse(
          (data['results'] as List).cast<Map<String, dynamic>>(),
          data['next'] != null && data['next'].toString().isNotEmpty,
        );
      } else {
        throw Exception('Falha ao carregar jogos');
      }
    } on SocketException {
      throw Exception('Erro de conexão com a Internet');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchGameDetails(int gameId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/games/$gameId?key=$apiKey'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Falhar ao carragar detalhes do jogo');
      }
    } on SocketException {
      throw Exception('Erro de conexão com a Internet');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchGameMovies(int gameId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/games/$gameId/movies?key=$apiKey'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Falhar ao carragar trailers');
      }
    } on SocketException {
      throw Exception('Erro de conexão com a Internet');
    } catch (e) {
      rethrow;
    }
  }
}
