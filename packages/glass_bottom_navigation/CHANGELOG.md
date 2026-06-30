## 0.2.0

- Added iOS 26+ native Liquid Glass rendering for the bottom navigation bar.
- Added iOS 26+ native Liquid Glass action buttons for back, close, search,
  more, and custom SF Symbol buttons.
- Added `nativeSymbolName` support for navigation items and custom action
  buttons so iOS can render SF Symbols in the native path.
- Added `GlassActionButton`, `GlassActionButtonRow`, `GlassActionButtonItem`,
  and action button style APIs.
- Added leading and trailing action button support on `GlassBottomBar`.
- Updated the Android and iOS < 26 Flutter fallback to simulate Liquid Glass
  with brighter frosted surfaces, selected-pill effects, and press feedback.
- Added fallback glass action button styling for Android and iOS < 26.
- Updated the example app and README screenshots for native iOS and Flutter
  fallback glass states.

## 0.1.0

- Simplified public API for `GlassBottomBar`.
- Added `GlassBottomNavStyle` for grouped visual customization.
- Added optional built-in search button with `onSearchTap`.
- Added optional `width` and `height` overrides on `GlassBottomBar`.
- Added automatic responsive width/height sizing when overrides are not set.
- Enforced supported item count (2 to 4) and index range assertions.
- Implemented centered layout without search and trailing layout with search.
- Replaced template library entrypoint with real package exports.
- Added standard `/example` Flutter app with 2/3/4 tab demos and search toggle.
- Added widget tests for rendering, assertions, interactions, and layout behavior.
- Updated README documentation.
