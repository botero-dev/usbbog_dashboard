import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import 'day_cell.dart';

/// `Calendario · November 2026` (`3:3`) — 7 columns of 29 px, Sunday first.
class MiniMonthCalendar extends StatelessWidget {
  const MiniMonthCalendar({super.key, required this.weeks, this.onTap});

  static const double cellWidth = 29;
  static const double cellHeight = 16;

  final List<List<DateTime?>> weeks;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: cellWidth * 7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                for (final initial in weekdayInitials)
                  SizedBox(
                    width: cellWidth,
                    height: cellHeight,
                    child: Center(child: Text(initial, style: AppText.weekday)),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            for (final week in weeks)
              Row(
                children: [
                  for (final day in week)
                    SizedBox(
                      width: cellWidth,
                      height: cellHeight,
                      child: Center(child: DayCell(day: day)),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
