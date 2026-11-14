/// Weeks of [month], Sunday first.
///
/// Cells outside the month are `null`, so the caller can render the trailing
/// blanks the design shows after the last day.
List<List<DateTime?>> buildMonthWeeks(DateTime month) {
  final firstDay = DateTime(month.year, month.month);
  final leadingBlanks = firstDay.weekday % 7;
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

  final cells = <DateTime?>[
    ...List<DateTime?>.filled(leadingBlanks, null),
    for (var day = 1; day <= daysInMonth; day++)
      DateTime(month.year, month.month, day),
  ];

  while (cells.length % 7 != 0) {
    cells.add(null);
  }

  return [
    for (var start = 0; start < cells.length; start += 7)
      cells.sublist(start, start + 7),
  ];
}
