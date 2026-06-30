import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _nativeGlassChannel = MethodChannel('glass_bottom_navigation');
const _nativeGlassButtonViewType =
    'glass_bottom_navigation/native_glass_button';
const _nativeGlassBarViewType = 'glass_bottom_navigation/native_glass_bar';

/// Builds the backdrop filter for the faux-glass surfaces: a gaussian blur with
/// an optional saturation boost composed on top. Real iOS Liquid Glass amplifies
/// the colour of the content behind it, not just blurs it, so a saturation > 1
/// gives the fallback that same vibrancy. [saturation] == 1 is a plain blur.
ImageFilter _glassBackdrop(double sigma, double saturation) {
  final blur = ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);
  if (saturation == 1.0) {
    return blur;
  }
  return ImageFilter.compose(
    outer: ColorFilter.matrix(_saturationMatrix(saturation)),
    inner: blur,
  );
}

/// A 5x4 colour matrix that scales saturation around luminance-weighted grey.
List<double> _saturationMatrix(double s) {
  const lumR = 0.2126;
  const lumG = 0.7152;
  const lumB = 0.0722;
  final sr = (1 - s) * lumR;
  final sg = (1 - s) * lumG;
  final sb = (1 - s) * lumB;
  return <double>[
    sr + s, sg, sb, 0, 0, //
    sr, sg + s, sb, 0, 0, //
    sr, sg, sb + s, 0, 0, //
    0, 0, 0, 1, 0, //
  ];
}

enum GlassActionIcon {
  back,
  close,
  search,
  more,
  add,
  settings,
  favorite,
  share,
  custom,
}

enum GlassActionButtonMode { flutter, nativeLiquidGlassOnIOS26 }

enum GlassNativeButtonStyle { regular, prominent, clear, prominentClear }

class GlassActionButtonItem {
  final GlassActionIcon type;
  final IconData? icon;
  final String? nativeSymbolName;
  final VoidCallback onTap;
  final String? semanticLabel;
  final GlassNativeButtonStyle nativeStyle;

  const GlassActionButtonItem({
    required this.type,
    required this.onTap,
    this.icon,
    this.nativeSymbolName,
    this.semanticLabel,
    this.nativeStyle = GlassNativeButtonStyle.regular,
  }) : assert(
         type != GlassActionIcon.custom || icon != null,
         'Custom action buttons require an icon.',
       );

  const GlassActionButtonItem.back({
    required this.onTap,
    this.semanticLabel = 'Back',
    this.nativeStyle = GlassNativeButtonStyle.regular,
  }) : type = GlassActionIcon.back,
       nativeSymbolName = 'chevron.backward',
       icon = Icons.arrow_back_ios_new_rounded;

  const GlassActionButtonItem.close({
    required this.onTap,
    this.semanticLabel = 'Close',
    this.nativeStyle = GlassNativeButtonStyle.regular,
  }) : type = GlassActionIcon.close,
       nativeSymbolName = 'xmark',
       icon = Icons.close_rounded;

  const GlassActionButtonItem.search({
    required this.onTap,
    this.semanticLabel = 'Search',
    this.nativeStyle = GlassNativeButtonStyle.regular,
  }) : type = GlassActionIcon.search,
       nativeSymbolName = 'magnifyingglass',
       icon = Icons.search_rounded;

  const GlassActionButtonItem.more({
    required this.onTap,
    this.semanticLabel = 'More',
    this.nativeStyle = GlassNativeButtonStyle.regular,
  }) : type = GlassActionIcon.more,
       nativeSymbolName = 'ellipsis',
       icon = Icons.more_horiz_rounded;
}

class GlassBarItem {
  final IconData icon;
  final String label;
  final String? nativeSymbolName;

  const GlassBarItem({
    required this.icon,
    required this.label,
    this.nativeSymbolName,
  });
}

class GlassBottomNavStyle {
  final Color pillTint;
  final double pillBlurSigma;
  final double pillFilmStart;
  final double pillFilmEnd;
  final double pillBorderOpacity;
  final bool showSpecularDot;
  final double pillFrostOpacity;

  /// Saturation multiplier applied to the content behind the faux-glass surfaces
  /// (bar + selected pill). > 1 amplifies colour like real Liquid Glass; 1 is a
  /// plain blur. Has no effect on the iOS 26 native path.
  final double backdropSaturation;

  final Color accent;
  final double height;
  final double radius;
  final EdgeInsets barPadding;
  final double widthFactor;
  final double edgePadding;

  final double selectedWidthFactor;
  final double selectedSideInsetPx;
  final double selectedHeightFactor;
  final double selectedInsetPx;
  final bool selectedCornerAuto;
  final double selectedBlurSigma;
  final double selectedStartOpacity;
  final double selectedEndOpacity;
  final double selectedBorderOpacity;
  final double selectedFrostOpacity;
  final double selectedRadialOpacity;
  final double selectedRadialRadiusFactor;
  final Alignment selectedRadialCenter;

  final double searchButtonSize;
  final double searchButtonBlur;
  final double searchButtonBorderWidth;
  final double searchGap;
  final IconData searchIcon;
  final GlassActionButtonMode actionButtonMode;

  /// Icon size for the Flutter-rendered bar items (non-iOS-26 path).
  final double iconSize;

  /// SF Symbol point size for the native iOS 26 UITabBar items.
  final double nativeIconPointSize;

  /// SF Symbol weight name for the native iOS 26 UITabBar items.
  /// One of: ultraLight, thin, light, regular, medium, semibold, bold, heavy, black.
  final String nativeIconWeight;

  const GlassBottomNavStyle({
    this.pillTint = const Color(0xFFFFFFFF),
    this.pillBlurSigma = 26,
    this.pillFilmStart = 0.42,
    this.pillFilmEnd = 0.26,
    this.pillBorderOpacity = 0,
    this.showSpecularDot = false,
    this.pillFrostOpacity = 0.09,
    this.backdropSaturation = 1.0,
    this.accent = const Color(0xFFFF2D55),
    this.height = 68,
    this.radius = 26,
    this.barPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.widthFactor = 0.86,
    this.edgePadding = 16,
    this.selectedWidthFactor = 1,
    this.selectedSideInsetPx = 1.5,
    this.selectedHeightFactor = 1,
    this.selectedInsetPx = 1,
    this.selectedCornerAuto = true,
    this.selectedBlurSigma = 26,
    this.selectedStartOpacity = 0.50,
    this.selectedEndOpacity = 0.30,
    this.selectedBorderOpacity = 0,
    this.selectedFrostOpacity = 0.16,
    this.selectedRadialOpacity = 0.14,
    this.selectedRadialRadiusFactor = 0.90,
    this.selectedRadialCenter = const Alignment(-0.020, -0.20),
    this.searchButtonSize = 56,
    this.searchButtonBlur = 48,
    this.searchButtonBorderWidth = 1.4,
    this.searchGap = 12,
    this.searchIcon = Icons.search_rounded,
    this.actionButtonMode = GlassActionButtonMode.nativeLiquidGlassOnIOS26,
    this.iconSize = 20,
    this.nativeIconPointSize = 18,
    this.nativeIconWeight = 'regular',
  });

  GlassBottomNavStyle copyWith({
    Color? pillTint,
    double? pillBlurSigma,
    double? pillFilmStart,
    double? pillFilmEnd,
    double? pillBorderOpacity,
    bool? showSpecularDot,
    double? pillFrostOpacity,
    double? backdropSaturation,
    Color? accent,
    double? height,
    double? radius,
    EdgeInsets? barPadding,
    double? widthFactor,
    double? edgePadding,
    double? selectedWidthFactor,
    double? selectedSideInsetPx,
    double? selectedHeightFactor,
    double? selectedInsetPx,
    bool? selectedCornerAuto,
    double? selectedBlurSigma,
    double? selectedStartOpacity,
    double? selectedEndOpacity,
    double? selectedBorderOpacity,
    double? selectedFrostOpacity,
    double? selectedRadialOpacity,
    double? selectedRadialRadiusFactor,
    Alignment? selectedRadialCenter,
    double? searchButtonSize,
    double? searchButtonBlur,
    double? searchButtonBorderWidth,
    double? searchGap,
    IconData? searchIcon,
    GlassActionButtonMode? actionButtonMode,
    double? iconSize,
    double? nativeIconPointSize,
    String? nativeIconWeight,
  }) {
    return GlassBottomNavStyle(
      pillTint: pillTint ?? this.pillTint,
      pillBlurSigma: pillBlurSigma ?? this.pillBlurSigma,
      pillFilmStart: pillFilmStart ?? this.pillFilmStart,
      pillFilmEnd: pillFilmEnd ?? this.pillFilmEnd,
      pillBorderOpacity: pillBorderOpacity ?? this.pillBorderOpacity,
      showSpecularDot: showSpecularDot ?? this.showSpecularDot,
      pillFrostOpacity: pillFrostOpacity ?? this.pillFrostOpacity,
      backdropSaturation: backdropSaturation ?? this.backdropSaturation,
      accent: accent ?? this.accent,
      height: height ?? this.height,
      radius: radius ?? this.radius,
      barPadding: barPadding ?? this.barPadding,
      widthFactor: widthFactor ?? this.widthFactor,
      edgePadding: edgePadding ?? this.edgePadding,
      selectedWidthFactor: selectedWidthFactor ?? this.selectedWidthFactor,
      selectedSideInsetPx: selectedSideInsetPx ?? this.selectedSideInsetPx,
      selectedHeightFactor: selectedHeightFactor ?? this.selectedHeightFactor,
      selectedInsetPx: selectedInsetPx ?? this.selectedInsetPx,
      selectedCornerAuto: selectedCornerAuto ?? this.selectedCornerAuto,
      selectedBlurSigma: selectedBlurSigma ?? this.selectedBlurSigma,
      selectedStartOpacity: selectedStartOpacity ?? this.selectedStartOpacity,
      selectedEndOpacity: selectedEndOpacity ?? this.selectedEndOpacity,
      selectedBorderOpacity:
          selectedBorderOpacity ?? this.selectedBorderOpacity,
      selectedFrostOpacity: selectedFrostOpacity ?? this.selectedFrostOpacity,
      selectedRadialOpacity:
          selectedRadialOpacity ?? this.selectedRadialOpacity,
      selectedRadialRadiusFactor:
          selectedRadialRadiusFactor ?? this.selectedRadialRadiusFactor,
      selectedRadialCenter: selectedRadialCenter ?? this.selectedRadialCenter,
      searchButtonSize: searchButtonSize ?? this.searchButtonSize,
      searchButtonBlur: searchButtonBlur ?? this.searchButtonBlur,
      searchButtonBorderWidth:
          searchButtonBorderWidth ?? this.searchButtonBorderWidth,
      searchGap: searchGap ?? this.searchGap,
      searchIcon: searchIcon ?? this.searchIcon,
      actionButtonMode: actionButtonMode ?? this.actionButtonMode,
      iconSize: iconSize ?? this.iconSize,
      nativeIconPointSize: nativeIconPointSize ?? this.nativeIconPointSize,
      nativeIconWeight: nativeIconWeight ?? this.nativeIconWeight,
    );
  }
}

class GlassBottomBar extends StatefulWidget {
  final List<GlassBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onSearchTap;
  final List<GlassActionButtonItem> leadingActions;
  final List<GlassActionButtonItem> trailingActions;
  final GlassBottomNavStyle style;
  final double? width;
  final double? height;

  const GlassBottomBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.onSearchTap,
    this.leadingActions = const [],
    this.trailingActions = const [],
    this.style = const GlassBottomNavStyle(),
    this.width,
    this.height,
  }) : assert(
         items.length >= 2 && items.length <= 4,
         'GlassBottomBar supports 2 to 4 items.',
       ),
       assert(
         currentIndex >= 0 && currentIndex < items.length,
         'currentIndex must be in range of items.',
       ),
       assert(width == null || width > 0, 'width must be greater than 0.'),
       assert(height == null || height > 0, 'height must be greater than 0.');

  @override
  State<GlassBottomBar> createState() => _GlassBottomBarState();
}

class _GlassBottomBarState extends State<GlassBottomBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 340),
  );

  late int _oldIndex = widget.currentIndex;
  late int _fromIndex = widget.currentIndex;
  late int _toIndex = widget.currentIndex;

  @override
  void didUpdateWidget(covariant GlassBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_oldIndex != widget.currentIndex) {
      _fromIndex = oldWidget.currentIndex;
      _toIndex = widget.currentIndex;
      _controller.forward(from: 0);
      _oldIndex = widget.currentIndex;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;
    final trailingActions = [
      ...widget.trailingActions,
      if (widget.onSearchTap != null)
        GlassActionButtonItem(
          type: GlassActionIcon.search,
          icon: style.searchIcon,
          semanticLabel: 'Search',
          onTap: widget.onSearchTap!,
        ),
    ];
    final actionCount = widget.leadingActions.length + trailingActions.length;
    final actionTotal = actionCount == 0
        ? 0.0
        : (actionCount * style.searchButtonSize) +
              (math.max(0, actionCount) * style.searchGap);

    final flutterBar = LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        final availableForContent = math.max(
          0,
          availableWidth - (2 * style.edgePadding),
        );
        final maxBarWidth = math.max(0, availableForContent - actionTotal);
        final targetBarWidth =
            availableWidth * style.widthFactor -
            (2 * style.edgePadding) -
            actionTotal;

        const minBarWidth = 160.0;
        final effectiveMin = math.min(minBarWidth, maxBarWidth);
        final autoBarWidth = targetBarWidth
            .clamp(effectiveMin, maxBarWidth)
            .toDouble();
        final barWidth = widget.width != null
            ? widget.width!.clamp(0.0, maxBarWidth).toDouble()
            : autoBarWidth;

        final scale = (availableWidth / 390).clamp(0.9, 1.15).toDouble();
        final autoHeight = (56 * scale).clamp(50.0, 72.0).toDouble();
        final barHeight = widget.height ?? autoHeight;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: style.edgePadding),
            for (final action in widget.leadingActions) ...[
              _ActionButtonSlot(item: action, style: style, height: barHeight),
              SizedBox(width: style.searchGap),
            ],
            _FrostedPill(
              key: const ValueKey('glass_bottom_bar_pill'),
              width: barWidth,
              height: barHeight,
              radius: style.radius,
              padding: style.barPadding,
              blurSigma: style.pillBlurSigma,
              saturation: style.backdropSaturation,
              filmStart: style.pillFilmStart,
              filmEnd: style.pillFilmEnd,
              rimOpacity: style.pillBorderOpacity,
              tint: style.pillTint,
              frostOpacity: style.pillFrostOpacity,
              showSpecularDot: style.showSpecularDot,
              child: _BarContent(
                items: widget.items,
                currentIndex: widget.currentIndex,
                onTap: widget.onTap,
                accent: style.accent,
                controller: _controller,
                iconSize: style.iconSize,
                selectedWidthFactor: style.selectedWidthFactor,
                selectedSideInsetPx: style.selectedSideInsetPx,
                selectedHeightFactor: style.selectedHeightFactor,
                selectedInsetPx: style.selectedInsetPx,
                selectedCornerAuto: style.selectedCornerAuto,
                selectedBlurSigma: style.selectedBlurSigma,
                selectedStartOpacity: style.selectedStartOpacity,
                selectedEndOpacity: style.selectedEndOpacity,
                selectedBorderOpacity: style.selectedBorderOpacity,
                selectedFrostOpacity: style.selectedFrostOpacity,
                selectedRadialOpacity: style.selectedRadialOpacity,
                selectedRadialRadiusFactor: style.selectedRadialRadiusFactor,
                selectedRadialCenter: style.selectedRadialCenter,
                backdropSaturation: style.backdropSaturation,
                fromIndex: _fromIndex,
                toIndex: _toIndex,
              ),
            ),
            for (final action in trailingActions) ...[
              SizedBox(width: style.searchGap),
              _ActionButtonSlot(
                key: action.type == GlassActionIcon.search
                    ? const ValueKey('glass_bottom_bar_search_button')
                    : null,
                item: action,
                style: style,
                height: barHeight,
              ),
            ],
            SizedBox(width: style.edgePadding),
          ],
        );
      },
    );

    if (style.actionButtonMode !=
            GlassActionButtonMode.nativeLiquidGlassOnIOS26 ||
        defaultTargetPlatform != TargetPlatform.iOS) {
      return flutterBar;
    }

    return _AdaptiveNativeGlassBottomBar(
      items: widget.items,
      currentIndex: widget.currentIndex,
      onTap: widget.onTap,
      style: style,
      leadingActions: widget.leadingActions,
      trailingActions: trailingActions,
      actionTotal: actionTotal,
      fallback: flutterBar,
    );
  }
}

class _AdaptiveNativeGlassBottomBar extends StatefulWidget {
  final List<GlassBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final GlassBottomNavStyle style;
  final List<GlassActionButtonItem> leadingActions;
  final List<GlassActionButtonItem> trailingActions;
  final double actionTotal;
  final Widget fallback;

  const _AdaptiveNativeGlassBottomBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.style,
    required this.leadingActions,
    required this.trailingActions,
    required this.actionTotal,
    required this.fallback,
  });

  @override
  State<_AdaptiveNativeGlassBottomBar> createState() =>
      _AdaptiveNativeGlassBottomBarState();
}

class _AdaptiveNativeGlassBottomBarState
    extends State<_AdaptiveNativeGlassBottomBar> {
  static Future<bool>? _supportsNativeLiquidGlass;
  MethodChannel? _barChannel;

  @override
  void didUpdateWidget(covariant _AdaptiveNativeGlassBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sendUpdate();
  }

  @override
  void dispose() {
    _barChannel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _supportsNativeLiquidGlass ??= _nativeGlassChannel
        .invokeMethod<bool>('isLiquidGlassSupported')
        .then((value) => value ?? false)
        .catchError((_) => false);

    return FutureBuilder<bool>(
      future: _supportsNativeLiquidGlass,
      builder: (context, snapshot) {
        if (snapshot.data != true) {
          return widget.fallback;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.hasBoundedWidth
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width;
            final availableForContent = math.max(
              0.0,
              availableWidth - (2 * widget.style.edgePadding),
            );
            final maxBarWidth = math.max(
              0.0,
              availableForContent - widget.actionTotal,
            );
            final targetBarWidth =
                availableWidth * widget.style.widthFactor -
                (2 * widget.style.edgePadding) -
                widget.actionTotal;
            const minBarWidth = 160.0;
            final effectiveMin = math.min(minBarWidth, maxBarWidth);
            final autoBarWidth = targetBarWidth
                .clamp(effectiveMin, maxBarWidth)
                .toDouble();
            final barWidth = widget.style.widthFactor <= 0
                ? maxBarWidth
                : autoBarWidth;
            final scale = (availableWidth / 390).clamp(0.9, 1.15).toDouble();
            // Native UITabBar needs enough vertical room to lay the label
            // below the icon; too short and iOS collapses them together.
            final autoHeight = (74 * scale).clamp(70.0, 92.0).toDouble();
            final barHeight =
                widget.style.height == const GlassBottomNavStyle().height
                ? autoHeight
                : math.max(widget.style.height, 70.0);

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: widget.style.edgePadding),
                for (final action in widget.leadingActions) ...[
                  _ActionButtonSlot(
                    item: action,
                    style: widget.style,
                    height: barHeight,
                  ),
                  SizedBox(width: widget.style.searchGap),
                ],
                SizedBox(
                  key: const ValueKey('glass_bottom_bar_native_pill'),
                  width: barWidth,
                  height: barHeight + 8,
                  child: UiKitView(
                    viewType: _nativeGlassBarViewType,
                    creationParamsCodec: const StandardMessageCodec(),
                    creationParams: _nativeParams(),
                    onPlatformViewCreated: (id) {
                      final channel = MethodChannel(
                        'glass_bottom_navigation/native_glass_bar_$id',
                      );
                      _barChannel?.setMethodCallHandler(null);
                      _barChannel = channel;
                      channel.setMethodCallHandler((call) async {
                        if (call.method == 'tap') {
                          final index = call.arguments as int;
                          widget.onTap(index);
                        }
                      });
                      _sendUpdate();
                    },
                  ),
                ),
                for (final action in widget.trailingActions) ...[
                  SizedBox(width: widget.style.searchGap),
                  _ActionButtonSlot(
                    key: action.type == GlassActionIcon.search
                        ? const ValueKey('glass_bottom_bar_search_button')
                        : null,
                    item: action,
                    style: widget.style,
                    height: barHeight,
                  ),
                ],
                SizedBox(width: widget.style.edgePadding),
              ],
            );
          },
        );
      },
    );
  }

  Map<String, Object?> _nativeParams() {
    return {
      'items': widget.items
          .map(
            (item) => {
              'label': item.label,
              'symbolName': item.nativeSymbolName,
            },
          )
          .toList(),
      'currentIndex': widget.currentIndex,
      'accent': widget.style.accent.toARGB32(),
      'radius': widget.style.radius,
      'iconPointSize': widget.style.nativeIconPointSize,
      'iconWeight': widget.style.nativeIconWeight,
    };
  }

  void _sendUpdate() {
    _barChannel?.invokeMethod<void>('update', _nativeParams());
  }
}

class GlassActionButton extends StatelessWidget {
  final GlassActionButtonItem item;
  final GlassBottomNavStyle style;

  const GlassActionButton({
    super.key,
    required this.item,
    this.style = const GlassBottomNavStyle(),
  });

  @override
  Widget build(BuildContext context) {
    return _AdaptiveGlassActionButton(
      item: item,
      mode: style.actionButtonMode,
      size: style.searchButtonSize,
      blur: style.searchButtonBlur,
      borderWidth: style.searchButtonBorderWidth,
    );
  }
}

class GlassActionButtonRow extends StatelessWidget {
  final List<GlassActionButtonItem> actions;
  final GlassBottomNavStyle style;
  final Axis direction;

  const GlassActionButtonRow({
    super.key,
    required this.actions,
    this.style = const GlassBottomNavStyle(),
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < actions.length; i++) {
      if (i > 0) {
        children.add(SizedBox(width: style.searchGap, height: style.searchGap));
      }
      children.add(GlassActionButton(item: actions[i], style: style));
    }

    return Flex(
      direction: direction,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

class _ActionButtonSlot extends StatelessWidget {
  final GlassActionButtonItem item;
  final GlassBottomNavStyle style;
  final double height;

  const _ActionButtonSlot({
    super.key,
    required this.item,
    required this.style,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: style.searchButtonSize,
      height: height,
      child: Center(
        child: GlassActionButton(item: item, style: style),
      ),
    );
  }
}

class _BarContent extends StatelessWidget {
  final List<GlassBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color accent;
  final AnimationController controller;
  final double iconSize;
  final double selectedWidthFactor;
  final double selectedSideInsetPx;
  final double selectedHeightFactor;
  final double selectedInsetPx;
  final bool selectedCornerAuto;
  final double selectedBlurSigma;
  final double selectedStartOpacity;
  final double selectedEndOpacity;
  final double selectedBorderOpacity;
  final double selectedFrostOpacity;
  final double selectedRadialOpacity;
  final double selectedRadialRadiusFactor;
  final Alignment selectedRadialCenter;
  final double backdropSaturation;
  final int fromIndex;
  final int toIndex;

  const _BarContent({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.accent,
    required this.controller,
    required this.iconSize,
    required this.selectedWidthFactor,
    required this.selectedSideInsetPx,
    required this.selectedHeightFactor,
    required this.selectedInsetPx,
    required this.selectedCornerAuto,
    required this.selectedBlurSigma,
    required this.backdropSaturation,
    required this.selectedStartOpacity,
    required this.selectedEndOpacity,
    required this.selectedBorderOpacity,
    required this.selectedFrostOpacity,
    required this.selectedRadialOpacity,
    required this.selectedRadialRadiusFactor,
    required this.selectedRadialCenter,
    required this.fromIndex,
    required this.toIndex,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemW = constraints.maxWidth / items.length;

        const minSelH = 24.0;
        final maxSelH = math.max(
          minSelH,
          constraints.maxHeight - (2 * selectedInsetPx),
        );
        final selH = (constraints.maxHeight * selectedHeightFactor)
            .clamp(minSelH, maxSelH)
            .toDouble();

        final availW = math.max(0.0, itemW - (2 * selectedSideInsetPx));
        final minSelW = math.min(48.0, availW);
        final selW = (availW * selectedWidthFactor)
            .clamp(minSelW, availW)
            .toDouble();
        final left =
            currentIndex * itemW + selectedSideInsetPx + ((availW - selW) / 2);
        final top = (constraints.maxHeight - selH) / 2;
        final corner = selectedCornerAuto ? selH / 2 : 20.0;

        return Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 340),
              curve: Curves.easeOutQuart,
              left: left,
              top: top,
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  final progress = Curves.easeOutCubic.transform(
                    controller.value,
                  );
                  final direction = toIndex >= fromIndex ? 1.0 : -1.0;

                  return _BrightFrostSelection(
                    width: selW,
                    height: selH,
                    corner: corner,
                    blurSigma: selectedBlurSigma,
                    saturation: backdropSaturation,
                    startOpacity: selectedStartOpacity,
                    endOpacity: selectedEndOpacity,
                    borderOpacity: selectedBorderOpacity,
                    frostOpacity: selectedFrostOpacity,
                    radialOpacity: selectedRadialOpacity,
                    radialRadiusFactor: selectedRadialRadiusFactor,
                    radialCenter: selectedRadialCenter,
                    transitionProgress: progress,
                    direction: direction,
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(items.length, (i) {
                final selected = i == currentIndex;

                return _Pressable(
                  onTap: () => onTap(i),
                  borderRadius: BorderRadius.circular(corner),
                  child: SizedBox(
                    width: itemW,
                    height: constraints.maxHeight,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: selected ? 1 : 0),
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      builder: (context, t, child) {
                        final iconColor = Color.lerp(
                          const Color(0xE6151B18),
                          accent,
                          t,
                        )!;
                        final labelColor = Color.lerp(
                          const Color(0xC4151B18),
                          accent,
                          t,
                        )!;

                        return Transform.scale(
                          scale: 0.975 + (t * 0.045),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                items[i].icon,
                                size: iconSize,
                                color: iconColor,
                                shadows: [
                                  Shadow(
                                    color: Colors.white.withValues(
                                      alpha: 0.10 + (0.14 * t),
                                    ),
                                    blurRadius: 9,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Flexible(
                                child: Text(
                                  items[i].label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.1,
                                    color: labelColor,
                                    shadows: [
                                      Shadow(
                                        color: Colors.white.withValues(
                                          alpha: 0.08 + (0.10 * t),
                                        ),
                                        blurRadius: 7,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

class _FrostedPill extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final EdgeInsets padding;
  final Widget child;
  final Color tint;
  final double blurSigma;
  final double saturation;
  final double filmStart;
  final double filmEnd;
  final double rimOpacity;
  final bool showSpecularDot;
  final double frostOpacity;

  const _FrostedPill({
    super.key,
    required this.width,
    required this.height,
    required this.radius,
    required this.padding,
    required this.child,
    required this.tint,
    required this.blurSigma,
    this.saturation = 1.0,
    required this.filmStart,
    required this.filmEnd,
    required this.rimOpacity,
    this.showSpecularDot = true,
    this.frostOpacity = 0.06,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height + 8,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: BackdropFilter(
                filter: _glassBackdrop(blurSigma, saturation),
                child: Container(
                  padding: padding,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        tint.withValues(alpha: filmStart),
                        tint.withValues(alpha: filmEnd),
                      ],
                    ),
                    border: rimOpacity <= 0
                        ? null
                        : Border.all(
                            color: Colors.white.withValues(alpha: rimOpacity),
                            width: 0.7,
                          ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: frostOpacity),
                            borderRadius: BorderRadius.circular(radius),
                          ),
                        ),
                      ),
                      const Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _GrainPainter(opacity: 0.025, count: 700),
                          ),
                        ),
                      ),
                      if (showSpecularDot)
                        Positioned(
                          top: 6,
                          left: 8,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.95),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  blurRadius: 10,
                                  spreadRadius: 1.2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      child,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrightFrostSelection extends StatelessWidget {
  final double width;
  final double height;
  final double corner;
  final double blurSigma;
  final double saturation;
  final double startOpacity;
  final double endOpacity;
  final double borderOpacity;
  final double frostOpacity;
  final double radialOpacity;
  final double radialRadiusFactor;
  final Alignment radialCenter;
  final double transitionProgress;
  final double direction;

  const _BrightFrostSelection({
    required this.width,
    required this.height,
    required this.corner,
    this.blurSigma = 46,
    this.saturation = 1.0,
    this.startOpacity = 0.30,
    this.endOpacity = 0.16,
    this.borderOpacity = 0.90,
    this.frostOpacity = 0.10,
    this.radialOpacity = 0.14,
    this.radialRadiusFactor = 0.90,
    this.radialCenter = const Alignment(-0.10, -0.10),
    this.transitionProgress = 0,
    this.direction = 1,
  });

  @override
  Widget build(BuildContext context) {
    final r = math.min(width, height) * 0.5 * radialRadiusFactor;
    final sweepPulse = math.sin(transitionProgress * math.pi).clamp(0.0, 1.0);
    final borderAlpha = (borderOpacity + (0.04 * sweepPulse)).clamp(0.0, 1.0);
    final coreOpacity = (radialOpacity + (0.08 * sweepPulse)).clamp(0.0, 1.0);

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(corner),
            child: BackdropFilter(
              filter: _glassBackdrop(blurSigma, saturation),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(corner),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(
                        alpha: startOpacity + (0.05 * sweepPulse),
                      ),
                      Colors.white.withValues(
                        alpha: endOpacity + (0.03 * sweepPulse),
                      ),
                    ],
                  ),
                  border: borderAlpha <= 0
                      ? null
                      : Border.all(
                          color: Colors.white.withValues(
                            alpha: borderAlpha * 0.85,
                          ),
                          width: 0.65,
                        ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: frostOpacity),
                          borderRadius: BorderRadius.circular(corner),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _MovingSweepPainter(
                            progress: transitionProgress,
                            pulse: sweepPulse,
                            corner: corner,
                            direction: direction,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _RadialHighlightPainter(
                          centerAlignment: radialCenter,
                          radius: r,
                          opacity: coreOpacity,
                        ),
                      ),
                    ),
                    const Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _GrainPainter(opacity: 0.022, count: 450),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadialHighlightPainter extends CustomPainter {
  final Alignment centerAlignment;
  final double radius;
  final double opacity;

  const _RadialHighlightPainter({
    required this.centerAlignment,
    required this.radius,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      ((centerAlignment.x + 1) / 2) * size.width,
      ((centerAlignment.y + 1) / 2) * size.height,
    );

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: opacity),
          Colors.transparent,
        ],
        stops: const [0, 0.6],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RadialHighlightPainter oldDelegate) {
    return oldDelegate.centerAlignment != centerAlignment ||
        oldDelegate.radius != radius ||
        oldDelegate.opacity != opacity;
  }
}

class _MovingSweepPainter extends CustomPainter {
  final double progress;
  final double pulse;
  final double corner;
  final double direction;

  const _MovingSweepPainter({
    required this.progress,
    required this.pulse,
    required this.corner,
    required this.direction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pulse <= 0) {
      return;
    }

    final sweepWidth = size.width * 0.56;
    final fromX = direction > 0 ? -sweepWidth : size.width + sweepWidth;
    final toX = direction > 0 ? size.width + sweepWidth : -sweepWidth;
    final sweepX = lerpDouble(fromX, toX, progress) ?? (size.width * 0.5);

    final sweepRect = Rect.fromLTWH(
      sweepX - (sweepWidth / 2),
      -size.height * 0.45,
      sweepWidth,
      size.height * 1.90,
    );

    final shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withValues(alpha: 0),
        Colors.white.withValues(alpha: 0.16 * pulse),
        Colors.white.withValues(alpha: 0.04 * pulse),
        Colors.white.withValues(alpha: 0),
      ],
      stops: const [0.0, 0.35, 0.62, 1.0],
      transform: GradientRotation(direction * -0.20),
    ).createShader(sweepRect);

    final paint = Paint()
      ..shader = shader
      ..blendMode = BlendMode.screen;

    canvas
      ..save()
      ..clipRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(corner)),
      )
      ..drawRect(sweepRect, paint)
      ..restore();
  }

  @override
  bool shouldRepaint(covariant _MovingSweepPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.pulse != pulse ||
        oldDelegate.corner != corner ||
        oldDelegate.direction != direction;
  }
}

class _GrainPainter extends CustomPainter {
  final double opacity;
  final int count;

  const _GrainPainter({this.opacity = 0.02, this.count = 600});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(7);
    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < count; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final alpha = opacity * (0.6 + (random.nextDouble() * 0.4));
      final isLight = random.nextBool();
      paint.color = (isLight ? Colors.white : Colors.black).withValues(
        alpha: alpha,
      );
      canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) {
    return oldDelegate.opacity != opacity || oldDelegate.count != count;
  }
}

class _AdaptiveGlassActionButton extends StatefulWidget {
  final GlassActionButtonItem item;
  final GlassActionButtonMode mode;
  final double size;
  final double blur;
  final double borderWidth;

  const _AdaptiveGlassActionButton({
    required this.item,
    required this.mode,
    required this.size,
    required this.blur,
    required this.borderWidth,
  });

  @override
  State<_AdaptiveGlassActionButton> createState() =>
      _AdaptiveGlassActionButtonState();
}

class _AdaptiveGlassActionButtonState
    extends State<_AdaptiveGlassActionButton> {
  static Future<bool>? _supportsNativeLiquidGlass;
  MethodChannel? _buttonChannel;

  @override
  void dispose() {
    _buttonChannel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fallback = _GlassCircleButton(
      icon: widget.item.icon ?? _iconForType(widget.item.type),
      onTap: widget.item.onTap,
      size: widget.size,
      blur: widget.blur,
      borderWidth: widget.borderWidth,
      semanticLabel: widget.item.semanticLabel,
    );

    if (widget.mode != GlassActionButtonMode.nativeLiquidGlassOnIOS26 ||
        defaultTargetPlatform != TargetPlatform.iOS ||
        (widget.item.type == GlassActionIcon.custom &&
            widget.item.nativeSymbolName == null)) {
      return fallback;
    }

    _supportsNativeLiquidGlass ??= _nativeGlassChannel
        .invokeMethod<bool>('isLiquidGlassSupported')
        .then((value) => value ?? false)
        .catchError((_) => false);

    return FutureBuilder<bool>(
      future: _supportsNativeLiquidGlass,
      builder: (context, snapshot) {
        if (snapshot.data != true) {
          return fallback;
        }

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: UiKitView(
            viewType: _nativeGlassButtonViewType,
            creationParamsCodec: const StandardMessageCodec(),
            creationParams: {
              'icon': widget.item.type.name,
              'label': widget.item.semanticLabel,
              'style': widget.item.nativeStyle.name,
              'symbolName': widget.item.nativeSymbolName,
              'size': widget.size,
            },
            onPlatformViewCreated: (id) {
              final channel = MethodChannel(
                'glass_bottom_navigation/native_glass_button_$id',
              );
              _buttonChannel?.setMethodCallHandler(null);
              _buttonChannel = channel;
              channel.setMethodCallHandler((call) async {
                if (call.method == 'tap') {
                  widget.item.onTap();
                }
              });
            },
          ),
        );
      },
    );
  }

  IconData _iconForType(GlassActionIcon type) {
    return switch (type) {
      GlassActionIcon.back => Icons.arrow_back_ios_new_rounded,
      GlassActionIcon.close => Icons.close_rounded,
      GlassActionIcon.search => Icons.search_rounded,
      GlassActionIcon.more => Icons.more_horiz_rounded,
      GlassActionIcon.add => Icons.add_rounded,
      GlassActionIcon.settings => Icons.settings_rounded,
      GlassActionIcon.favorite => Icons.favorite_rounded,
      GlassActionIcon.share => Icons.ios_share_rounded,
      GlassActionIcon.custom => Icons.circle,
    };
  }
}

/// Wraps a tappable glass surface with interactive press feedback: a subtle
/// scale-down plus a brightening overlay, mimicking `.glassEffect(.interactive())`
/// on iOS 26. The overlay is clipped to [borderRadius] so it matches the host
/// shape (pill, circle, etc.).
class _Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  const _Pressable({
    required this.child,
    required this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(999)),
  });

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  void _setDown(bool value) {
    if (mounted && _down != value) {
      setState(() => _down = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setDown(true),
      onTapUp: (_) => _setDown(false),
      onTapCancel: () => _setDown(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: Stack(
          children: [
            widget.child,
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _down ? 1 : 0,
                  duration: const Duration(milliseconds: 130),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: widget.borderRadius,
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double blur;
  final double borderWidth;
  final String? semanticLabel;

  const _GlassCircleButton({
    required this.icon,
    required this.onTap,
    required this.size,
    required this.blur,
    required this.borderWidth,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: _Pressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              Positioned.fill(
                top: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                        spreadRadius: -6,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(size),
                  child: BackdropFilter(
                    filter: _glassBackdrop(blur, 1.35),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.58),
                            Colors.white.withValues(alpha: 0.36),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.96),
                          width: borderWidth,
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          IgnorePointer(
                            child: CustomPaint(
                              painter: _GrainPainter(
                                opacity: 0.025,
                                count: 400,
                              ),
                            ),
                          ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color.fromRGBO(255, 255, 255, 0.24),
                                  Color.fromRGBO(255, 255, 255, 0.08),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Icon(
                  icon,
                  size: 26,
                  color: Colors.black.withValues(alpha: 0.90),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
