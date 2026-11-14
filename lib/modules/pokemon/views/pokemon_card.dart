import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/surface_card.dart';
import '../models/pokemon.dart';
import '../services/pokemon_provider.dart';
import '../view_models/pokemon_view_model.dart';
import 'pokedex_view.dart';
import 'widgets/pokemon_artwork.dart';

/// Dashboard tile (`1:26`). Shows today's Pokémon and opens the Pokedex.
class PokemonCard extends StatefulWidget {
  const PokemonCard({super.key, this.onLongPress});

  final VoidCallback? onLongPress;

  @override
  State<PokemonCard> createState() => _PokemonCardState();
}

class _PokemonCardState extends State<PokemonCard> {
  late final PokemonViewModel _viewModel = PokemonViewModel(
    PokemonProvider.service,
  )..load();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      height: 155,
      padding: const EdgeInsets.all(12),
      onLongPress: widget.onLongPress,
      child: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => AsyncView(
          isLoading: _viewModel.isLoading,
          error: _viewModel.error,
          onRetry: _viewModel.refresh,
          builder: (context) => _content(_viewModel.pokemon!),
        ),
      ),
    );
  }

  Widget _content(Pokemon pokemon) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => PokedexView(pokemon: pokemon),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PokemonArtwork(imageUrl: pokemon.imageUrl),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pokemon del día', style: AppText.caption),
                const SizedBox(height: 6),
                Text(
                  pokemon.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.title,
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    pokemon.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
