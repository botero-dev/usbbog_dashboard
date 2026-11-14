import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/wireframe_scaffold.dart';
import '../models/account.dart';
import '../view_models/add_account_view_model.dart';

/// `9:85` — Server / User / Pass / Connect. Pops the created [Account].
class AddAccountView extends StatefulWidget {
  const AddAccountView({super.key, required this.kind});

  final AccountKind kind;

  @override
  State<AddAccountView> createState() => _AddAccountViewState();
}

class _AddAccountViewState extends State<AddAccountView> {
  late final AddAccountViewModel _viewModel = AddAccountViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final account = await _viewModel.connect(widget.kind);
    if (account == null || !mounted) {
      return;
    }
    Navigator.of(context).pop(account);
  }

  @override
  Widget build(BuildContext context) {
    return WireframeScaffold(
      title: 'Add Account',
      child: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final error = _viewModel.error;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screenGutter),
            children: [
              _Field(controller: _viewModel.server, hint: 'Server'),
              const SizedBox(height: AppSpacing.controlGap),
              _Field(controller: _viewModel.user, hint: 'User'),
              const SizedBox(height: AppSpacing.controlGap),
              _Field(controller: _viewModel.pass, hint: 'Pass', obscure: true),
              const SizedBox(height: AppSpacing.controlGap),
              PrimaryButton(
                label: _viewModel.isConnecting ? 'Connecting...' : 'Connect',
                accent: true,
                enabled: !_viewModel.isConnecting,
                onPressed: _connect,
              ),
              if (error != null) ...[
                const SizedBox(height: 16),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: AppText.body.copyWith(color: Colors.red.shade700),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    this.obscure = false,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.controlHeight,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        style: AppText.button,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppText.button.copyWith(
            color: AppColors.onLight.withValues(alpha: 0.6),
          ),
          filled: true,
          fillColor: AppColors.surface,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
