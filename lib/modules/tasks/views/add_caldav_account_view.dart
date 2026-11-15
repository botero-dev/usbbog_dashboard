import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/wireframe_scaffold.dart';
import '../view_models/add_caldav_account_view_model.dart';

/// `9:85` — Server / User / Pass → Connect. Pops the created account.
class AddCaldavAccountView extends StatefulWidget {
  const AddCaldavAccountView({super.key});

  @override
  State<AddCaldavAccountView> createState() => _AddCaldavAccountViewState();
}

class _AddCaldavAccountViewState extends State<AddCaldavAccountView> {
  late final AddCaldavAccountViewModel _viewModel = AddCaldavAccountViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final account = await _viewModel.connect();
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
              _Field(
                controller: _viewModel.server,
                hint: 'Server',
                helper: 'https://caldav.fastmail.com',
              ),
              const SizedBox(height: AppSpacing.controlGap),
              _Field(controller: _viewModel.user, hint: 'User'),
              const SizedBox(height: AppSpacing.controlGap),
              _Field(
                controller: _viewModel.pass,
                hint: 'App password',
                obscure: true,
              ),
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
    this.helper,
    this.obscure = false,
  });

  final TextEditingController controller;
  final String hint;
  final String? helper;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    final helper = this.helper;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
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
        ),
        if (helper != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              helper,
              style: AppText.caption.copyWith(color: AppColors.onLight),
            ),
          ),
      ],
    );
  }
}
