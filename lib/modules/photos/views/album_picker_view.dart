import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/wireframe_scaffold.dart';
import '../models/immich_account.dart';
import '../services/immich_provider.dart';
import '../view_models/album_picker_view_model.dart';

/// `9:102` for Immich — lists the account's albums and pops the chosen one.
class AlbumPickerView extends StatefulWidget {
  const AlbumPickerView({super.key, required this.account});

  final ImmichAccount account;

  @override
  State<AlbumPickerView> createState() => _AlbumPickerViewState();
}

class _AlbumPickerViewState extends State<AlbumPickerView> {
  late final AlbumPickerViewModel _viewModel = AlbumPickerViewModel(
    ImmichProvider.serviceFor(widget.account.id),
  )..load();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WireframeScaffold(
      title: 'Select List',
      child: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final error = _viewModel.error;
          if (error != null) {
            return _Message(
              text: error,
              action: 'Reintentar',
              onAction: _viewModel.load,
            );
          }

          final albums = _viewModel.albums;
          if (albums.isEmpty) {
            return const _Message(text: 'No hay álbumes en esta cuenta');
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.screenGutter),
            itemCount: albums.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.controlGap),
            itemBuilder: (context, index) {
              final album = albums[index];
              return PrimaryButton(
                label: album.name,
                onPressed: () => Navigator.of(context).pop(album),
              );
            },
          );
        },
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.action, this.onAction});

  final String text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppText.body.copyWith(color: AppColors.onLight),
            ),
            if (action != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onAction, child: Text(action!)),
            ],
          ],
        ),
      ),
    );
  }
}
