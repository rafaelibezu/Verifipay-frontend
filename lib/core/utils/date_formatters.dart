class DateFormatters {
  const DateFormatters._();

  static const List<String> _months = [
    'ene.',
    'feb.',
    'mar.',
    'abr.',
    'may.',
    'jun.',
    'jul.',
    'ago.',
    'sept.',
    'oct.',
    'nov.',
    'dic.',
  ];

  static String date(DateTime? value) {
    if (value == null) return '-';

    final local = value.toLocal();
    return '${local.day} ${_months[local.month - 1]} ${local.year}';
  }

  static String time(DateTime? value) {
    if (value == null) return '-';

    final local = value.toLocal();
    final period = local.hour >= 12 ? 'p. m.' : 'a. m.';
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');

    return '$hour:$minute $period';
  }

  static String dateTime(DateTime? value) {
    if (value == null) return '-';

    return '${date(value)} - ${time(value)}';
  }

  static String shortRelative(DateTime? value) {
    if (value == null) return 'Hace un momento';

    final local = value.toLocal();
    final now = DateTime.now();
    final difference = now.difference(local);

    if (difference.inMinutes < 1) return 'Hace un momento';
    if (difference.inMinutes < 60) return 'Hace ${difference.inMinutes} min';
    if (_isSameDay(local, now)) return 'Hoy, ${time(local)}';

    final yesterday = now.subtract(const Duration(days: 1));
    if (_isSameDay(local, yesterday)) return 'Ayer, ${time(local)}';

    return dateTime(local);
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
