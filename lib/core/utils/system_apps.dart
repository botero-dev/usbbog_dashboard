import 'package:flutter/material.dart';

enum SystemApp {
  clock('reloj'),
  calendar('calendario');

  const SystemApp(this.label);

  final String label;
}

/// The design delegates clock and calendar to the OS instead of drawing screens.
///
/// `url_launcher` deep links land in M1; until then the tap is acknowledged so
/// the button stays wired and discoverable.
void openSystemApp(BuildContext context, SystemApp app) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Abrir app del sistema: ${app.label}')),
  );
}
