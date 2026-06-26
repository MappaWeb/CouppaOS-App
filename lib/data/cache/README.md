# Cache dùng chung

Cache dữ liệu **tham chiếu ít thay đổi** (tỉnh/thành phố, phường/xã, phân loại
ngành hàng, …) vào Hive để tránh gọi lại API mỗi lần mở form / field select / map.

## Cấu trúc

| File | Vai trò |
|------|---------|
| `reference_cache_data_source.dart` | Lõi cache tổng quát — `CachedRefDataSource`, hằng cấu hình, `clearReferenceCache()`. Không chứa nghiệp vụ. |
| `cached_data_sources.dart` | Khai báo các nguồn cache cụ thể (`geoDataSource`, `categoryDataSource`) + helper `cachedDataSource()`. **Thêm nội dung cache mới ở đây.** |
| `reference_store.dart` | Store typed "nạp 1 lần, dùng thì gọi" — `ReferenceStore.instance.provinces()/wards(id)/categories()/businessTypes()/departments()` trả `List<Map<String, dynamic>>`. |
| `cache.dart` | Barrel export, được re-export qua `lib/import.dart`. |

## Cách hoạt động

`CachedRefDataSource` là một decorator bọc một `DataSource` bất kỳ:

- Chỉ cache `list()` của các endpoint khớp `cachePrefixes`; thao tác khác
  (`detail`/`submit`/`delete`/`action`) và list không khớp được uỷ quyền nguyên trạng.
- **Cache theo resource path** → mỗi path một entry (vd mỗi tỉnh một danh sách phường).
- Khi cache miss, **luôn kéo trọn danh sách** (`limit: referenceCacheFullLimit = 1000`,
  bỏ qua phân trang của caller) để mọi nơi dùng chung một payload đầy đủ.
- **TTL** mặc định 30 ngày (`referenceCacheTtl`).
- Request có `search` server-side → **không** cache (mỗi keyword trả tập khác nhau).
- API lỗi → fallback về cache cũ (kể cả đã hết hạn) nếu có, để UI vẫn hiển thị.
- Lưu vào Hive box `reference_cache` (đã khai báo trong `app_config.dart`).

## Dùng nguồn cache có sẵn

`geoDataSource()` / `categoryDataSource()` đã export qua `import.dart`, dùng như một
`DataSource` bình thường.

### Trong field select (FieldSelect.picker)

```dart
FieldSelect.picker(
  dataSource: geoDataSource(),
  service: 'api/geo/provinces',
  valueKey: '_id',
  labelKey: 'name',
  // ...
)
```

> Lưu ý: **không** đặt `pageSize` cho geo/category picker — danh sách tham chiếu
> tải trọn 1 lần và lọc client-side, đặt `pageSize` sẽ tắt cache.

### Lấy danh sách trực tiếp (bloc / xử lý dữ liệu)

```dart
final res = await geoDataSource().list('api/geo/provinces');
final items = res.items; // List<dynamic>? gồm các Map
```

## `ReferenceStore` — nạp 1 lần, dùng thì gọi

Khi cần dùng trong bloc / xử lý dữ liệu (không phải field select), ưu tiên
`ReferenceStore` thay vì gọi thẳng `geoDataSource().list(...)`:

```dart
final provinces = await ReferenceStore.instance.provinces();   // List<Map<String, dynamic>>
final wards     = await ReferenceStore.instance.wards(provinceId);
final categories = await ReferenceStore.instance.categories();
final businessTypes = await ReferenceStore.instance.businessTypes();
final departments = await ReferenceStore.instance.departments();
```

- **Memo `Future` trong RAM**: lần đầu gọi sẽ nạp (Hive → miss thì API); các lần sau
  — kể cả nhiều nơi gọi đồng thời — nhận lại **cùng một** `Future` đã nạp, không đọc
  Hive lại, không gọi API trùng.
- Trả thẳng `List<Map<String, dynamic>>` (đã lọc non-Map) → không cần check
  `res.items == null` hay `is Map` ở chỗ dùng.
- Nền dưới vẫn là `CachedRefDataSource` + Hive nên dữ liệu sống qua restart; memo RAM
  sống trong 1 phiên app.
- Load lỗi → trả `[]` và **bỏ memo** để lần sau thử lại.

```dart
ReferenceStore.instance.invalidate();                 // bỏ toàn bộ memo RAM
ReferenceStore.instance.invalidate('api/geo/provinces'); // bỏ 1 resource
await ReferenceStore.instance.clear();                // bỏ memo RAM + cache Hive
```

> `geoDataSource()` / `categoryDataSource()` (DataSource) vẫn dùng cho field select
> picker; `ReferenceStore` chỉ là lớp typed tiện dụng đặt trên cùng cache đó.

## Thêm nội dung cache mới

Thêm 1 factory vào `cached_data_sources.dart`:

```dart
/// Ví dụ: danh mục foo (service foo).
DataSource fooDataSource() =>
    cachedDataSource(ApiService.foo, const {'api/foo'});
```

Rồi dùng ở bất kỳ đâu:

```dart
final res = await fooDataSource().list('api/foo');
```

`cachePrefixes` so khớp theo `startsWith`, nên `{'api/geo/provinces'}` cũng cache
luôn `api/geo/provinces/{id}/wards`.

Cần tinh chỉnh TTL / số bản ghi tối đa? Tạo trực tiếp `CachedRefDataSource`:

```dart
DataSource fooDataSource() => CachedRefDataSource(
      ApiService.foo.apiPath(),
      cachePrefixes: const {'api/foo'},
      ttl: const Duration(days: 7),
      fullLimit: 5000,
    );
```

## Xóa cache

```dart
await clearReferenceCache(); // xóa toàn bộ box reference_cache, buộc tải lại
```

## Lưu ý

- Box `reference_cache` phải nằm trong `boxes` của `init(...)` (`app_config.dart`).
- Dữ liệu cache là JSON-serializable (raw từ REST) — không cache object phức tạp.
