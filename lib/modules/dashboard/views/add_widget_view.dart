import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/views/option_picker_view.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/wireframe_scaffold.dart';
import '../../accounts/models/account.dart';
import '../../accounts/views/select_account_view.dart';
import '../../photos/models/album.dart';
import '../../photos/models/immich_account.dart';
import '../../photos/views/album_picker_view.dart';
import '../../photos/views/immich_account_picker_view.dart';
import '../../tasks/models/task_list.dart';
import '../models/widget_config.dart';

/// `1:50` — pick a widget type. Pops the resulting [WidgetConfig].
class AddWidgetView extends StatelessWidget {
  const AddWidgetView({super.key});

  // Replaced by `caldav_service` in M4.
  static const _demoTaskLists = [
    TaskList(id: 'mis-tareas', displayName: 'Mis Tareas'),
  ];

  @override
  Widget build(BuildContext context) {
    return WireframeScaffold(
      title: 'Add widget',
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.screenGutter),
        itemCount: 4,
        separatorBuilder: (_, _) =>
            const SizedBox(height: AppSpacing.controlGap),
        itemBuilder: (context, index) {
          return switch (index) {
            0 => PrimaryButton(
              label: 'Fecha/Hora',
              onPressed: () => Navigator.of(context).pop(const ClockConfig()),
            ),
            1 => PrimaryButton(
              label: 'Lista de Tareas',
              onPressed: () => _addTasks(context),
            ),
            2 => PrimaryButton(
              label: 'Galería Immich',
              onPressed: () => _addGallery(context),
            ),
            _ => PrimaryButton(
              label: 'Pokemon del dia',
              onPressed: () => Navigator.of(context).pop(const PokemonConfig()),
            ),
          };
        },
      ),
    );
  }

  /// Immich ships with the demo host and key in [ImmichProvider], so the album
  /// list is the only step — no account screen.
  /// Account (demo or newly added) -> album.
  Future<void> _addGallery(BuildContext context) async {
    final account = await Navigator.of(context).push<ImmichAccount>(
      MaterialPageRoute(builder: (_) => const ImmichAccountPickerView()),
    );
    if (account == null || !context.mounted) {
      return;
    }

    final album = await Navigator.of(context).push<Album>(
      MaterialPageRoute(builder: (_) => AlbumPickerView(account: account)),
    );
    if (album == null || !context.mounted) {
      return;
    }

    Navigator.of(context).pop(
      GalleryConfig(
        accountId: account.id,
        albumId: album.id,
        label: album.name,
      ),
    );
  }

  Future<void> _addTasks(BuildContext context) async {
    final account = await Navigator.of(context).push<Account>(
      MaterialPageRoute(
        builder: (_) => const SelectAccountView(kind: AccountKind.caldav),
      ),
    );
    if (account == null || !context.mounted) {
      return;
    }

    final list = await Navigator.of(context).push<PickerOption>(
      MaterialPageRoute(
        builder: (_) => OptionPickerView(
          title: 'Select List',
          options: [
            for (final taskList in _demoTaskLists)
              PickerOption(id: taskList.id, label: taskList.displayName),
          ],
        ),
      ),
    );
    if (list == null || !context.mounted) {
      return;
    }

    Navigator.of(context).pop(
      TasksConfig(accountId: account.id, listId: list.id, label: list.label),
    );
  }
}
