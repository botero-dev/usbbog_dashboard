import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/surface_card.dart';
import '../models/pokemon.dart';
import 'pokedex_view.dart';

/// Dashboard tile (`1:26`). Opens the Pokedex.
class PokemonCard extends StatelessWidget {
  const PokemonCard({super.key, this.onLongPress});

  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      height: 155,
      padding: EdgeInsets.zero,
      onLongPress: onLongPress,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const PokedexView(pokemon: demoPokemon),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 131,
              height: 131,
              decoration: BoxDecoration(
                color: AppColors.imagePlaceholder,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pokemon del día', style: AppText.caption),
                  const SizedBox(height: 10),
                  Text(demoPokemon.name, style: AppText.title),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Text(
                      demoPokemon.summary,
                      style: AppText.body,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
