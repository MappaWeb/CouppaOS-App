import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glass_bottom_navigation/glass_bottom_navigation.dart';

void main() {
  List<GlassBarItem> buildItems(int count) {
    return List.generate(
      count,
      (index) => GlassBarItem(icon: Icons.circle, label: 'Tab ${index + 1}'),
    );
  }

  Widget host({
    required List<GlassBarItem> items,
    required int currentIndex,
    required ValueChanged<int> onTap,
    VoidCallback? onSearchTap,
    List<GlassActionButtonItem> leadingActions = const [],
    List<GlassActionButtonItem> trailingActions = const [],
    double? width,
    double? height,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: GlassBottomBar(
            items: items,
            currentIndex: currentIndex,
            onTap: onTap,
            onSearchTap: onSearchTap,
            leadingActions: leadingActions,
            trailingActions: trailingActions,
            width: width,
            height: height,
          ),
        ),
      ),
    );
  }

  testWidgets('renders 2, 3, and 4 tabs', (tester) async {
    for (final count in [2, 3, 4]) {
      await tester.pumpWidget(
        host(items: buildItems(count), currentIndex: 0, onTap: (_) {}),
      );
      await tester.pumpAndSettle();

      for (var i = 1; i <= count; i++) {
        expect(find.text('Tab $i'), findsOneWidget);
      }
    }
  });

  test('asserts for invalid item count and invalid currentIndex', () {
    expect(
      () =>
          GlassBottomBar(items: buildItems(1), currentIndex: 0, onTap: (_) {}),
      throwsA(isA<AssertionError>()),
    );

    expect(
      () =>
          GlassBottomBar(items: buildItems(5), currentIndex: 0, onTap: (_) {}),
      throwsA(isA<AssertionError>()),
    );

    expect(
      () =>
          GlassBottomBar(items: buildItems(3), currentIndex: 3, onTap: (_) {}),
      throwsA(isA<AssertionError>()),
    );

    expect(
      () => GlassBottomBar(
        items: buildItems(3),
        currentIndex: 0,
        onTap: (_) {},
        width: 0,
      ),
      throwsA(isA<AssertionError>()),
    );

    expect(
      () => GlassBottomBar(
        items: buildItems(3),
        currentIndex: 0,
        onTap: (_) {},
        height: 0,
      ),
      throwsA(isA<AssertionError>()),
    );
  });

  testWidgets('hides search when onSearchTap is null', (tester) async {
    await tester.pumpWidget(
      host(items: buildItems(3), currentIndex: 0, onTap: (_) {}),
    );

    expect(
      find.byKey(const ValueKey('glass_bottom_bar_search_button')),
      findsNothing,
    );
  });

  testWidgets('shows and handles search tap when onSearchTap is provided', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      host(
        items: buildItems(3),
        currentIndex: 0,
        onTap: (_) {},
        onSearchTap: () => tapped = true,
      ),
    );

    final searchButton = find.byKey(
      const ValueKey('glass_bottom_bar_search_button'),
    );
    expect(searchButton, findsOneWidget);

    await tester.tap(searchButton);
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('calls onTap with tapped index', (tester) async {
    var tappedIndex = -1;

    await tester.pumpWidget(
      host(
        items: buildItems(3),
        currentIndex: 0,
        onTap: (index) => tappedIndex = index,
      ),
    );

    await tester.tap(find.text('Tab 2'));
    await tester.pump();

    expect(tappedIndex, 1);
  });

  testWidgets('renders and handles leading and trailing action buttons', (
    tester,
  ) async {
    var backTapped = false;
    var moreTapped = false;

    await tester.pumpWidget(
      host(
        items: buildItems(3),
        currentIndex: 0,
        onTap: (_) {},
        leadingActions: [
          GlassActionButtonItem.back(onTap: () => backTapped = true),
        ],
        trailingActions: [
          GlassActionButtonItem.more(onTap: () => moreTapped = true),
        ],
      ),
    );

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pump();

    expect(backTapped, isTrue);
    expect(moreTapped, isTrue);
  });

  testWidgets('supports a standalone action button', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassActionButton(
              item: GlassActionButtonItem.back(onTap: () => tapped = true),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('supports a standalone action button row', (tester) async {
    var moreTapped = false;
    var searchTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassActionButtonRow(
              actions: [
                GlassActionButtonItem.more(onTap: () => moreTapped = true),
                GlassActionButtonItem.search(onTap: () => searchTapped = true),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.search_rounded));
    await tester.pump();

    expect(moreTapped, isTrue);
    expect(searchTapped, isTrue);
  });

  testWidgets('does not throw when bottom bar actions leave little nav width', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      host(
        items: buildItems(4),
        currentIndex: 0,
        onTap: (_) {},
        leadingActions: [GlassActionButtonItem.back(onTap: () {})],
        trailingActions: [GlassActionButtonItem.more(onTap: () {})],
        onSearchTap: () {},
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('glass_bottom_bar_pill')), findsOneWidget);
  });

  testWidgets('centers without search and shifts for trailing search layout', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(420, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      host(items: buildItems(3), currentIndex: 0, onTap: (_) {}),
    );
    await tester.pumpAndSettle();

    final viewCenterX = tester.getCenter(find.byType(Scaffold)).dx;
    final centeredPillX = tester
        .getCenter(find.byKey(const ValueKey('glass_bottom_bar_pill')))
        .dx;

    expect((centeredPillX - viewCenterX).abs(), lessThan(1.0));

    await tester.pumpWidget(
      host(
        items: buildItems(3),
        currentIndex: 0,
        onTap: (_) {},
        onSearchTap: () {},
      ),
    );
    await tester.pumpAndSettle();

    final shiftedPillX = tester
        .getCenter(find.byKey(const ValueKey('glass_bottom_bar_pill')))
        .dx;
    final searchButtonX = tester
        .getCenter(find.byKey(const ValueKey('glass_bottom_bar_search_button')))
        .dx;

    expect(shiftedPillX, lessThan(viewCenterX));
    expect(searchButtonX, greaterThan(shiftedPillX));
  });

  testWidgets('supports explicit width and height overrides', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      host(
        items: buildItems(3),
        currentIndex: 0,
        onTap: (_) {},
        width: 220,
        height: 62,
      ),
    );
    await tester.pumpAndSettle();

    final pillFinder = find.byKey(const ValueKey('glass_bottom_bar_pill'));
    final pillSize = tester.getSize(pillFinder);

    expect(pillSize.width, moreOrLessEquals(220, epsilon: 0.01));
    expect(pillSize.height, moreOrLessEquals(70, epsilon: 0.01));
  });

  testWidgets('uses automatic responsive height by default', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      host(items: buildItems(3), currentIndex: 0, onTap: (_) {}),
    );
    await tester.pumpAndSettle();

    final pillFinder = find.byKey(const ValueKey('glass_bottom_bar_pill'));
    final pillSize = tester.getSize(pillFinder);

    expect(pillSize.height, moreOrLessEquals(64, epsilon: 0.01));
  });
}
