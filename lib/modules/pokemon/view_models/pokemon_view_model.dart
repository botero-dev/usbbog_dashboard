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
    if (isLoading) {
      return;
    }

    isLoading = true;
    error = null;
    _notify();

    try {
      final id = pokemonId;
      pokemon = id == null ? await _service.daily() : await _service.byId(id);
    } on Exception catch (failure) {
      error = failure.toString();
    }

    isLoading = false;
    _notify();
  }

  Future<void> refresh() => load();

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
