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
Features live in `lib/pages/<group>/<feature>/` with `bloc.dart` (Model + State + Cubit in one file) + `page.dart`. **This project uses simple `Cubit` + `state.copyWith`**, not the `Bloc<Event,State>` or `SystemListBloc/SystemFormBloc` patterns from AppCore — do not mix them. Pattern: `page.dart` is a `StatelessWidget` wrapping a `BlocProvider(create: ...Cubit()..load())` around a private `_FooView`. A detailed worked template (list/detail/form/navigation) is in the recalled memory `feature-example-template` — follow it for new features.

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