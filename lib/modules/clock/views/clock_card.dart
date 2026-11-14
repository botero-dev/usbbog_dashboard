import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/system_apps.dart';
import '../view_models/clock_view_model.dart';
import 'widgets/mini_month_calendar.dart';

/// Clock + mini calendar + long date (`1:40` and `1:18`).
///
/// Tapping the clock or the calendar delegates to the OS app.
class ClockCard extends StatefulWidget {
  const ClockCard({super.key, this.onLongPress});

  final VoidCallback? onLongPress;

  @override
  State<ClockCard> createState() => _ClockCardState();
}

class _ClockCardState extends State<ClockCard> {
  late final ClockViewModel _viewModel = ClockViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.onLongPress,
      child: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 100,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => openSystemApp(context, SystemApp.clock),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _viewModel.clockText,
                            style: AppText.clock,
                          ),
                        ),
                      ),
                    ),
                    MiniMonthCalendar(
                      weeks: _viewModel.weeks,
                      onTap: () => openSystemApp(context, SystemApp.calendar),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.block),
              Text(_viewModel.longDateText, style: AppText.title),
            ],
          );
        },
      ),
    );
  }
}
