import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/wireframe_scaffold.dart';

class PickerOption {
  const PickerOption({required this.id, required this.label});

  final String id;
  final String label;
}

/// The generic "Select List" screen (`9:102`). Pops the chosen option.
class OptionPickerView extends StatelessWidget {
  const OptionPickerView({
    super.key,
    required this.title,
    required this.options,
    this.emptyMessage = 'No hay opciones disponibles',
  });

  final String title;
  final List<PickerOption> options;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return WireframeScaffold(
      title: title,
      child: options.isEmpty
          ? Center(
              child: Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(color: AppColors.onLight),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.screenGutter),
              itemCount: options.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.controlGap),
              itemBuilder: (context, index) {
                final option = options[index];
                return PrimaryButton(
                  label: option.label,
                  onPressed: () => Navigator.of(context).pop(option),
                );
              },
            ),
    );
  }
}
