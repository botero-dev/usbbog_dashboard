import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/month_grid.dart';

/// Ticks once per second and exposes the formatted values the card renders.
class ClockViewModel extends ChangeNotifier {
  ClockViewModel({DateTime Function()? now}) : _now = now ?? DateTime.now {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => notifyListeners(),
    );
  }

  final DateTime Function() _now;
  Timer? _timer;

  DateTime get now => _now();
  String get clockText => formatClock(now);
  String get longDateText => formatLongDate(now);
  List<List<DateTime?>> get weeks => buildMonthWeeks(now);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
