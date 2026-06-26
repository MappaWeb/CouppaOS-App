import 'config/dev_bypass.dart';
import 'import.dart';
import 'pages/account/page.dart';
import 'pages/merchant/coupon/page.dart';
import 'pages/merchant/redeem/page.dart';
import 'pages/merchant/report/page.dart';
import 'pages/user/coupon/page.dart';
import 'widget/my_app.dart';

// Branch indices:
//  0: /User/Coupon          (user)
//  1: /Merchant/Coupon      (merchant)
//  2: /Merchant/Redeem      (merchant)
//  3: /Merchant/Report      (merchant)
//  4: /Account              (both roles)
const _roleBranches = <UserRole, List<int>>{
  UserRole.user: [0, 4],
  UserRole.merchant: [1, 2, 3, 4],
};

CustomTransitionPage<T> _fadePage<T>({
  required LocalKey key,
  required String name,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    name: name,
    child: child,
    transitionDuration: Duration.zero,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

String? _requireAuth(BuildContext context, GoRouterState state) {
  if (DevBypass.active) return null;
  if (!AuthGuard.instance.isAuthenticated) return '/Login';
  return null;
}

final shellRouter = [
  StatefulShellRoute(
    navigatorContainerBuilder: (context, navigationShell, children) {
      final activeIndices = _roleBranches[getRole()]!;
      int localIndex = activeIndices.indexOf(navigationShell.currentIndex);
      if (localIndex < 0) localIndex = 0;
      return IndexedStack(
        index: localIndex,
        children: [for (final i in activeIndices) children[i]],
      );
    },
    builder: (context, state, child) => MyApp(state: state, child: child),
    redirect: (context, state) {
      if (DevBypass.active) return null;
      if (!AuthGuard.instance.isAuthenticated) {
        return '/Login';
      }
      return null;
    },
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/User/Coupon',
            pageBuilder: (context, state) => _fadePage(
              key: state.pageKey,
              name: state.uri.path,
              child: const UserCouponPage(),
            ),
            redirect: _requireAuth,
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/Merchant/Coupon',
            pageBuilder: (context, state) => _fadePage(
              key: state.pageKey,
              name: state.uri.path,
              child: const MerchantCouponPage(),
            ),
            redirect: _requireAuth,
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/Merchant/Redeem',
            pageBuilder: (context, state) => _fadePage(
              key: state.pageKey,
              name: state.uri.path,
              child: const MerchantRedeemPage(),
            ),
            redirect: _requireAuth,
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/Merchant/Report',
            pageBuilder: (context, state) => _fadePage(
              key: state.pageKey,
              name: state.uri.path,
              child: const MerchantReportPage(),
            ),
            redirect: _requireAuth,
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/Account',
            pageBuilder: (context, state) => _fadePage(
              key: state.pageKey,
              name: state.uri.path,
              child: const AccountPage(),
            ),
            redirect: _requireAuth,
          ),
        ],
      ),
    ],
  ),
];
