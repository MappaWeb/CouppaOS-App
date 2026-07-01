abstract final class CouponFormHelpers {
  static int parseInt(dynamic raw) {
    final cleaned = (raw ?? '').toString().replaceAll('.', '').trim();
    return int.tryParse(cleaned) ?? 0;
  }

  static String? toIsoUtc(dynamic raw) {
    final dt = parseDateTime(raw);
    if (dt == null) return null;
    return dt.toUtc().toIso8601String();
  }

  /// Parse format `dd/MM/yyyy HH:mm` từ `FieldDateTime`. Fallback: ISO-8601.
  static DateTime? parseDateTime(dynamic raw) {
    final s = raw?.toString().trim();
    if (s == null || s.isEmpty) return null;
    final parts = s.split(' ');
    if (parts.length == 2) {
      final d = parts[0].split('/');
      final t = parts[1].split(':');
      if (d.length == 3 && t.length >= 2) {
        final year = int.tryParse(d[2]);
        final month = int.tryParse(d[1]);
        final day = int.tryParse(d[0]);
        final hour = int.tryParse(t[0]);
        final min = int.tryParse(t[1]);
        if (year != null && month != null && day != null && hour != null && min != null) {
          return DateTime(year, month, day, hour, min);
        }
      }
    }
    return DateTime.tryParse(s);
  }

  static String formatDateTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
  }

  static Map<String, dynamic>? buildUsage(Map<String, dynamic> f) {
    final days = ((f['daysOfWeek'] as List?) ?? const []).cast<int>();
    final start = ((f['timeStart'] as String?) ?? '').trim();
    final end = ((f['timeEnd'] as String?) ?? '').trim();
    final hasWindow = start.isNotEmpty && end.isNotEmpty;
    if (days.isEmpty && !hasWindow) return null;
    return {
      if (days.isNotEmpty) 'daysOfWeek': days,
      if (hasWindow)
        'windows': [
          {'start': start, 'end': end},
        ],
    };
  }

  static Map<String, dynamic> buildAcceptance(Map<String, dynamic> f) {
    final scope = (f['scope'] as String?) ?? 'all';
    final storeIds = splitIds(f['storeIds']);
    final partnerIds = splitIds(f['partnerIds']);
    return {
      'scope': scope,
      if (scope == 'stores' && storeIds.isNotEmpty) 'storeIds': storeIds,
      if (partnerIds.isNotEmpty)
        'partners': partnerIds.map((id) => {'merchantId': id, 'scope': 'all'}).toList(),
    };
  }

  static List<String> splitIds(dynamic raw) {
    final s = raw?.toString() ?? '';
    if (s.isEmpty) return const [];
    return s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  static String? validatePositiveInt(dynamic raw, String message) {
    final cleaned = (raw ?? '').toString().replaceAll('.', '').trim();
    if (cleaned.isEmpty) return null;
    final n = int.tryParse(cleaned);
    if (n == null || n <= 0) return message;
    return null;
  }
}
