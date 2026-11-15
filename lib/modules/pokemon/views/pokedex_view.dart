import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/wireframe_scaffold.dart';
import '../models/pokemon.dart';
import '../services/pokemon_provider.dart';
import '../view_models/pokemon_view_model.dart';
import 'widgets/pokemon_artwork.dart';

/// `1:49` — Pokémon detail, with a random-Pokémon action in the app bar.
class PokedexView extends StatefulWidget {
  const PokedexView({super.key, required this.pokemon});

  final Pokemon pokemon;

  @override
  State<PokedexView> createState() => _PokedexViewState();
}

class _PokedexViewState extends State<PokedexView> {
  late final PokemonViewModel _viewModel = PokemonViewModel(
    PokemonProvider.service,
  )..pokemon = widget.pokemon;

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _random() async {
    await _viewModel.loadRandom();

    final error = _viewModel.error;
    if (error != null && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final pokemon = _viewModel.pokemon!;

        return WireframeScaffold(
          title: pokemon.displayName,
          backgroundColor: AppColors.pokedex,
          actions: [
            IconButton(
              onPressed: _viewModel.isLoading ? null : _random,
              tooltip: 'Pokémon al azar',
              icon: _viewModel.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.onLight,
                      ),
                    )
                  : const Icon(Icons.shuffle, color: AppColors.onLight),
            ),
          ],
          child: ListView(
            padding: const EdgeInsets.fromLTRB(27, 25, 27, 25),
            children: [PokedexContent(pokemon: pokemon)],
          ),
        );
      },
    );
  }
}

/// Artwork, types, measurements and flavour text, without the screen header.
class PokedexContent extends StatelessWidget {
  const PokedexContent({super.key, required this.pokemon});

  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: PokemonArtwork(
            imageUrl: pokemon.imageUrl,
            size: 262,
            radius: 0,
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [for (final type in pokemon.types) _TypeChip(label: type)],
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: _StatBox(
                label: 'Tamaño',
                value: formatHeight(pokemon.heightCm),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _StatBox(
                label: 'Peso',
                value: formatWeight(pokemon.weightG),
              ),
            ),
          ],
        ),
        if (pokemon.description.isNotEmpty) ...[
          const SizedBox(height: 32),
          Text(pokemon.description, style: AppText.body.copyWith(fontSize: 24)),
        ],
      ],
    );
  }
}

/// `123 cm` under a metre, `1,6 m` above it.
String formatHeight(int heightCm) {
  if (heightCm < 100) {
    return '$heightCm cm';
  }
  final metres = (heightCm / 100).toStringAsFixed(1).replaceAll('.', ',');
  return '$metres m';
}

/// `185 g` under a kilo, `5,4 kg` above it.
String formatWeight(int weightG) {
  if (weightG < 1000) {
    return '$weightG g';
  }
  final kilos = (weightG / 1000).toStringAsFixed(1).replaceAll('.', ',');
  return '$kilos kg';
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: AppText.body.copyWith(color: AppColors.onLight),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.body),
          const SizedBox(height: 8),
          Text(value, style: AppText.body.copyWith(fontSize: 24)),
        ],
      ),
    );
  }
}
