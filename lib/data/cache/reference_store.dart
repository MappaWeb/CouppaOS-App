// Store typed cho dữ liệu tham chiếu — "nạp 1 lần, dùng thì gọi".
//
// Memo `Future` trong RAM: lần đầu gọi sẽ nạp (đọc Hive qua CachedRefDataSource,
// miss thì gọi API), các lần sau (kể cả nhiều nơi gọi đồng thời) nhận lại CÙNG
// một Future đã nạp -> không đọc Hive lại, không gọi API trùng. Nền dưới vẫn là
// Hive nên dữ liệu sống qua restart; memo RAM sống trong 1 phiên app.
import 'package:core_data/core_data.dart';

import 'cached_data_sources.dart';
import 'reference_cache_data_source.dart';

class ReferenceStore {
  ReferenceStore._();
  static final ReferenceStore instance = ReferenceStore._();

  final _memo = <String, Future<List<Map<String, dynamic>>>>{};

  /// Tỉnh/thành phố.
  Future<List<Map<String, dynamic>>> provinces() =>
      _get('api/geo/provinces', geoDataSource());

  /// Phường/xã của một tỉnh (memo riêng theo từng tỉnh).
  Future<List<Map<String, dynamic>>> wards(String provinceId) =>
      _get('api/geo/provinces/$provinceId/wards', geoDataSource());

  /// Phân loại ngành hàng.
  Future<List<Map<String, dynamic>>> categories() =>
      _get('api/categories', categoryDataSource());

  /// Loại hình kinh doanh.
  Future<List<Map<String, dynamic>>> businessTypes() =>
      _get('api/merchants/business-types', businessTypeDataSource());

  /// Đơn vị.
  Future<List<Map<String, dynamic>>> departments() =>
      _get('api/departments', departmentDataSource());

  Future<List<Map<String, dynamic>>> _get(String resource, DataSource ds) {
    return _memo[resource] ??= _load(resource, ds);
  }

  Future<List<Map<String, dynamic>>> _load(String resource, DataSource ds) async {
    final res = await ds.list(resource);
    final items = res.items;
    if (!res.isSuccess || items == null) {
      _memo.remove(resource); // load lỗi -> cho phép thử lại lần sau
      return const [];
    }
    return items.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }

  /// Bỏ memo RAM (toàn bộ hoặc theo [resource]) để lần sau nạp lại.
  /// Không xóa Hive — dùng [clear] nếu muốn xóa cả đĩa.
  void invalidate([String? resource]) {
    if (resource == null) {
      _memo.clear();
    } else {
      _memo.remove(resource);
    }
  }

  /// Reset hoàn toàn: xóa memo RAM + cache Hive.
  Future<void> clear() async {
    _memo.clear();
    await clearReferenceCache();
  }
}
