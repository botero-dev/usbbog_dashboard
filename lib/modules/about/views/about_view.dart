import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/wireframe_scaffold.dart';

/// "Acerca de" settings screen: what the app is, which APIs it uses and where
/// the project lives. Doubles as the credits screen.
class AboutView extends StatelessWidget {
  const AboutView({super.key});

  static const repository = 'https://github.com/botero-dev/usbbog_dashboard';
  static const figma =
      'https://www.figma.com/design/scjsoLRlPRoRtvTiT5HzU8/Tablero';

  @override
  Widget build(BuildContext context) {
    return WireframeScaffold(
      title: 'Acerca de',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.page,
          AppSpacing.page,
          AppSpacing.block,
        ),
        children: [
          Center(
            child: Image.asset(
              'assets/images/app_logo.png',
              width: 96,
              height: 96,
              semanticLabel: 'Logotipo de Tablero',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tablero',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              height: 1.2,
              color: AppColors.onLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Versión 1.0.0',
            textAlign: TextAlign.center,
            style: AppText.caption.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          Text(
            'Un tablero personal que reúne en una sola pantalla la hora, el '
            'Pokémon del día, una foto de tu galería y tus tareas. Cada tarjeta '
            'se agrega o se quita con el botón +.',
            style: AppText.body.copyWith(color: AppColors.onLight, height: 1.5),
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Fuentes de datos'),
          const _LinkRow(
            icon: Icons.catching_pokemon,
            label: 'PokeAPI',
            value: 'https://pokeapi.co/',
          ),
          const _LinkRow(
            icon: Icons.photo_library_outlined,
            label: 'Immich',
            value: 'Servidor propio + clave de API',
          ),
          const _LinkRow(
            icon: Icons.event_available_outlined,
            label: 'CalDAV',
            value: 'Protocolo abierto para listas de tareas',
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Proyecto'),
          const _LinkRow(
            icon: Icons.code,
            label: 'Repositorio',
            value: repository,
          ),
          const _LinkRow(
            icon: Icons.design_services_outlined,
            label: 'Diseño en Figma',
            value: figma,
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Créditos'),
          Text(
            'Taller de Interacción Humano-Computador · Universidad de San Buenaventura '
            '· Andrés Botero',
            style: AppText.caption.copyWith(color: Colors.black54, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppText.body.copyWith(
          color: AppColors.onLight,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.header),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppText.body.copyWith(color: AppColors.onLight),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  value,
                  style: AppText.caption.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
