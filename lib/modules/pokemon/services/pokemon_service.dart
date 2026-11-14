import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

/// Failure already translated into something the UI can show as-is.
class PokemonException implements Exception {
  const PokemonException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// PokeAPI. Owns the HTTP calls and their failure modes — nothing above this
/// class sees a status code.
class PokemonService {
  PokemonService({
    http.Client? client,
    DateTime Function()? now,
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client(),
       _now = now ?? DateTime.now;

  static const baseUrl = 'https://pokeapi.co/api/v2';

  final http.Client _client;
  final DateTime Function() _now;
  final Duration timeout;

  int? _dexCount;
  final Map<int, Pokemon> _cache = {};

  /// Total number of species, used to wrap the day of year.
  Future<int> dexCount() async {
    final cached = _dexCount;
    if (cached != null) {
      return cached;
    }

    final json = await _getJson('$baseUrl/pokemon-species?limit=1');
    final count = (json['count'] as num?)?.toInt() ?? 0;
    _dexCount = count;
    return count;
  }

  /// Today's Pokémon, stable for the whole day.
  Future<Pokemon> daily({DateTime? day}) async {
    final date = day ?? _now();
    final count = await dexCount();
    return byId(pokemonIdForDate(date, count));
  }

  Future<Pokemon> byId(int id) async {
    final cached = _cache[id];
    if (cached != null) {
      return cached;
    }

    final pokemonJson = await _getJson('$baseUrl/pokemon/$id');
    final speciesJson = await _species(id);

    final pokemon = Pokemon.fromJson(pokemonJson, speciesJson: speciesJson);
    _cache[id] = pokemon;
    return pokemon;
  }

  /// The flavour text is a nice-to-have: a missing species entry must not hide
  /// the Pokémon itself.
  Future<Map<String, dynamic>?> _species(int id) async {
    try {
      return await _getJson('$baseUrl/pokemon-species/$id');
    } on PokemonException {
      return null;
    }
  }

  Future<Map<String, dynamic>> _getJson(String url) async {
    try {
      final response = await _client.get(Uri.parse(url)).timeout(timeout);

      if (response.statusCode == 404) {
        throw const PokemonException(
          'No se encontró la información solicitada',
        );
      }
      if (response.statusCode != 200) {
        throw PokemonException('El servidor respondió ${response.statusCode}');
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const PokemonException('Respuesta inesperada del servidor');
      }
      return decoded;
    } on PokemonException {
      rethrow;
    } on TimeoutException {
      throw const PokemonException('La solicitud tardó demasiado');
    } catch (_) {
      throw const PokemonException('No se pudo conectar con el servidor');
    }
  }

  void close() => _client.close();
}
