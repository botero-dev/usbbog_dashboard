import 'package:flutter/foundation.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';

/// Backs both the dashboard card and the Pokedex screen.
class PokemonViewModel extends ChangeNotifier {
  PokemonViewModel(this._service, {this.pokemonId});

  /// `null` means today's Pokémon.
  final int? pokemonId;

  final PokemonService _service;

  Pokemon? pokemon;
  bool isLoading = false;
  String? error;

  bool _disposed = false;

  Future<void> load() async {
    await _fetch(() {
      final id = pokemonId;
      return id == null ? _service.daily() : _service.byId(id);
    });
  }

  /// Replaces the current Pokémon with a random one.
  Future<void> loadRandom() => _fetch(_service.random);

  Future<void> refresh() => load();

  Future<void> _fetch(Future<Pokemon> Function() request) async {
    if (isLoading) {
      return;
    }

    isLoading = true;
    error = null;
    _notify();

    try {
      pokemon = await request();
    } on Exception catch (failure) {
      error = failure.toString();
    }

    isLoading = false;
    _notify();
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
