// Khai báo các DataSource có cache cho dữ liệu tham chiếu ít thay đổi.
//
// Thêm nội dung cache mới: tạo thêm 1 factory dùng [cachedDataSource], truyền
// service và các path prefix cần cache. Ví dụ:
//   DataSource fooDataSource() =>
//       cachedDataSource(ApiService.foo, const {'api/foo'});
import 'package:core_data/core_data.dart';
import 'package:core_rest/core_rest.dart';
import 'package:core_auth/core_auth.dart';

import 'reference_cache_data_source.dart';

/// Tạo nhanh 1 [DataSource] có cache cho [service], cache các path khớp
/// [cachePrefixes].
DataSource cachedDataSource(ApiService service, Set<String> cachePrefixes) =>
    CachedRefDataSource(service.apiPath(), cachePrefixes: cachePrefixes);

/// Tỉnh/thành phố & phường/xã (geo service).
DataSource geoDataSource() =>
    cachedDataSource(ApiService.geo, const {'api/geo/provinces'});

/// Phân loại ngành hàng (merchant service).
DataSource categoryDataSource() =>
    cachedDataSource(ApiService.merchant, const {'api/categories'});

/// Loại hình kinh doanh (merchant service).
DataSource businessTypeDataSource() =>
    cachedDataSource(ApiService.merchant, const {'api/merchants/business-types'});

/// Đơn vị (org service).
DataSource departmentDataSource() =>
    cachedDataSource(ApiService.org, const {'api/departments'});
