import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/wireframe_scaffold.dart';
import '../models/immich_account.dart';
import '../services/immich_provider.dart';
import 'add_immich_account_view.dart';

/// `9:60` for Immich — existing accounts plus "Add Account". Pops the chosen
/// [ImmichAccount].
class ImmichAccountPickerView extends StatefulWidget {
  const ImmichAccountPickerView({super.key});

  @override
  State<ImmichAccountPickerView> createState() =>
      _ImmichAccountPickerViewState();
}

class _ImmichAccountPickerViewState extends State<ImmichAccountPickerView> {
  Future<void> _addAccount() async {
    final account = await Navigator.of(context).push<ImmichAccount>(
      MaterialPageRoute<ImmichAccount>(
        builder: (_) => const AddImmichAccountView(),
      ),
    );
    if (account == null || !mounted) {
      return;
    }

    // The prototype goes Add Account → Connect → Select List, so hand the new
    // account straight back to the caller.
    Navigator.of(context).pop(account);
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ImmichProvider.accounts;

    return WireframeScaffold(
      title: 'Select Account',
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.screenGutter),
        itemCount: accounts.length + 1,
        separatorBuilder: (_, _) =>
            const SizedBox(height: AppSpacing.controlGap),
        itemBuilder: (context, index) {
          if (index == accounts.length) {
            return PrimaryButton(label: 'Add Account', onPressed: _addAccount);
          }

          final account = accounts[index];
          return PrimaryButton(
            label: account.label,
            onPressed: () => Navigator.of(context).pop(account),
          );
        },
      ),
    );
  }
}
