import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

enum GamePlatform {
  pc(4),
  playstation5(187),
  xboxSeriesX(186),
  nintendoSwitch(7);

  final int id;
  const GamePlatform(this.id);
}

class RawgService {
  final String apiKey = '4dc10e932c4944d8913b4e8c336c086b';
  final String baseUrl = 'https://api.rawg.io/api';

  Future<List<Map<String, dynamic>>> fetchGames({
    int? page = 1,
    String? search,
    String? platforms,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/games?key=$apiKey&page=$page${search != null ? '&search=$search' : ''}${platforms != null ? '&platforms=$platforms' : ''}',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
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
}
