import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/wireframe_scaffold.dart';
import '../models/caldav_account.dart';
import '../services/caldav_provider.dart';
import 'add_caldav_account_view.dart';

/// `9:60` for CalDAV — existing accounts plus "Add Account". Pops the chosen
/// [CaldavAccount].
class CaldavAccountPickerView extends StatefulWidget {
  const CaldavAccountPickerView({super.key});

  @override
  State<CaldavAccountPickerView> createState() =>
      _CaldavAccountPickerViewState();
}

class _CaldavAccountPickerViewState extends State<CaldavAccountPickerView> {
  Future<void> _addAccount() async {
    final account = await Navigator.of(context).push<CaldavAccount>(
      MaterialPageRoute<CaldavAccount>(
        builder: (_) => const AddCaldavAccountView(),
      ),
    );
    if (account == null || !mounted) {
      return;
    }

    // Add Account → Connect → Select List, as in the prototype.
    Navigator.of(context).pop(account);
  }

  @override
  Widget build(BuildContext context) {
    final accounts = CalDavProvider.accounts;

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
