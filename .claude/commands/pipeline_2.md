# Pipeline 2 — Migrate Feature từ Supabase sang System (REST)

Bạn là **Migration Orchestrator** — điều phối việc chuyển một feature **đang dùng Supabase** sang **kiến trúc System (REST)** mới, giữ nguyên UI/UX và hành vi.

> Khác với `/pipeline` (tạo feature mới từ đầu qua Q&A của BA), pipeline này **không tạo mới** — nó **chuyển đổi code đã có**. Không hỏi spec; thay vào đó khảo sát feature hiện tại, map sang endpoint REST, biến đổi data layer, rồi verify.

## Input

Nhận từ user: `$ARGUMENTS` — tên feature folder cần migrate (vd: `market_surveillance/article`, `merchant_home/licenses`).
Nếu user không truyền tên → chạy **Phase 0** để liệt kê các feature còn Supabase rồi hỏi chọn.

## Tài liệu tham chiếu reference (mẫu migration thực tế)

| File | Trạng thái | Vai trò |
|------|-----------|---------|
| `lib/pages/complain/bloc.dart` | ✅ Đã migrate (list) | **Mẫu chuẩn before→after** — code Supabase cũ comment lại, REST mới active bên dưới |
| `lib/pages/complain/edit/bloc.dart` | ⏳ Còn Supabase (form) | Ví dụ form chưa migrate — biết shape cần chuyển |
| `packages/core_rest/lib/src/client/api_address.dart` | — | Bảng tra endpoint `ApiAddress.{service}.{path}` |
| `packages/core_rest/lib/src/client/api_service.dart` | — | Enum `ApiService` các backend domain |

---

## Migration Flow

```
┌──────────────────────────────────────────────────────────┐
│  Phase 0: INVENTORY (chỉ khi chưa biết feature)          │
│  Grep SupabaseDataSource / SupabaseListBloc / core_supabase│
│  → Bảng feature còn dùng Supabase → user chọn 1           │
└────────────────────────┬─────────────────────────────────┘
                         ▼
┌──────────────────────────────────────────────────────────┐
│  Phase 1: ANALYZE FEATURE                                 │
│  Đọc TẤT CẢ file của feature đích                         │
│  Trích: bloc base class, dsResource (table), filters,     │
│  select-joins, detailIdField, RPC, order, options         │
│  Output: Migration Sheet (before snapshot)                │
└────────────────────────┬─────────────────────────────────┘
                         ▼
┌──────────────────────────────────────────────────────────┐
│  Phase 2: MAP TO REST                                     │
│  table → ApiService + ApiAddress endpoint                 │
│  select-joins → server-side (bỏ)                          │
│  filter syntax Postgrest → query params REST              │
│  offset/limit → page/limit, detailIdField → idField       │
│  Output: Mapping Table → HIỂN THỊ cho user xác nhận       │
└────────────────────────┬─────────────────────────────────┘
                         ▼
┌──────────────────────────────────────────────────────────┐
│  Phase 3: TRANSFORM                                       │
│  Sửa bloc: thay dataSource, dọn imports core_supabase     │
│  COMMENT lại code Supabase cũ (giữ tham chiếu), thêm REST  │
│  Page/widget: chỉ sửa nếu binding field đổi               │
└────────────────────────┬─────────────────────────────────┘
                         ▼
┌──────────────────────────────────────────────────────────┐
│  Phase 4: VERIFY                                          │
│  Grep còn sót SupabaseDataSource/SupabaseManager trong    │
│  feature; dart analyze; check imports; report             │
└──────────────────────────────────────────────────────────┘
```

---

## Phase 0 — Inventory (chỉ khi $ARGUMENTS rỗng)

Grep trong `lib/pages/` các pattern:
`SupabaseDataSource`, `SupabaseListBloc`, `SupabaseDetailBloc`, `SupabaseFormBloc`, `SupabaseManager`, `import 'package:core_supabase`.

Gom theo feature folder, in bảng:

```markdown
| # | Feature | File còn Supabase | Loại (list/detail/form) |
|---|---------|-------------------|--------------------------|
```

Hỏi user chọn feature (hoặc nhiều feature) để migrate rồi sang Phase 1.

---

## Phase 1 — Analyze Feature

Đọc **toàn bộ** file trong folder feature đích (`list/`, `detail/`, `form/` hoặc `edit/`, `widgets/`, `bloc.dart`, `page.dart`).

Với mỗi bloc, trích các thông tin sau (đây là phần Supabase cần chuyển):

| Mục cần trích | Tìm ở đâu |
|---------------|-----------|
| Base class | `SystemListBloc` / `AppListBloc` / `SystemDetailBloc` / `SystemFormBloc` / `SupabaseFormBloc` |
| Table name | arg đầu (bloc cũ) hoặc `api:` / `resource:` / `dsResource:` / `tableName:` |
| DataSource | `SupabaseDataSource(SupabaseManager.client, ...)` |
| `detailIdField` | param trong `SupabaseDataSource(...)` (vd `'_id'`) |
| Filters tĩnh | `filters: { ... }` — chú ý key `select` (join), `user_id`, `:operator` |
| Order | `extraParams: {'order': {...}}` |
| Options | `options: {...}` / `suggestTitle:` |
| RPC | `tableName: 'rpc/...'` + lời gọi `SupabaseManager.client.from(...)` trong event handler |

Output **Migration Sheet** (before snapshot):

```markdown
# Migration Sheet — {feature}

## Files
- list/bloc.dart  → SupabaseDataSource, table `{x}`, filters {...}
- detail/bloc.dart → detailIdField `_id`, ...
- form/bloc.dart  → ...

## Supabase đặc thù cần xử lý
- [ ] select-join: `*,merchants(*),...`
- [ ] filter user_id, :operator
- [ ] order created_at desc
- [ ] RPC create_full_complaint (nếu có)
- [ ] truy vấn phụ trong event (merchants, violations...)
```

---

## Phase 2 — Map to REST

Quy tắc chuyển đổi (theo đúng cách `complain/bloc.dart` đã làm):

| Supabase (before) | REST (after) |
|-------------------|--------------|
| `SupabaseDataSource(SupabaseManager.client)` | `ApiService.{service}.apiPath(ApiAddress.{service}.{endpoint})` |
| arg đầu = table name `'complaints'` | arg đầu = `''` (service name không dùng với REST) |
| `detailIdField: '_id'` | `idField: '_id'` (chỉ giữ nếu REST thật sự dùng id phi chuẩn) — truyền qua `RestDataSource(...)` thủ công |
| `filters: {'select': '*,joins(*)'}` | **bỏ** — server tự join |
| `filters: {'col:operator': v}` | query param `?col:operator=v` (đa số REST hỗ trợ suffix `:op`), hoặc `?search=` |
| `extraParams: {'order': {...}}` | `?sort=field:desc` (do `SystemListBloc` tự build từ sorts) |
| `offset/limit` (0-based) | `page/limit` (1-based) — adapter tự convert |
| `tableName: 'rpc/fn'` | `ApiAddress.{service}.{fnEndpoint}` (POST full path) |
| truy vấn phụ trong event (dropdown data) | gọi endpoint REST tương ứng qua `ApiService.{service}` |

**Tra endpoint**: mở `packages/core_rest/lib/src/client/api_address.dart`, tìm `_{Service}Paths` khớp với table/resource. Nếu **không tìm thấy endpoint** → DỪNG, báo user: cần endpoint nào, service nào, kèm link Swagger từ bảng API Services (xem CLAUDE.md). KHÔNG bịa path.

In **Mapping Table** (before → after cho từng bloc) và **HIỂN THỊ cho user xác nhận** trước khi sửa code. Nêu rõ phần không map được (join phức tạp, RPC) để user quyết.

---

## Phase 3 — Transform

Với mỗi bloc, áp dụng đúng style của `complain/bloc.dart`:

1. **Giữ code Supabase cũ dưới dạng comment** ngay trong constructor (để dev đối chiếu), thêm dòng REST mới active bên dưới.
2. Thay `dataSource:` sang `ApiService.{service}.apiPath(ApiAddress.{service}.{endpoint})`.
3. Đổi arg table name đầu thành `''`.
4. Nếu cần id phi chuẩn: dùng `RestDataSource(ApiService.{service}.dio, idField: '_id', apiPath: ApiAddress.{service}.{endpoint})`.
5. **Dọn imports**: bỏ `import 'package:core_supabase/...'` và `supa_base/utils/supabase_manager.dart` nếu file không còn dùng. Đảm bảo `import '../../import.dart'`.
6. Form còn `extends SupabaseFormBloc` → chuyển sang `SystemFormBloc` với `dsResource` + `dataSource` REST; truy vấn phụ trong event chuyển sang gọi REST.
7. **Page/widget**: chỉ sửa khi tên field trong response REST khác Supabase (vd snake_case → camelCase). Nếu giống → không đụng UI.

Conventions bắt buộc (giống code-agent): không hardcode màu/text/chuỗi, `AppDialogs`, `appNavigator`, `debugPrint()`.

---

## Phase 4 — Verify

1. Grep trong folder feature: `SupabaseDataSource`, `SupabaseManager`, `core_supabase`, `SupabaseFormBloc` → phải = 0 (trừ phần comment cố ý giữ lại).
2. Grep import `package:core_supabase` còn sót → cảnh báo.
3. `dart analyze {feature path}` (hoặc cả app) — không lỗi mới.
4. Kiểm tra navigation flow vẫn nguyên: list → detail → form → pop.

Output final report:

```
✅ Migrated: {feature}
✅ Blocs chuyển REST: {list}
✅ DataSource: SupabaseDataSource → ApiService.{service}.apiPath(...)
✅ Imports core_supabase đã dọn: {n} file
⚠️  Endpoint chưa có trong ApiAddress: {liệt kê nếu có}
⚠️  Field response cần kiểm tra (snake_case→camelCase): {liệt kê}
⚠️  RPC/truy vấn phụ cần endpoint REST: {liệt kê}

TODO:
    dart analyze && dart format -l 100 .
    Test thủ công: list load, detail mở, form submit
```

---

## Quy tắc Migration

1. **KHÔNG đổi UI/UX** — chỉ thay data layer, trừ khi field name response khác.
2. **KHÔNG bịa endpoint** — chỉ dùng path có trong `ApiAddress`; thiếu thì DỪNG và hỏi user (kèm Swagger).
3. **GIỮ code Supabase cũ dạng comment** trong bloc — đúng như `complain/bloc.dart`.
4. **KHÔNG code trước khi user xác nhận Mapping Table (Phase 2)**.
5. **KHÔNG dùng Clean Architecture** — giữ SystemBloc pattern.
6. **LUÔN tham chiếu `complain/bloc.dart`** làm mẫu before→after.
7. **LUÔN verify** không còn sót Supabase reference sau khi xong.
8. **Output bằng tiếng Việt**.

## Ví dụ sử dụng

```
User: /pipeline_2 market_surveillance/article

→ Phase 1: Đọc article/{list,detail,form}/bloc.dart
   list: SupabaseDataSource, table 'articles', options {suggestTitle:'title'}
   detail: detailIdField '_id'
   form: dsResource 'articles', detailIdField '_id'
→ Phase 2: Mapping Table
   'articles' → ApiService.catalog.apiPath(ApiAddress.catalog.articles)
   detailIdField '_id' → idField '_id' (giữ)
   [HIỂN THỊ → user xác nhận]
→ Phase 3: Sửa 3 bloc, comment code Supabase cũ, dọn imports
→ Phase 4: Verify 0 Supabase ref, dart analyze OK

✅ Migrated: market_surveillance/article (3 blocs)
⚠️  Kiểm tra field response: created_at → createdAt
```
