import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// One day number of the mini calendar; a `null` day is the empty cell after the
/// last day of the month.
class DayCell extends StatelessWidget {
  const DayCell({super.key, this.day});

  final DateTime? day;

  @override
  Widget build(BuildContext context) {
    final day = this.day;
    if (day == null) {
      return const SizedBox.shrink();
    }

    return Text('${day.day}', style: AppText.dayNumber);
  }
}
