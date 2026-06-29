# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`couppa_mini` is a Flutter coupon app with two user roles (`user` / `merchant`) sharing one binary. It is built on top of **AppCore** — a private package (`github.com/MappaWeb/AppCore`) pinned by git `ref` in `pubspec.yaml`, consumed as the `core`, `core_data`, `core_rest`, `core_auth`, `core_monitoring` packages. Most cross-cutting machinery (BLoC/Cubit re-exports, `ApiClient`/`ApiService`, auth/session, `appNavigator`, `AppRouter`, `Field*` form widgets, Hive caching, `FieldScope`/upload) lives in AppCore, not here.

## Common commands

```bash
# Run (dev flavor — hardcoded dev API domain)
flutter run -t lib/main_dev.dart        # or lib/main.dart (identical to dev)

# Run (prod — API_DOMAIN is REQUIRED via dart-define, app throws on startup without it)
flutter run -t lib/main_prod.dart --dart-define=API_DOMAIN=api.suyxet.com

# Regenerate routes after adding/removing/renaming a page.dart (see Routing below)
dart run tool/gen_router.dart

# Regenerate localizations after editing .arb files
flutter gen-l10n          # config in l10n.yaml; outputs lib/l10n/app_localizations*.dart

# Regenerate assets after changing files under assets/ (flutter_gen)
dart run build_runner build --delete-conflicting-outputs   # outputs lib/gen/assets.gen.dart

# Lint / analyze (flutter_lints)
flutter analyze

# Tests
flutter test                              # all
flutter test test/widget_test.dart        # single file
flutter test --plain-name "description"   # single test by name
```

Flutter SDK: stable 3.44.x, Dart `^3.12.2`.

## Architecture

### Entry points & flavors
`lib/main.dart`, `lib/main_dev.dart`, `lib/main_prod.dart` each build an immutable `AppFlavorConfig` (`lib/config/app_flavor.dart`), then call **`bootstrap()`** in `lib/app_config.dart`. `bootstrap()` is the single composition root: it constructs `ApiClient`, wires auth (`AuthSetup.create`), notifications (SSE + count cubit), merchant session, registers routes, and hands everything to AppCore's `init(...)` which builds the `MaterialApp.router`. When adding global services/providers, register them here.

### The `import.dart` barrel
`lib/import.dart` re-exports Flutter material + all AppCore packages + local essentials (`global.dart`, `RouterConstants`, `Palette`, l10n, cache). **Every file under `lib/pages/` imports only this barrel** (`import '../../../import.dart';`) — don't add per-package imports for things the barrel already provides (`Cubit`, `BlocProvider`, `appNavigator`, `ApiClient`, `Field*`, etc.).

### Routing — generated, do not hand-edit
`lib/routes.dart` and `lib/router_constants.dart` are **generated** by `tool/gen_router.dart` from the file tree under `lib/pages/`. Never edit them by hand. The generator maps `lib/pages/merchant/coupon/form/page.dart` → class `MerchantCouponFormPage` → path `/Merchant/Coupon/Form` → constant `RouterConstants.merchantCouponForm`. Conventions it relies on:
- A page taking arguments must be `const FooPage(this.args, {super.key})` with `final Map? args` (generator detects the `Map?` type and injects `state.uri.queryParameters` or `state.extra`).
- A page with no args: `const FooPage({super.key})`.
- Redirect: add `static String? redirect(BuildContext context, GoRouterState state)` (see `lib/pages/start/page.dart`).
- Exclude a page: add `// @ignoreRouter` comment. Rename folder→segment via `lib/router_factory.json`. Non-conventional routes go in `lib/routes_manual.json`.

After any page change: run `dart run tool/gen_router.dart` and verify the two generated files.

### Role-based shell vs. plain routes
There are **two route sets**, both passed to `AppRouter.init` in `bootstrap()`:
- `lib/shell_router.dart` — a `StatefulShellRoute` with 5 branches; `_roleBranches` selects which tabs a `user` vs `merchant` sees (driven by `getRole()` in `lib/global.dart`). All branches require auth (`_requireAuth` → `/Login`).
- `lib/routes.dart` (generated) — flat routes for push navigation (detail/form/etc.).

`getRole()` derives the role from `currentUser?.role` string in `lib/global.dart` — that's the single source of truth for role.

### Feature structure & state
Features live in `lib/pages/<group>/<feature>/` with `bloc.dart` + `page.dart`. **Prefer AppCore's `SystemListBloc` / `SystemDetailBloc` / `SystemFormBloc` (and the convenience subclasses `AppListBloc<T>` / `AppFormBloc<T>`) for lists, detail screens, and forms** over a hand-rolled `Cubit` + `state.copyWith`. These are event-based `Bloc`s from `core_state` — reachable through the `import.dart` barrel (`package:core/core.dart` re-exports `core_state`), no extra imports — and provide pagination / search / filter / fetch-on-init / refresh / submit / validation out of the box; pair them with the ready widgets (`SystemListView` / `scaffold_list` for lists, `scaffold_detail` / `detail_widget` for detail, `scaffold_form` / `form_widget` + `FormFieldWrapper` for forms). `AppFormBloc<T>`/`AppListBloc<T>` require `T extends JsonModel<T>` + a `DataSource`; there is **no `AppDetailBloc`** — subclass `SystemDetailBloc` directly. Use the raw `SystemListBloc`/`SystemFormBloc` (with `T = Map`) when you don't have a JsonModel. Fall back to a plain `Cubit` + `state.copyWith` only for trivial, UI-local state with no list/detail/form/server interaction. Many existing pages (login/coupon/etc.) still use the older Cubit pattern (worked template in memory `feature-example-template`) — that's now the fallback; migrate opportunistically, don't rewrite wholesale.

### Direct API calls in Bloc (ad-hoc, outside System*Bloc)
When a feature must make ad-hoc API calls that don't fit `AppListBloc`/`AppFormBloc`/`SystemDetailBloc` (e.g. action endpoints, single GET/PATCH outside list/form CRUD), **call the API directly in the Bloc/Cubit** — do **not** create an intermediate `DataSource` class for one-off calls. Convention (see `lib/pages/account/profile/bloc.dart` as reference, and `lib/pages/user/voucher_claim/bloc.dart`):
- Inject `ApiClient` via constructor: `required ApiClient apiClient`.
- In handlers: `await _apiClient.dio(ApiService.X).get/post/patch(path, data: ...)`.
- Catch `DioException` locally (already exported transitively via `import.dart` → `core_rest`; **do not** add `import 'package:dio/dio.dart'`). Map to state error.
- If the endpoint lives on a different domain than the `ApiService` enum's subdomain, declare an **absolute URL** in `lib/api/app_api.dart` (e.g. `AppApi.voucher.campaignByCode`). Dio bypasses `baseUrl` for absolute URLs while still applying all interceptors (auth/logger/error).
- For session updates after an API call (e.g. `PATCH /auth/me`), dispatch via `AuthSetup.instance.authSessionBloc.add(SessionUserUpdated(...))`.

Only extract a `DataSource` when the feature has multiple endpoints worth grouping or needs reuse across blocs.

### App owns API/AuthSetup config — AppCore's `ApiService`/`suyxet.com` is just a fallback sample
The `ApiService` enum + the `api.suyxet.com` defaults in AppCore are **convention/fallback samples** for downstream apps to reference — **not** the runtime spec. Each app builds its own setup in `bootstrap()` (`lib/app_config.dart`): it constructs `ApiClient(ApiService.urlsFrom(config.apiDomain))` and `AuthSetup.create(apiClient: ..., authBaseUrl: ..., config: AuthConfig(mePath/refreshPath/logoutPath/...), onRequireLogin: ...)` against the project's own `config.apiDomain` (`AppFlavorConfig`). `ApiService.coupon`, `ApiService.merchant`, ... are just subdomain prefixes — bound to whatever domain the app sets.

**When building any new feature: always read `lib/app_config.dart` + `lib/api/app_api.dart` of the project first to learn the real domain/endpoints. Do not infer from AppCore's `ApiService` enum or assume `suyxet.com`** — that's just sample. Endpoints not on the main domain go in `AppApi` as absolute URLs (see `AppApi.voucher` for the `voucher.api-qr.iotcommunication.net` example). In feature code, reference only `ApiService.X` + `AppApi.X.path` — never hardcode full URLs.

### Forms — use `Field*` widgets
When building any input (forms, dialogs, login, search), **prefer `Field*` widgets from `core_widgets/fields.dart`** (`FieldText`, `FieldPassword`, `FieldDropdown`, `FieldSelect`, `FieldDate`, `FieldUpload`, ...) over raw Material `TextFormField`/`Checkbox`/`Switch`. They are re-exported through `import.dart` and carry the design-system styling, validation, and upload wiring (`FieldScope` is set up in `bootstrap()`). Only fall back to Material when no `Field*` equivalent exists, and say why. See memory `feedback-use-field-widgets`.

### Localization (multi-author ARB)
`lib/l10n/app_en.arb` / `app_vi.arb` are the templates consumed by `flutter gen-l10n`. Per-developer fragment ARBs live in `lib/l10n/src/<author>_{en,vi}.arb` and are merged into the templates (keep keys in sync across `en`/`vi`). Access strings via `context.l10n.<key>` or, without a context, `L10n.of.<key>` (`lib/l10n/l10n_helper.dart`). Supported locales: `vi` (default), `en`.

### Reference data cache
`lib/data/cache/` is a Hive-backed cache decorator for slow-changing reference data (provinces/wards/categories). Use the ready sources `geoDataSource()` / `categoryDataSource()` (exported via `import.dart`) as drop-in `DataSource`s; register new cached sources in `cached_data_sources.dart`. Full notes in `lib/data/cache/README.md`. Hive boxes are declared in `bootstrap()` (`auth_cache`, `merchant_cache`, `reference_cache`).

### Misc conventions
- Colors come from `lib/utils/palette.dart` (`Palette.primary`, etc.) — don't hardcode `Color(0x...)` in widgets.
- Navigate with `appNavigator.pushNamed(RouterConstants.xxx, arguments: {...})` — use the generated constants, not string literals.
- Reusable widgets (used in ≥2 pages) go under `lib/widget/`; single-use widgets stay private (`_Foo`) in the same `page.dart`.