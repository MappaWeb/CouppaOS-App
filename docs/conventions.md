# couppa_mini — Quy ước Phát triển

> Tài liệu này tổng hợp các quy ước viết code, chọn widget, layout và thiết kế UI
> cho `couppa_mini`. Mục tiêu: mọi thành viên (cũ + mới) có cùng một mental model,
> tránh việc mỗi page tự pick widget/spacing/style khác nhau.
>
> Dùng tài liệu này như **checklist khi mở PR**. Phần nào không tuân theo cần
> ghi rõ lý do trong PR description.

---

## Mục lục

1. [State management — ưu tiên System*Bloc của AppCore](#1-state-management)
2. [Gọi API trực tiếp trong Bloc (ad-hoc, ngoài System*Bloc)](#2-gọi-api-trực-tiếp-trong-bloc)
3. [App tự config API/AuthSetup — AppCore chỉ là fallback sample](#3-app-tự-config-apiauthsetup)
4. [Cấu trúc thư mục Feature](#4-cấu-trúc-thư-mục-feature)
5. [Routing — auto-gen từ `tool/gen_router.dart`](#5-routing--auto-gen)
6. [Navigation pattern](#6-navigation-pattern)
7. [Imports — luôn qua `import.dart`](#7-imports)
8. [Form Fields — ưu tiên `Field*` widgets](#8-form-fields)
9. [Scaffolds — `System*Scaffold` + unfocus form](#9-scaffolds--unfocus)
10. [AppBar — ưu tiên `BaseAppBar`](#10-appbar)
11. [List item conventions — `ItemBase`, spacing, radius](#11-list-item-conventions)
12. [Design language — Modern · Minimal · Premium](#12-design-language)
13. [Widget tái sử dụng — khi nào tách ra `lib/widget/`](#13-widget-tái-sử-dụng)
14. [Checklist PR](#14-checklist-pr)

---

## 1. State management

### Quy tắc

| Loại state | Dùng cái nào |
|------------|--------------|
| **List** (pagination/search/filter) | `AppListBloc<T>` (khi `T extends JsonModel<T>`) hoặc `SystemListBloc<S, T>` base (T = `Map` cũng được) |
| **Detail** (1 item + refresh) | Kế thừa trực tiếp `SystemDetailBloc<SystemDetailState>` — **KHÔNG có `AppDetailBloc`** |
| **Form** (create/edit + validation) | `AppFormBloc<T>` (khi `T extends JsonModel<T>`) hoặc `SystemFormBloc<S>` base |
| **State UI-local đơn giản** (toggle, tab index, không server) | `Cubit` + `state.copyWith` (fallback) |

### Vì sao

System*Bloc của AppCore cung cấp sẵn: pagination, search, filter, fetch-on-init,
refresh, submit, validation, cache. Tự viết bằng `Cubit` + `copyWith` cho list/
detail/form là **lãng phí + dễ lệch hành vi** giữa các page. Trang cũ còn dùng
Cubit — migrate dần khi đụng tới, không rewrite hàng loạt.

### API surface chính (đã verify trên AppCore)

Nguồn: `packages/shared_core/shared_state/lib/src/blocs/`.

- **`AppListBloc<T extends JsonModel<T>>`** — ctor `{required T empty, String resource, DataSource? dataSource, ListQuery? query}`.
- **`AppFormBloc<T extends JsonModel<T>>`** — ctor `{required String resource, DataSource? dataSource, Map? params, Map<String, Rules>? rules, Map? initialFields}`. `params['id']` → edit mode (tự fetch).
- **`SystemListBloc<S, T>`** — base list bloc. T = `Map` chạy được luôn; T khác phải override `parseItem`/`getItemId`/`getItemTitle`.
- **`SystemDetailBloc<S>`** — kế thừa trực tiếp. Đọc data qua `state.result` (Map). Override `handleResult` để biến đổi data.
- **`SystemFormBloc<S>`** — khi dùng `dataSource` mà không có `submitService` → **bắt buộc `@override onSubmit`**.

### Ví dụ — list page

```dart
// bloc.dart
class MyVoucherListBloc extends AppListBloc<MyVoucherModel> {
  MyVoucherListBloc({Map<String, dynamic>? initialFilters})
      : super(
          empty: const MyVoucherModel.empty(),
          dataSource: ApiService.coupon.apiPath(AppApi.voucher.vouchersMine),
          query: ListQuery.fromMap(initialFilters ?? const {}),
        );
}

// page.dart
BlocBuilder<MyVoucherListBloc, SystemListState<MyVoucherModel>>(
  builder: (context, state) {
    if (state.showLoading) return ...;
    if (state.isFail)      return ...;
    final items = state.items.map((e) => e.value).toList();
    // ...
  },
)
```

Refresh: `context.read<...>().add(RefreshBaseList(clearItems: false, completer: completer))`.

---

## 2. Gọi API trực tiếp trong Bloc

### Quy tắc

Khi feature phải gọi API **không hợp với** `AppListBloc<T>` / `AppFormBloc<T>` /
`SystemDetailBloc` (action endpoint, một GET/PATCH lẻ ngoài luồng list/form CRUD)
→ **gọi API thẳng trong Bloc/Cubit**, **KHÔNG** tạo lớp `DataSource` trung gian
cho 1–2 call đơn lẻ.

Tham khảo mẫu chuẩn: `lib/pages/account/profile/bloc.dart` và
`lib/pages/user/voucher_claim/bloc.dart`.

### Cách làm

- Inject `ApiClient` qua constructor: `required ApiClient apiClient`.
- Trong handler:
  `await _apiClient.dio(ApiService.X).get/post/patch(path, data: ...)`.
- Bắt `DioException` tại chỗ → map sang state error
  (`SystemFormStateStatus.fail` / cờ trong state Cubit).
  `DioException` đã re-export transitively qua `import.dart` → `core_rest` —
  **KHÔNG** thêm `import 'package:dio/dio.dart'`.
- Endpoint nằm trên **domain khác** với subdomain của `ApiService.X`
  → khai báo **absolute URL** trong `lib/api/app_api.dart`
  (vd: `AppApi.voucher.campaignByCode`). Dio bypass `baseUrl` khi gặp scheme
  `https://`, nhưng vẫn áp dụng full interceptors (auth/logger/error).
- Cập nhật session sau call (vd: PATCH `/auth/me`):
  `AuthSetup.instance.authSessionBloc.add(SessionUserUpdated(...))`.

### Ví dụ — Cubit gọi API trực tiếp

```dart
class VoucherClaimCubit extends Cubit<VoucherClaimState> {
  VoucherClaimCubit({required ApiClient apiClient})
    : _apiClient = apiClient,
      super(const VoucherClaimState());

  final ApiClient _apiClient;

  Future<({bool success, String? message})> _claim(String code) async {
    try {
      final res = await _apiClient
          .dio(ApiService.coupon)
          .get(AppApi.voucher.campaignByCode(code));
      final ok = (res.statusCode ?? 0) >= 200 && (res.statusCode ?? 0) < 300;
      return (success: ok, message: null);
    } on DioException catch (e) {
      return (success: false, message: e.message);
    }
  }
}
```

### Khi nào mới tách `DataSource`?

Chỉ tách khi feature có **nhiều endpoint** đáng group lại, hoặc cần **tái dùng**
giữa nhiều Bloc. Một call lẻ → gộp luôn trong bloc cho gọn.

---

## 3. App tự config API/AuthSetup

### Quy tắc

`ApiService` enum + `api.suyxet.com` defaults trong AppCore là **convention /
fallback sample** cho các dự án downstream tham khảo — **KHÔNG phải runtime spec**.

Mỗi app tự build setup riêng trong `bootstrap()` (`lib/app_config.dart`):

```dart
final apiClient = ApiClient(ApiService.urlsFrom(config.apiDomain));
final authSetup = AuthSetup.create(
  apiClient: apiClient,
  authBaseUrl: 'https://${ApiService.auth.subdomain}.${config.apiDomain}',
  config: const AuthConfig(
    mePath: '/auth/me',
    refreshPath: '/auth/refresh',
    logoutPath: '/auth/logout',
    logoutSendsRefreshTokenInBody: true,
  ),
  bootstrapMinDuration: const Duration(milliseconds: 300),
  onRequireLogin: (_) => appNavigator.pushNamed(RouterConstants.login),
);
```

- `config.apiDomain` lấy từ `AppFlavorConfig` (dev hardcode, prod yêu cầu
  `--dart-define=API_DOMAIN=...`).
- `ApiService.coupon` / `ApiService.merchant` / ... chỉ là **subdomain prefix** —
  bind vào bất kỳ domain nào app set.
- Endpoint **không thuộc** domain chính: định nghĩa **absolute URL** trong
  `lib/api/app_api.dart` (vd: `AppApi.voucher.*` cho domain
  `voucher.api-qr.iotcommunication.net`).

### Khi làm feature mới — bắt buộc

1. **Đọc trước** `lib/app_config.dart` + `lib/api/app_api.dart` của project
   để biết domain/path thật.
2. **KHÔNG** suy diễn từ `ApiService` enum của AppCore hay giả định
   `suyxet.com` — đó chỉ là sample.
3. Endpoint chưa có trong `AppApi`: thêm vào `AppApi.X`
   - Cùng domain với `ApiService.X` đã config → relative path.
   - Khác domain → absolute URL (Dio tự bypass baseUrl).
4. Trong code chỉ tham chiếu `ApiService.X` (subdomain) và `AppApi.X.path` —
   **KHÔNG hardcode full URL** trong feature.

### Vì sao

Sample/fallback API của AppCore (`suyxet.com`) không phải runtime spec — mỗi app
có domain/endpoint riêng. Lẫn 2 thứ này dẫn đến hardcode sai domain.

---

## 4. Cấu trúc thư mục Feature

```
lib/pages/<group>/<feature>/
├── bloc.dart              # Bloc/Cubit chính của feature
├── model.dart             # Model implements JsonModel<T> (nếu dùng AppListBloc/AppFormBloc)
├── page.dart              # <Group><Feature>Page — list/index
├── widgets/
│   └── item.dart          # Widget riêng cho 1 item / 1 phần — không reuse ngoài
├── detail/
│   ├── bloc.dart          # extends SystemDetailBloc
│   └── page.dart          # <Group><Feature>DetailPage(this.args)
└── form/                  # Dùng folder `form/`, KHÔNG dùng `edit/`
    ├── bloc.dart          # extends AppFormBloc<T> hoặc SystemFormBloc<S>
    └── page.dart          # <Group><Feature>FormPage(this.args) — create + edit
```

**Ràng buộc bắt buộc:**

- File page **luôn tên `page.dart`**.
- Folder `widgets/` **bị router skip** — đặt widget private/internal ở đây.
- Page nhận tham số: `const FooPage(this.args, {super.key})` với `final Map? args`.
  Getter `String get id => args?['id']?.toString() ?? '';`.
- Page không tham số: `const FooPage({super.key})`.
- Có redirect: `static String? redirect(BuildContext context, GoRouterState state)`.

**Tham chiếu (mẫu thực tế trong repo):**

- `lib/pages/merchant/coupon/` — list + detail + form + issue
- `lib/pages/merchant/redeem/` — list + confirm
- `lib/pages/user/coupon/` — list + detail

---

## 5. Routing — auto-gen

**KHÔNG sửa tay** `lib/routes.dart` và `lib/router_constants.dart`.

Sau khi thêm/đổi/xoá `page.dart`:

```bash
dart run tool/gen_router.dart
```

### Mapping

```
lib/pages/merchant/coupon/form/page.dart
  → Class:  MerchantCouponFormPage
  → Path:   /Merchant/Coupon/Form
  → Const:  RouterConstants.merchantCouponForm
```

### Đặc biệt

- Bỏ qua page khỏi router: thêm comment `// @ignoreRouter` trong file.
- Đổi segment name (vd: `merchant` → `Shop`): sửa `lib/router_factory.json`.
- Route phá convention: thêm vào `lib/routes_manual.json`.

---

## 6. Navigation pattern

```dart
// Push - List → Detail (truyền id)
appNavigator.pushNamed(
  RouterConstants.merchantCouponDetail,
  arguments: {'id': coupon.id},
);

// Push - List → Form (create)
appNavigator.pushNamed(RouterConstants.merchantCouponForm);

// Push - Detail → Form (edit)
appNavigator.pushNamed(
  RouterConstants.merchantCouponForm,
  arguments: {'id': id},
);

// Pop sau khi submit thành công
appNavigator.pop();
```

**Luôn dùng** `RouterConstants.xxx` thay vì string literal `'/Merchant/Coupon/Form'`.

---

## 7. Imports

**Mọi file trong `lib/pages/` chỉ import qua barrel `lib/import.dart`:**

```dart
// từ lib/pages/<a>/<b>/file.dart:
import '../../../import.dart';

// từ lib/pages/<a>/<b>/<c>/file.dart:
import '../../../../import.dart';
```

`import.dart` đã re-export:

- `flutter/material.dart`
- `core/core.dart` — `BlocProvider`/`BlocBuilder`/`BlocConsumer`/`Cubit`/`Bloc`,
  `appNavigator`, `GoRouter`, `ApiClient`, `ApiService`, `Field*`, `ItemBase`,
  `BaseAppBar`, các System*Bloc/Scaffold/State...
- `core_rest`, `core_auth`, `core_monitoring`
- `lib/gen/assets.gen.dart`, `AppLocalizations`, `Palette`, `RouterConstants`,
  `lib/data/cache/...`, `auth_state`

→ **Không bao giờ import lẻ** `package:flutter_bloc/...`, `package:core_state/...`,
`package:core_widgets/...` cho thứ đã có trong barrel.

> ⚠️ `dart:async` (vd. `Completer`) **không** trong barrel — import riêng khi cần.

---

## 8. Form Fields

### Quy tắc

Khi build **bất kỳ input nào** (form, dialog, login, search bar...) — luôn
ưu tiên `Field*` widgets từ `package:core_widgets/fields.dart` (đã re-export
qua `import.dart`).

### Bảng đối chiếu Material → Field*

| Material thuần | Field* tương đương |
|----------------|-------------------|
| `TextFormField` (text) | `FieldText` |
| `TextFormField(obscureText: true)` + toggle | `FieldPassword` (đã có sẵn show/hide) |
| `TextFormField(keyboardType: number)` | `FieldText(keyboardType: ...number)` hoặc `FieldNumber` |
| `DropdownButtonFormField` | `FieldDropdown` / `FieldSelect` |
| `Checkbox` + label | `FieldCheckbox` |
| `Switch` + label | `FieldSwitch` |
| Date picker thủ công | `FieldDate` / `FieldDateTime` |
| `Image.pick` + preview | `FieldUpload` / `FieldImage` |

### Vì sao

`Field*` mang sẵn: validation, label, error display, theme đồng nhất, accessibility,
upload service (qua `FieldScope` đã set ở `app_config.dart`). Material thuần làm
UI lệch chuẩn + phải tự gắn lại từng concern → KHÔNG generate `TextFormField`
mặc định khi viết feature mới.

### Khi nào được fallback Material?

- Đã chắc chắn `core_widgets/fields.dart` không có `Field*` tương đương.
- Comment rõ lý do trong code/PR.

---

## 9. Scaffolds + unfocus

### Quy tắc

| Loại page | Scaffold |
|-----------|----------|
| List | `SystemListScaffold` |
| Detail | `SystemDetailScaffold` |
| Form | `SystemFormScaffold` |
| Khác | `Scaffold` thường + (nếu là form) wrap `GestureDetector` để unfocus |

### Unfocus — bắt buộc cho mọi form

Tap ra ngoài field → ẩn bàn phím. **`SystemFormScaffold` đã bọc sẵn** — chỉ
phải lo unfocus thủ công khi tự build form bằng `Scaffold` thường:

```dart
GestureDetector(
  behavior: HitTestBehavior.opaque,
  onTap: () => FocusScope.of(context).unfocus(),
  child: ...
)
```

### Lưu ý SystemFormScaffold

- `appBarBuilder`, `builder: (context, state, wrapper)`, `bottomNavigationBar`,
  `bottomSheet` (nhận sẵn `submitBtn`).
- `wrapper<T>('key', builder: ...)` cho từng field — rebuild qua `BlocSelector` riêng.
- `builder` top-level chỉ rebuild khi `status`/`stepIndex` đổi. Widget custom đọc
  `state.fields` (vd field map/location) phải tự bọc `BlocBuilder`/`BlocSelector`
  với `buildWhen` đúng field.
- Navigation sau submit: bọc body bằng `BlocListener` lắng `state.isSuccess`/`isFail`
  — đừng override `listener` của scaffold (nó lo `showLoading`/`disableLoading`).

---

## 10. AppBar

### Quy tắc

**Ưu tiên `BaseAppBar`** thay vì `AppBar` thuần của Material.

```dart
appBar: BaseAppBar(
  context: context,                       // ← BẮT BUỘC
  title: const Text('Coupon của tôi'),
  bottom: const TabBar(...),
),
```

### Vì sao

`BaseAppBar extends AppBar` — tương thích y hệt `AppBar` ở mọi chỗ nhận
`PreferredSizeWidget`. Khác biệt duy nhất: phải truyền `context: context` vào
ctor (vì BaseAppBar đọc `Theme.of(context).extension<AppBarThemeExtension>()`).

Tự áp default từ theme extension:
- `baseTitle`, `baseLeading`, `baseActions`, `flexibleSpace`
- `persistentActions` / `persistentActionBuilder` — inject action chung
  (notification, profile...) vào MỌI AppBar
- `_buildLeading` tự sinh nút back qua `Navigator.maybePop` khi `canPop`

Dùng `AppBar` thuần → mất hết default này → UI lệch nhịp giữa các màn.

### Ngoại lệ

Khi page nằm ngoài app theme (splash, full-screen video, custom shell không
có `AppBarThemeExtension`) — ghi rõ lý do trong comment.

> Các `System*Scaffold` thường đã tự dùng `BaseAppBar` bên trong — chỉ cần lo
> `BaseAppBar` khi viết Scaffold trần.

---

## 11. List item conventions

### Quy tắc

- **Item widget**: ưu tiên `ItemBase` (AppCore — `shared_widgets/layouts/detail/item_base.dart`).
  Chỉ tự build từ `InkWell`/`Row`/`Container` khi layout vượt khả năng `ItemBase`
  (custom hit area, nhiều slot, animation riêng).
- **Khoảng cách giữa item / giữa widget kề nhau**: ~**12**.
  `SizedBox(height: 12)`, `EdgeInsets.all(12)`, `gap: 12`.
- **Border radius**: trong khoảng **12 → 20**, **chia hết cho 4** (chọn `12 / 16 / 20`).
  - Default `12` cho list item.
  - `16` cho card lớn.
  - `20` cho bottom sheet / dialog hero.
- **Padding ngang đến 2 viền** màn hình / container cha: luôn **16**.
  `EdgeInsets.symmetric(horizontal: 16)` hoặc `EdgeInsets.all(16)` cho `ListView.padding`.

### Vì sao

Thống nhất visual rhythm giữa các màn list trong app, tránh việc mỗi page tự
pick spacing/radius khác nhau → UI lệch nhịp 4pt grid.

### Cách dùng `ItemBase` với viền (nền trắng)

`ItemBase` có sẵn param `side: BorderSide?` (ref AppCore mới):

```dart
ItemBase(
  onPressed: onTap,
  backgroundColor: Palette.cardColor,
  borderRadius: BorderRadius.circular(12),
  side: const BorderSide(color: Palette.borderColor),
  leading: ...,
  titleText: ...,
  content: ...,
)
```

→ KHÔNG wrap `DecoratedBox` / `Container(border: ...)` ngoài.

### Setup list page chuẩn

```dart
ListView.separated(
  padding: const EdgeInsets.all(16),
  separatorBuilder: (_, _) => const SizedBox(height: 12),
  itemCount: items.length,
  itemBuilder: (context, i) => MyItem(items[i], onTap: ...),
)
```

---

## 12. Design language

> Nguyên tắc UI/UX cho toàn app — đặc biệt nghiêm ngặt với các màn Auth
> (login, register, forgot_password, otp, reset_password, welcome).

### Principles bắt buộc

Modern · Minimal · Premium · Clean · Soft · Elegant · Professional ·
User-friendly · Accessible · Consistent.

**Tránh**: flashy, nhiều màu, gaming-style, trang trí thừa.

Reference: Linear / Notion / Stripe / Airbnb / Revolut / Apple / Google Material 3.

### Color

- Chỉ **một** màu primary brand. Còn lại là **neutral**.
- Background: very light gray hoặc white.
- Dùng màu **chỉ** cho: Primary button · Focus state · Success · Error.
- Source of truth: `lib/utils/palette.dart` (`Palette.primary`, `Palette.cardColor`,
  `Palette.borderColor`, `Palette.textPrimary*`, `Palette.successBgColor`...).
- **KHÔNG hardcode `Color(0x...)`** trong widget.

### Typography

- Hierarchy rõ: title lớn đậm → subtitle vừa → body dễ đọc.
- Ít font weight. Tránh chữ thừa.

### Spacing

- Hệ **8-point**. Vertical spacing thoáng. Padding nhất quán.
- Không màn nào được cảm giác chật.

### Border radius

- Buttons: **16–20**
- Inputs: **16**
- Cards: **20**
- List items: **12** (xem mục 11)

### Buttons

- **1 primary CTA** lớn / màn. Secondary là text button.
- **Bắt buộc** có loading & disabled state.

### Inputs

- Filled hoặc outlined modern (floating label).
- States: Focus · Error · Success · Disabled.
- Password field có icon show/hide (→ `FieldPassword`).

### Icons

- **Một** icon family duy nhất, outline đơn giản, không trang trí.

### Animations

- Subtle: fade / slide / scale. Transition nhanh.
- **Không** motion thừa.

### Accessibility

- Min touch size, typography dễ đọc, contrast cao.
- Hỗ trợ dark mode và screen reader.

### Auth layout chuẩn (mọi màn auth giống cấu trúc)

```
Top safe area
  → Back button (nếu cần)
  → Logo / App mark
  → Large title
  → Short supporting text
  → Main form
  → Primary CTA
  → Optional divider
  → Social login
  → Bottom helper text
  → Footer action
```

**Tất cả màn auth phải cùng cấu trúc này** — chỉ đổi nội dung, không đổi
layout, spacing, typography, buttons, colors, components, interactions.

### Component reuse cho Auth

Primary Button · Secondary Button · Text Field · Password Field · OTP Input ·
Avatar · Divider · Social Button · Checkbox · Snackbar · Loading Indicator.

### Philosophy

Giảm friction & cognitive load. Hướng sự chú ý của user. Giữ tương tác đơn giản.
Mỗi màn yêu cầu suy nghĩ tối thiểu. **Clarity over decoration.** Không redesign
component giữa các màn. Giữ ngôn ngữ thiết kế thống nhất xuyên suốt flow.

---

## 13. Widget tái sử dụng

| Phạm vi dùng | Đặt ở đâu |
|--------------|-----------|
| Chỉ 1 page | Private `_FooView` trong cùng `page.dart` |
| 1 feature (vd. nhiều file trong `pages/user/coupon/`) | `pages/<group>/<feature>/widgets/foo.dart` |
| ≥ 2 feature | `lib/widget/common/foo.dart` hoặc `lib/widget/<nhóm>/foo.dart` |

File đặt tên **snake_case** theo tên class chính (vd: `gradient_button.dart` cho `GradientButton`).

---

## 14. Checklist PR

Trước khi mở PR, đối chiếu nhanh:

- [ ] State: list/detail/form dùng `System*Bloc` / `App*Bloc`, **không** Cubit (trừ khi state UI-local đơn giản)
- [ ] Ad-hoc API (ngoài System*Bloc): inject `ApiClient`, gọi `_apiClient.dio(ApiService.X)` thẳng trong Bloc + catch `DioException`; **không** tạo `DataSource` cho call lẻ
- [ ] Domain/endpoint đọc từ `lib/app_config.dart` + `lib/api/app_api.dart` của project; **không** suy diễn từ AppCore `ApiService`/`suyxet.com`; URL khác domain → khai báo absolute trong `AppApi`
- [ ] Cấu trúc thư mục đúng: `bloc.dart`, `page.dart`, `widgets/`, `detail/`, `form/`
- [ ] Page nhận args dùng `const FooPage(this.args, {super.key})` + `final Map? args`
- [ ] Đã chạy `dart run tool/gen_router.dart` nếu thêm/đổi/xoá `page.dart`
- [ ] **Không sửa tay** `lib/routes.dart` / `lib/router_constants.dart` / `lib/gen/` / `lib/l10n/app_*.arb` / `lib/l10n/app_localizations.dart`
- [ ] Navigation qua `appNavigator.pushNamed(RouterConstants.xxx, arguments: {...})`
- [ ] Import duy nhất qua `import '../../.../import.dart'`
- [ ] Form inputs dùng `Field*` (không `TextFormField`/Material thuần)
- [ ] Scaffold dùng `SystemListScaffold` / `SystemDetailScaffold` / `SystemFormScaffold`; form bắt buộc unfocus
- [ ] AppBar dùng `BaseAppBar(context: context, ...)`
- [ ] List item: ưu tiên `ItemBase`, separator 12, padding 16, radius 12/16/20
- [ ] Color/spacing dùng `Palette.*` + 8pt grid; **không** hardcode `Color(0x...)`
- [ ] Chuỗi UI dùng `context.l10n.<key>` (không hardcode tiếng Việt/Anh trong widget)
- [ ] Logging dùng `debugPrint()` / `FirebaseCrashlytics`; **không** `print()`
- [ ] Controller / FocusNode / StreamSubscription đã `dispose()`
- [ ] Không dùng `BuildContext` sau `await` chưa check `mounted`
- [ ] Search/filter có debounce; submit form chống double-tap

---

## Phụ lục — Một số chốt nhỏ hay quên

- `state.items` của `SystemListState<T>` trả về `List<MapEntry<String, T>>` — extract value qua `.map((e) => e.value)`.
- Refresh có spinner: `RefreshBaseList(clearItems: false, completer: completer)` + `Completer<void>` (nhớ `import 'dart:async'`).
- `SystemDetailBloc` đọc data qua `state.result` (Map), KHÔNG có generic model.
- Hive boxes: `auth_cache`, `merchant_cache`, `reference_cache` — đã declare ở `bootstrap()` (`lib/app_config.dart`).
- Reference data (provinces/wards/categories) đã có cached `DataSource`: `geoDataSource()` / `categoryDataSource()` (qua `import.dart`).
- Dialog dùng `AppDialogs.delete` / `AppDialogs.showConfirmDialog` — không gọi `showDialog` trực tiếp.
- Thông báo dùng `AppSnackbar` / `showMessage()`.
- Sửa l10n: viết trong `lib/l10n/src/<name>_<locale>.arb` rồi `dart run lib/tool/merge.dart` — **không** sửa tay `lib/l10n/app_*.arb`.
