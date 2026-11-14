const _months = [
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Agosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre',
];

const _weekdays = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

/// Column headers of the mini calendar, Sunday first — matches the Figma frame.
const weekdayInitials = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

/// `9:32`
String formatClock(DateTime time) {
  return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
}

/// `Lunes, Noviembre 16`
String formatLongDate(DateTime date) {
  return '${_weekdays[date.weekday - 1]}, ${_months[date.month - 1]} ${date.day}';
}
