// Lõi cache dùng chung cho dữ liệu tham chiếu ít thay đổi.
//
// `CachedRefDataSource` là decorator bọc một [DataSource] bất kỳ và cache kết
// quả `list()` của các endpoint khớp `cachePrefixes` vào Hive (box
// 'reference_cache'). Không chứa kiến thức nghiệp vụ — muốn cache nội dung mới
// thì khai báo factory trong `cached_data_sources.dart`.
import 'dart:convert';

import 'package:core_data/core_data.dart';
import 'package:core_storage/core_storage.dart';

/// Box dùng chung cho mọi cache tham chiếu.
/// Phải được khai báo trong SharedStorage.init(boxes: [...]).
const referenceCacheBox = 'reference_cache';

/// TTL mặc định cho dữ liệu tham chiếu (ít thay đổi nên cache lâu).
const referenceCacheTtl = Duration(days: 30);

/// Số bản ghi tối đa kéo về khi cache 1 list (lấy trọn danh sách trong 1 lần để
/// mọi caller dùng chung cùng một payload đầy đủ).
const referenceCacheFullLimit = 1000;

/// Xóa toàn bộ cache dữ liệu tham chiếu (buộc tải lại dữ liệu mới).
Future<void> clearReferenceCache() => Setting(referenceCacheBox).clear();

/// Decorator bọc một [DataSource], cache kết quả `list()` của các endpoint khớp
/// [cachePrefixes] vào Hive. Các thao tác khác và list không khớp được uỷ quyền
/// nguyên trạng cho [_inner].
class CachedRefDataSource implements DataSource {
  CachedRefDataSource(
    this._inner, {
    required this.cachePrefixes,
    this.fullLimit = referenceCacheFullLimit,
    Duration ttl = referenceCacheTtl,
  }) : _ttl = ttl;

  final DataSource _inner;
  final Set<String> cachePrefixes;
  final int fullLimit;
  final Duration _ttl;
  final _box = Setting(referenceCacheBox);

  String _normalize(String resource) =>
      resource.startsWith('/') ? resource.substring(1) : resource;

  bool _isCacheable(String resource, QuerySpec? query) {
    // Có search server-side thì không cache (mỗi keyword trả tập khác nhau).
    final search = query?.search;
    if (search != null && search.isNotEmpty) return false;
    final r = _normalize(resource);
    return cachePrefixes.any(r.startsWith);
  }

  String _key(String resource) => 'list:${_normalize(resource)}';

  @override
  Future<DataResult> list(String resource, {QuerySpec? query}) async {
    if (!_isCacheable(resource, query)) {
      return _inner.list(resource, query: query);
    }

    final key = _key(resource);
    final cached = _read(key);
    if (cached != null && cached.fresh) {
      return DataResult.list(items: cached.items);
    }

    // Luôn kéo trọn danh sách (bỏ qua phân trang của caller) để cache đầy đủ và
    // mọi caller chia sẻ cùng một payload.
    final result = await _inner.list(
      resource,
      query: QuerySpec(filters: query?.filters ?? const {}, limit: fullLimit),
    );
    if (result.isSuccess && result.items != null) {
      await _write(key, result.items!);
      return result;
    }
    // API lỗi: fallback cache cũ (kể cả đã hết hạn) nếu có để UI vẫn hiển thị.
    if (cached != null) return DataResult.list(items: cached.items);
    return result;
  }

  _RefCacheEntry? _read(String key) {
    final raw = _box.get<String>(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final ts = (map['ts'] as num?)?.toInt() ?? 0;
      final items = (map['items'] as List?) ?? const <dynamic>[];
      final age = DateTime.now().millisecondsSinceEpoch - ts;
      return _RefCacheEntry(items: items, fresh: age < _ttl.inMilliseconds);
    } on Object {
      return null;
    }
  }

  Future<void> _write(String key, List<dynamic> items) async {
    final payload = jsonEncode(<String, dynamic>{
      'ts': DateTime.now().millisecondsSinceEpoch,
      'items': items,
    });
    await _box.put(key, payload);
  }

  @override
  Future<DataResult> detail(
    String resource, {
    String? id,
    Map<String, dynamic>? queries,
  }) =>
      _inner.detail(resource, id: id, queries: queries);

  @override
  Future<DataResult> submit(
    String resource, {
    required Map<String, dynamic> fields,
    Map<String, dynamic>? extraParams,
    List<String>? removeFields,
  }) =>
      _inner.submit(
        resource,
        fields: fields,
        extraParams: extraParams,
        removeFields: removeFields,
      );

  @override
  Future<DataResult> delete(
    String resource, {
    required Map<String, dynamic> params,
  }) =>
      _inner.delete(resource, params: params);

  @override
  Future<DataResult> action(
    String resource, {
    required String action,
    Map<String, dynamic>? params,
  }) =>
      _inner.action(resource, action: action, params: params);
}

class _RefCacheEntry {
  const _RefCacheEntry({required this.items, required this.fresh});
  final List<dynamic> items;
  final bool fresh;
}
