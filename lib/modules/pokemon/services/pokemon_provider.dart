import 'pokemon_service.dart';

/// Static access point for Pokémon data.
///
/// One instance lives for the whole app, so the day's Pokémon and the
/// `PokemonService` cache are shared by every card without threading a
/// container through the widget tree. Tests swap [service] for a fake-backed
/// one and call [reset] afterwards.
abstract final class PokemonProvider {
  static PokemonService? _service;

  static PokemonService get service => _service ??= PokemonService();

  static set service(PokemonService value) => _service = value;

  static void reset() => _service = null;
}
