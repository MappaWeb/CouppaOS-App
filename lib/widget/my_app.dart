import 'dart:math';

import 'package:flutter/services.dart';
import 'package:glass_bottom_navigation/glass_bottom_navigation.dart';

import '../import.dart';

class NavItem {
  const NavItem({
    required this.label,
    required this.path,
    required this.icon,
    required this.symbol,
  });

  final String label;
  final String path;
  final IconData icon;
  final String symbol;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.child, required this.state});

  final Widget child;
  final GoRouterState state;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<NavItem> _getNavItems(UserRole role) {
    switch (role) {
      case UserRole.user:
        return const [
          NavItem(
            label: 'Coupon của tôi',
            path: '/User/Coupon',
            icon: Icons.confirmation_number_outlined,
            symbol: 'ticket',
          ),
          NavItem(
            label: 'Nhận voucher',
            path: '/User/VoucherClaim',
            icon: Icons.redeem_outlined,
            symbol: 'gift',
          ),
          NavItem(
            label: 'Tài khoản',
            path: '/Account',
            icon: Icons.person_outline,
            symbol: 'person.crop.circle',
          ),
        ];
      case UserRole.merchant:
        return const [
          NavItem(
            label: 'Chiến dịch',
            path: '/Merchant/Coupon',
            icon: Icons.local_offer_outlined,
            symbol: 'tag',
          ),
          NavItem(
            label: 'Hợp tác',
            path: '/Merchant/Partners',
            icon: Icons.handshake_outlined,
            symbol: 'person.2',
          ),
          NavItem(
            label: 'Báo cáo',
            path: '/Merchant/Report',
            icon: Icons.insert_chart_outlined,
            symbol: 'chart.bar',
          ),
          NavItem(
            label: 'Tài khoản',
            path: '/Account',
            icon: Icons.person_outline,
            symbol: 'person.crop.circle',
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: viewAsUser,
      builder: (context, _, _) => _buildShell(context),
    );
  }

  static const double _glassBarHeight = 76;
  static const double _glassBarBottomMargin = 12;

  Widget _buildShell(BuildContext context) {
    final UserRole role = getRole();
    final List<NavItem> navItems = _getNavItems(role);
    final List<String> currentPaths = navItems.map((e) => e.path).toList();

    final String currentPath = widget.state.uri.toString();
    final int currentIndex = max(currentPaths.indexOf(currentPath), 0);

    final mq = MediaQuery.of(context);
    final bool keyboardOpen = mq.viewInsets.bottom > 0;
    final double extraBottom = keyboardOpen ? 0 : _glassBarHeight + _glassBarBottomMargin;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBody: true,
        body: MediaQuery(
          data: mq.copyWith(
            padding: mq.padding.copyWith(bottom: mq.padding.bottom + extraBottom),
            viewPadding: mq.viewPadding.copyWith(bottom: mq.viewPadding.bottom + extraBottom),
          ),
          child: widget.child,
        ),
        bottomNavigationBar: keyboardOpen
            ? const SizedBox.shrink()
            : SafeArea(
                minimum: const EdgeInsets.only(bottom: _glassBarBottomMargin),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: GlassBottomBar(
                    items: [
                      for (final item in navItems)
                        GlassBarItem(
                          icon: item.icon,
                          label: item.label,
                          nativeSymbolName: item.symbol,
                        ),
                    ],
                    currentIndex: currentIndex,
                    onTap: (index) => appNavigator.go(currentPaths[index]),
                    style: const GlassBottomNavStyle(
                      accent: Palette.primary,
                      pillTint: Color(0xFFDDDDDD),
                      pillFilmStart: 0.72,
                      pillFilmEnd: 0.52,
                      pillBorderOpacity: 0.22,
                      backdropSaturation: 1.2,
                      iconSize: 16,
                      nativeIconPointSize: 14,
                      nativeIconWeight: 'regular',
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
