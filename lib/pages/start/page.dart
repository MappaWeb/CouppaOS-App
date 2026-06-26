import '../../import.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  static String? redirect(BuildContext context, GoRouterState state) {
    if (!AuthGuard.instance.isAuthenticated) {
      return '/Start/WithoutLogin';
    }
    return getRole() == UserRole.merchant ? '/Merchant/Coupon' : '/User/Coupon';
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
