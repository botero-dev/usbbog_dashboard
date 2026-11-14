import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/wireframe_scaffold.dart';
import '../models/pokemon.dart';

/// `1:49` — Pokémon detail.
class PokedexView extends StatelessWidget {
  const PokedexView({super.key, required this.pokemon});

  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    return WireframeScaffold(
      title: pokemon.name,
      backgroundColor: AppColors.pokedex,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(27, 25, 27, 25),
        children: [
          Container(height: 262, color: AppColors.imagePlaceholder),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final type in pokemon.types) _TypeChip(label: type),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: 'Tamaño',
                  value: '${pokemon.heightCm} cm',
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _StatBox(label: 'Peso', value: '${pokemon.weightG} g'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(pokemon.description, style: AppText.body.copyWith(fontSize: 24)),
        ],
      ),
    );
  }
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
