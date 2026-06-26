// Run from project root:
//   dart run tool/gen_router.dart
//
// Generates:
//   lib/routes.dart           — GoRoute list (auto + manual)
//   lib/router_constants.dart — path constants (auto + manual)
//
// Conventions:
//   - page.dart file at lib/pages/foo/bar/page.dart → class FooBarPage
//   - Add `// @ignoreRouter` to any page to exclude it
//   - router_factory.json  → rename folder segments (e.g. "merchant": "Shop")
//   - routes_manual.json   → explicit entries for pages that don't match the convention
//
// Works the same for path-dependency packages that have their own lib/pages/.

import 'dart:collection';
import 'dart:convert';
import 'dart:io';

// ---------------------------------------------------------------------------
// Helpers shared with makeGoRouter logic
// ---------------------------------------------------------------------------

Map<String, String> routerFix = {};

String _firstUpper(String s) {
  const acronyms = ['lms', 'rms', 'cms', 'qr'];
  if (acronyms.contains(s)) return s.toUpperCase();
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

String _firstLower(String s) {
  if (s.isEmpty) return s;
  return s[0].toLowerCase() + s.substring(1);
}

/// Converts a dot-separated key like "market_surveillance.article"
/// into segments like ["MarketSurveillance", "Article"], then applies routerFix.
List<String> _toSegments(String key) {
  return key.split('.').map((part) {
    final name = part.split('_').map(_firstUpper).join('');
    final lower = name.toLowerCase();
    return routerFix.containsKey(lower) ? routerFix[lower]! : name;
  }).toList();
}

Future<void> _loadRouterFix(String jsonPath) async {
  if (!File(jsonPath).existsSync()) return;
  final Map data = json.decode(File(jsonPath).readAsStringSync()) as Map;
  data.forEach((k, v) => routerFix[k.toString().toLowerCase()] = v.toString());
}

// ---------------------------------------------------------------------------
// Import-path helpers
// ---------------------------------------------------------------------------

/// Returns the import string for a page asset.
/// [entityPath] — absolute or relative path to the page file.
/// [pkgName]    — Dart package name.
/// [isLocal]    — true for the app's own lib/pages.
String _importPath(String entityPath, String pkgName, {required bool isLocal}) {
  final normalized = entityPath.replaceAll('\\', '/');
  if (isLocal) {
    // Relative to lib/ → "pages/foo/bar/page.dart"
    final idx = normalized.lastIndexOf('/lib/');
    if (idx == -1) {
      final libIdx = normalized.indexOf('lib/');
      return libIdx == -1 ? normalized : normalized.substring(libIdx + 4);
    }
    return normalized.substring(idx + 5);
  } else {
    // package:pkgName/pages/foo/bar/page.dart
    final idx = normalized.lastIndexOf('/lib/');
    final rel = idx == -1 ? normalized : normalized.substring(idx + 5);
    return 'package:$pkgName/$rel';
  }
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

void main(List<String> arguments) async {
  final pubspec = File('pubspec.yaml').readAsStringSync();

  // 1. Load router_factory.json (local + from each path dep)
  await _loadRouterFix('lib/router_factory.json');

  // 2. Collect (pagesDir, pkgName, isLocal) to scan — shared first, local last
  final scanList = <(String dir, String pkg, bool isLocal)>[];

  // Parse path: dependencies from pubspec
  final pathDepRe = RegExp(
      r'^\s{2}(\w+):\s*\n(?:\s{4}[^\n]+\n)*?\s{4}path:\s*([^\n]+)',
      multiLine: true);
  for (final m in pathDepRe.allMatches(pubspec)) {
    final pkgName = m.group(1)!;
    final pkgPath = m.group(2)!.trim();
    final pagesDir = '$pkgPath/lib/pages';
    if (Directory(pagesDir).existsSync()) {
      await _loadRouterFix('$pkgPath/lib/router_factory.json');
      scanList.add((pagesDir, pkgName, false));
    }
  }

  // Local lib/pages — added last so it overrides shared packages on key collision
  scanList.add(('lib/pages', 'v_map', true));

  // 3. Read ignore list
  String ignoreContent = '';
  if (File('lib/ignore_router.dart').existsSync()) {
    ignoreContent = File('lib/ignore_router.dart').readAsStringSync();
  }

  // 4. Scan all page files
  final Map<String, Map<String, dynamic>> pages = {};

  for (final (dir, pkg, isLocal) in scanList) {
    final dirObj = Directory(dir);
    if (!dirObj.existsSync()) continue;

    dirObj.listSync(recursive: true, followLinks: false).forEach((entity) {
      if (entity is! File) return;
      final filePath = entity.path.replaceAll('\\', '/');
      if (!RegExp(r'/[Pp]age\.dart$').hasMatch(filePath)) return;

      // Key = dot-separated path segments after "pages/"
      final pagesIdx = filePath.indexOf('/pages/');
      if (pagesIdx == -1) return;
      String s = filePath.substring(pagesIdx + 7);

      if (s.contains('/widgets/') || s.startsWith('widgets/')) return;

      final key = s
          .replaceFirst(RegExp(r'/?[Pp]age\.dart$'), '')
          .replaceAll('/', '.');

      if (key.isEmpty) return;

      final content = entity.readAsStringSync();
      if (content.contains('@ignoreRouter')) return;

      final importPath = _importPath(filePath, pkg, isLocal: isLocal);
      final importLine = "import '$importPath';";
      if (ignoreContent.contains(importLine)) return;

      final segments = _toSegments(key);
      final className = '${segments.join('')}Page';

      // Detect constructor parameter
      String? paramType;
      final paramMatch = RegExp(
              '(${RegExp.escape(className)}\\([^(a-zA-Z0-9){]*\\[?(this|super)\\.)([a-zA-Z0-9]+)')
          .firstMatch(content);
      final paramsName = paramMatch?.group(3);
      final paramsKind = paramMatch?.group(2);

      if (paramsKind == 'super' && paramsName != null) {
        final typeRe = RegExp("@SuperParameterType\\('$paramsName',?\\s*'([^']+)");
        paramType = typeRe.hasMatch(content)
            ? typeRe.firstMatch(content)!.group(1)
            : 'dynamic';
      } else if (paramsName != null) {
        final typeRe = RegExp('final\\s+([a-zA-Z0-9]+\\??)\\s+$paramsName')
            .firstMatch(content);
        paramType = typeRe?.group(1);
      }

      // Local overrides shared on same key
      pages[className] = {
        'key': key,
        'path': importPath,
        'hasParams': paramsName != null && paramType != null,
        'paramsType': paramType,
        'hasRedirect':
            content.contains('static String? redirect(BuildContext context, GoRouterState state)'),
        'useCustomRouter': content.contains('@useCustomRouter'),
      };
    });
  }

  // Sort alphabetically so output is deterministic
  final sorted = SplayTreeMap<String, Map<String, dynamic>>.from(
      pages, (a, b) => a.compareTo(b));

  // 5. Read routes_manual.json (non-standard routes)
  List manualRoutes = [];
  if (File('lib/routes_manual.json').existsSync()) {
    manualRoutes = json.decode(File('lib/routes_manual.json').readAsStringSync()) as List;
  }

  // ---------------------------------------------------------------------------
  // Generate routes.dart
  // ---------------------------------------------------------------------------
  // Collect all imports, then split: package: first, relative second (linter rule)
  final allImports = <String>{};
  for (final v in sorted.values) {
    allImports.add("import '${v['path']}';");
  }
  for (final m in manualRoutes) {
    allImports.add("import '${m['import']}';");
  }

  final pkgImports = allImports.where((s) => s.contains("'package:")).toList()..sort();
  final relImports = allImports.where((s) => !s.contains("'package:")).toList()..sort();

  // routes.dart needs RouteBase + GoRoute — add to pkg group then re-sort
  final routesPkgImports = [
    ...pkgImports,
    "import 'package:core/core.dart' show RouteBase, GoRoute;",
  ]..sort();

  // Page-only imports (shared_core.dart omitted — not needed in constants file)
  final pageImportBuf = StringBuffer();
  for (final s in pkgImports) {
    pageImportBuf.writeln(s);
  }
  if (relImports.isNotEmpty) pageImportBuf.writeln();
  for (final s in relImports) {
    pageImportBuf.writeln(s);
  }

  // Import block for routes.dart
  final routesImportBuf = StringBuffer();
  for (final s in routesPkgImports) {
    routesImportBuf.writeln(s);
  }
  if (relImports.isNotEmpty) routesImportBuf.writeln();
  for (final s in relImports) {
    routesImportBuf.writeln(s);
  }

  final routesBuf = StringBuffer()
    ..write(routesImportBuf)
    ..writeln()
    ..writeln('List<RouteBase> get routes => <RouteBase>[');

  // Root "/" — StartPage always goes first
  if (sorted.containsKey('StartPage')) {
    routesBuf.writeln("""  GoRoute(
    path: '/',
    builder: (context, state) => const StartPage(),
    redirect: StartPage.redirect,
  ),""");
  }

  // Auto-generated routes
  for (final entry in sorted.entries) {
    final v = entry.value;
    final segments = _toSegments(v['key'] as String);
    if (v['useCustomRouter'] == true) {
      routesBuf.writeln('  ${segments.join('')}Page.router,');
      continue;
    }
    routesBuf.write(_routeEntry(segments, v));
  }

  // Manual routes
  for (final m in manualRoutes) {
    routesBuf.write(_manualRouteEntry(m));
  }

  routesBuf.writeln('];');

  // ---------------------------------------------------------------------------
  // Generate router_constants.dart
  // ---------------------------------------------------------------------------
  final constBuf = StringBuffer()
    ..write(pageImportBuf) // page imports only — no GoRoute/RouteBase needed
    ..writeln('class RouterConstants {')
    ..writeln('  const RouterConstants._();')
    ..writeln("  static String get root => '/';");

  for (final entry in sorted.entries) {
    final v = entry.value;
    if (v['useCustomRouter'] == true) continue;
    final segments = _toSegments(v['key'] as String);
    constBuf
      ..writeln()
      ..writeln('  ///Router to [${segments.join('')}Page]')
      ..writeln(
          "  static String get ${_firstLower(segments.join(''))} => '/${segments.join('/')}';");
  }

  for (final m in manualRoutes) {
    final path = m['path'] as String;
    final parts = path.split('/').where((s) => s.isNotEmpty).toList();
    final constName = _firstLower(parts.join(''));
    final className = m['class'] as String;
    constBuf
      ..writeln()
      ..writeln('  ///Router to [$className]')
      ..writeln("  static String get $constName => '$path';");
  }

  constBuf.writeln('}');

  // ---------------------------------------------------------------------------
  // Write files
  // ---------------------------------------------------------------------------
  File('lib/routes.dart').writeAsStringSync(routesBuf.toString());
  File('lib/router_constants.dart').writeAsStringSync(constBuf.toString());

  final total = sorted.length + manualRoutes.length;
  print('✅  Generated lib/routes.dart ($total routes)');
  print('✅  Generated lib/router_constants.dart');
}

// ---------------------------------------------------------------------------
// Code-generation helpers
// ---------------------------------------------------------------------------

String _routeEntry(List<String> segments, Map<String, dynamic> v) {
  final paramsType = v['paramsType'] as String?;
  final hasParams = v['hasParams'] == true;
  final hasRedirect = v['hasRedirect'] == true;

  final castSuffix =
      (paramsType != null && paramsType.isNotEmpty && paramsType != 'dynamic')
          ? ' as $paramsType'
          : '';
  final isMap = paramsType == 'Map' || paramsType == 'Map?';
  final extra = isMap
      ? 'state.uri.queryParameters.isNotEmpty\n    ? state.uri.queryParameters : state.extra$castSuffix'
      : 'state.extra$castSuffix';
  final widget = hasParams
      ? '${segments.join('')}Page($extra)'
      : 'const ${segments.join('')}Page()';

  final buf = StringBuffer()
    ..writeln('  GoRoute(')
    ..writeln("    path: '/${segments.join('/')}',")
    ..writeln('    builder: (context, state) => $widget,');
  if (hasRedirect) buf.writeln('    redirect: ${segments.join('')}Page.redirect,');
  buf.writeln('  ),');
  return buf.toString();
}

String _manualRouteEntry(Map m) {
  final path = m['path'] as String;
  final className = m['class'] as String;
  final paramsType = m['paramsType'] as String?;
  final hasParams = paramsType != null;

  final castSuffix =
      (paramsType != null && paramsType.isNotEmpty && paramsType != 'dynamic')
          ? ' as $paramsType'
          : '';
  final isMap = paramsType == 'Map' || paramsType == 'Map?';
  final extra = isMap
      ? 'state.uri.queryParameters.isNotEmpty\n    ? state.uri.queryParameters : state.extra$castSuffix'
      : 'state.extra$castSuffix';
  final widget = hasParams ? '$className($extra)' : 'const $className()';

  return '''  GoRoute(
    path: '$path',
    builder: (context, state) => $widget,
  ),
''';
}
