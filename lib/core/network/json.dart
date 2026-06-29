/// The Lead360 API serializes JSON in **PascalCase** (request + response), while
/// some endpoints/tools may emit camelCase. These helpers read a value by trying
/// several key casings so models don't care which the server used.

Object? _raw(Map<String, dynamic> j, String key) {
  if (j.containsKey(key)) return j[key];
  // PascalCase ↔ camelCase fallbacks.
  final pascal = key.isEmpty ? key : key[0].toUpperCase() + key.substring(1);
  final camel = key.isEmpty ? key : key[0].toLowerCase() + key.substring(1);
  if (j.containsKey(pascal)) return j[pascal];
  if (j.containsKey(camel)) return j[camel];
  return null;
}

String? str(Map<String, dynamic> j, String key) {
  final v = _raw(j, key);
  return v?.toString();
}

int intOr(Map<String, dynamic> j, String key, [int fallback = 0]) {
  final v = _raw(j, key);
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? fallback;
}

double doubleOr(Map<String, dynamic> j, String key, [double fallback = 0]) {
  final v = _raw(j, key);
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '') ?? fallback;
}

bool boolOr(Map<String, dynamic> j, String key, [bool fallback = false]) {
  final v = _raw(j, key);
  if (v is bool) return v;
  if (v is String) return v.toLowerCase() == 'true';
  return fallback;
}

DateTime? dateOrNull(Map<String, dynamic> j, String key) {
  final v = str(j, key);
  if (v == null || v.isEmpty) return null;
  return DateTime.tryParse(v);
}

List<dynamic> listOr(Map<String, dynamic> j, String key) {
  final v = _raw(j, key);
  return v is List ? v : const [];
}

/// Standard paged envelope: { items: [...], totalCount, page, pageSize }.
class Paged<T> {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;

  const Paged({required this.items, required this.totalCount, required this.page, required this.pageSize});

  factory Paged.fromJson(Map<String, dynamic> j, T Function(Map<String, dynamic>) item) => Paged(
        items: listOr(j, 'items').whereType<Map<String, dynamic>>().map(item).toList(),
        totalCount: intOr(j, 'totalCount'),
        page: intOr(j, 'page', 1),
        pageSize: intOr(j, 'pageSize', 20),
      );
}
