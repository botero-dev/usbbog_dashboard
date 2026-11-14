import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/task.dart';

/// 24×24 outlined box + title (`9:51`).
class CheckboxRow extends StatelessWidget {
  const CheckboxRow({super.key, required this.task, required this.onChanged});

  final Task task;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onChanged,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.onDark),
            ),
            child: task.isDone
                ? const Icon(Icons.check, size: 16, color: AppColors.onDark)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(task.summary, style: AppText.body)),
        ],
      ),
    );
  }
}
