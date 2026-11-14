import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/wireframe_scaffold.dart';
import '../models/account.dart';
import '../view_models/select_account_view_model.dart';
import 'add_account_view.dart';

/// `9:60` — pops the chosen [Account], or the one created by "Add Account".
class SelectAccountView extends StatefulWidget {
  const SelectAccountView({super.key, required this.kind});

  final AccountKind kind;

  @override
  State<SelectAccountView> createState() => _SelectAccountViewState();
}

class _SelectAccountViewState extends State<SelectAccountView> {
  late final SelectAccountViewModel _viewModel = SelectAccountViewModel.demo(
    widget.kind,
  );

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _addAccount() async {
    final account = await Navigator.of(context).push<Account>(
      MaterialPageRoute<Account>(
        builder: (_) => AddAccountView(kind: widget.kind),
      ),
    );
    if (account == null || !mounted) {
      return;
    }

    _viewModel.add(account);

    // The prototype goes Add Account → Connect → Select List, skipping this
    // screen, so hand the new account straight back to the caller.
    Navigator.of(context).pop(account);
  }

  @override
  Widget build(BuildContext context) {
    return WireframeScaffold(
      title: 'Select Account',
      child: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final accounts = _viewModel.accounts;
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.screenGutter),
            itemCount: accounts.length + 1,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.controlGap),
            itemBuilder: (context, index) {
              if (index == accounts.length) {
                return PrimaryButton(
                  label: 'Add Account',
                  onPressed: _addAccount,
                );
              }

              final account = accounts[index];
              return PrimaryButton(
                label: account.label,
                onPressed: () => Navigator.of(context).pop(account),
              );
            },
          );
        },
      ),
    );
  }
}
