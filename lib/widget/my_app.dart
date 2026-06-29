import 'dart:math';

import 'package:flutter/services.dart';

import '../import.dart';

class NavItem {
  const NavItem({
    required this.label,
    required this.path,
    required this.icon,
  });

  final String label;
  final String path;
  final IconData icon;
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
          ),
          NavItem(
            label: 'Tài khoản',
            path: '/Account',
            icon: Icons.person_outline,
          ),
        ];
      case UserRole.merchant:
        return const [
          NavItem(
            label: 'Quản lý chiến dịch',
            path: '/Merchant/Coupon',
            icon: Icons.local_offer_outlined,
          ),
          NavItem(
            label: 'Quét mã',
            path: '/Merchant/Redeem',
            icon: Icons.qr_code_scanner,
          ),
          NavItem(
            label: 'Báo cáo',
            path: '/Merchant/Report',
            icon: Icons.insert_chart_outlined,
          ),
          NavItem(
            label: 'Tài khoản',
            path: '/Account',
            icon: Icons.person_outline,
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

  Widget _buildShell(BuildContext context) {
    final UserRole role = getRole();
    final List<NavItem> navItems = _getNavItems(role);
    final List<String> currentPaths = navItems.map((e) => e.path).toList();

    final String currentPath = widget.state.uri.toString();
    final int currentIndex = max(currentPaths.indexOf(currentPath), 0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: MediaQuery.of(context).viewInsets.bottom > 0
            ? const SizedBox.shrink()
            : DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFEAECF0))),
                ),
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  currentIndex: currentIndex,
                  onTap: (index) => appNavigator.go(currentPaths[index]),
                  selectedItemColor: Palette.primary,
                  unselectedItemColor: Palette.textPrimary4,
                  items: [
                    for (final item in navItems)
                      BottomNavigationBarItem(
                        icon: Icon(item.icon),
                        label: item.label,
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
